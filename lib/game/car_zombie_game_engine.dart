import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/car_zombie_game_state.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';

enum CarZombieGameStatus {
  playing,
  paused,
  gameOver,
}

class CarZombieGameEngine extends ChangeNotifier {
  CarZombieGameStatus status = CarZombieGameStatus.playing;

  late CarZombieVehicleState car;
  final List<CarZombieEnemy> zombies = [];
  final List<CarZombieBullet> bullets = [];
  final List<CarZombieObstacle> obstacles = [];
  final List<CarZombieCollectible> collectibles = [];
  final List<CarZombieParticle> particles = [];

  // Game Stats
  double distanceMeters = 0.0;
  int score = 0;
  int sessionCoins = 0;
  int zombiesDefeated = 0;

  // High Scores (Persisted)
  double highDistance = 0.0;
  int highScore = 0;
  int totalZombiesDefeatedInCarMode = 0;

  // Weapon & Ammo
  String activeWeaponId = 'basic';
  int currentClip = 30;
  int maxClip = 30;
  int reserveAmmo = 120;
  int maxReserve = 120;
  bool isReloading = false;
  double reloadTimer = 0.0;
  double fireCooldown = 0.0;

  // Spawning & Difficulty
  double _zombieSpawnTimer = 0.0;
  double _obstacleSpawnTimer = 0.0;
  double _nextObstacleX = 1200.0;
  final Random _random = Random();

  // Screen Bounds
  double screenWidth = 844.0;
  double screenHeight = 390.0;
  double roadY = 280.0;

  CarZombieGameEngine() {
    activeWeaponId = ZombieProgressController.instance.selectedWeapon;
    _configureWeaponStats();
    car = CarZombieVehicleState(x: 220.0, y: roadY - 45.0);
    _loadHighScores();
  }

  void _configureWeaponStats() {
    switch (activeWeaponId) {
      case 'ak47':
        maxClip = 40;
        maxReserve = 200;
        break;
      case 'shotgun':
        maxClip = 12;
        maxReserve = 72;
        break;
      case 'smg':
        maxClip = 35;
        maxReserve = 140;
        break;
      case 'rifle':
        maxClip = 20;
        maxReserve = 100;
        break;
      case 'basic':
      default:
        maxClip = 25;
        maxReserve = 100;
        break;
    }
    currentClip = maxClip;
    reserveAmmo = maxReserve;
  }

  Future<void> _loadHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highDistance = prefs.getDouble('car_zombie_high_distance') ?? 0.0;
      highScore = prefs.getInt('car_zombie_high_score') ?? 0;
      totalZombiesDefeatedInCarMode = prefs.getInt('car_zombie_total_defeated') ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (distanceMeters > highDistance) {
        highDistance = distanceMeters;
        await prefs.setDouble('car_zombie_high_distance', highDistance);
      }
      if (score > highScore) {
        highScore = score;
        await prefs.setInt('car_zombie_high_score', highScore);
      }
      totalZombiesDefeatedInCarMode += zombiesDefeated;
      await prefs.setInt('car_zombie_total_defeated', totalZombiesDefeatedInCarMode);
    } catch (_) {}
  }

  void updateScreenSize(double w, double h) {
    screenWidth = w;
    screenHeight = h;
    roadY = h * 0.72;
    car.y = roadY - car.height + 10;
  }

  void restart() {
    status = CarZombieGameStatus.playing;
    car.reset(roadY - car.height + 10);
    zombies.clear();
    bullets.clear();
    obstacles.clear();
    collectibles.clear();
    particles.clear();

    distanceMeters = 0.0;
    score = 0;
    sessionCoins = 0;
    zombiesDefeated = 0;

    _zombieSpawnTimer = 0.0;
    _obstacleSpawnTimer = 0.0;
    _nextObstacleX = car.x + 1000.0;

    _configureWeaponStats();
    isReloading = false;
    reloadTimer = 0.0;
    fireCooldown = 0.0;

    notifyListeners();
  }

  void togglePause() {
    if (status == CarZombieGameStatus.playing) {
      status = CarZombieGameStatus.paused;
    } else if (status == CarZombieGameStatus.paused) {
      status = CarZombieGameStatus.playing;
    }
    notifyListeners();
  }

  void triggerBoost() {
    if (status != CarZombieGameStatus.playing) return;
    car.isBoosting = true;
    car.boostTimer = 2.5; // Boost duration in seconds
    // Shake particles behind car
    for (int i = 0; i < 12; i++) {
      particles.add(CarZombieParticle(
        x: car.x - 10,
        y: car.y + car.height - 10 + _random.nextDouble() * 15,
        vx: -200 - _random.nextDouble() * 200,
        vy: -30 + _random.nextDouble() * 60,
        color: const Color(0xFF38BDF8),
        size: 5.0,
        life: 0.6,
        maxLife: 0.6,
      ));
    }
    notifyListeners();
  }

  void shoot() {
    if (status != CarZombieGameStatus.playing) return;
    if (isReloading || fireCooldown > 0) return;

    if (currentClip <= 0) {
      reload();
      return;
    }

    currentClip--;
    fireCooldown = activeWeaponId == 'smg' ? 0.12 : (activeWeaponId == 'ak47' ? 0.15 : 0.25);

    // Muzzle flash particle
    final double gunX = car.x + 25;
    final double gunY = car.y + 15;

    // Fire backward toward chasing zombies
    bullets.add(CarZombieBullet(
      id: 'b_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000)}',
      x: gunX,
      y: gunY,
      vx: -850.0 - _random.nextDouble() * 100.0,
      vy: (_random.nextDouble() - 0.5) * 60.0,
      damage: activeWeaponId == 'shotgun' ? 2.5 : (activeWeaponId == 'ak47' ? 2.0 : 1.2),
    ));

    // Shotgun extra pellets
    if (activeWeaponId == 'shotgun') {
      bullets.add(CarZombieBullet(
        id: 'b_${DateTime.now().microsecondsSinceEpoch}_pellet1',
        x: gunX,
        y: gunY - 8,
        vx: -820.0,
        vy: -80.0,
        damage: 2.0,
      ));
      bullets.add(CarZombieBullet(
        id: 'b_${DateTime.now().microsecondsSinceEpoch}_pellet2',
        x: gunX,
        y: gunY + 8,
        vx: -820.0,
        vy: 80.0,
        damage: 2.0,
      ));
    }

    // Spark particles
    for (int i = 0; i < 4; i++) {
      particles.add(CarZombieParticle(
        x: gunX - 10,
        y: gunY,
        vx: -150 - _random.nextDouble() * 100,
        vy: (_random.nextDouble() - 0.5) * 120,
        color: const Color(0xFFFBBF24),
        size: 3.5,
        life: 0.25,
        maxLife: 0.25,
      ));
    }

    if (currentClip == 0) {
      reload();
    }

    notifyListeners();
  }

  void reload() {
    if (isReloading || reserveAmmo <= 0 || currentClip == maxClip) return;
    isReloading = true;
    reloadTimer = 1.4; // 1.4 seconds reload time
    notifyListeners();
  }

  void _completeReload() {
    isReloading = false;
    final needed = maxClip - currentClip;
    final load = min(needed, reserveAmmo);
    currentClip += load;
    reserveAmmo -= load;
  }

  void tick(double dt) {
    if (status != CarZombieGameStatus.playing) return;

    // 1. Vehicle Driving Physics
    double currentSpeed = car.speed;
    if (car.isBoosting) {
      currentSpeed = 720.0;
      car.boostTimer -= dt;
      if (car.boostTimer <= 0) {
        car.isBoosting = false;
      }
    }

    car.x += currentSpeed * dt;
    car.wheelRotation += (currentSpeed * dt) * 0.08;
    distanceMeters += (currentSpeed * dt) * 0.15;
    score += (dt * 20).toInt();

    if (car.damageFlashTimer > 0) {
      car.damageFlashTimer -= dt;
    }

    // Fire cooldown & Reload timers
    if (fireCooldown > 0) {
      fireCooldown -= dt;
    }
    if (isReloading) {
      reloadTimer -= dt;
      if (reloadTimer <= 0) {
        _completeReload();
      }
    }

    // 2. Spawn Zombie Horde Behind
    _zombieSpawnTimer += dt;
    final double targetSpawnInterval = max(0.2, 1.2 - (distanceMeters / 3000.0));
    if (_zombieSpawnTimer >= targetSpawnInterval) {
      _zombieSpawnTimer = 0.0;
      _spawnZombieHordeBatch();
    }

    // 3. Spawn Road Obstacles & Collectibles Ahead
    if (car.x + screenWidth + 200 > _nextObstacleX) {
      _spawnRoadSegmentObjects(_nextObstacleX);
      _nextObstacleX += 600 + _random.nextDouble() * 500;
    }

    // 4. Update Zombie Horde AI & Attacks
    for (int i = zombies.length - 1; i >= 0; i--) {
      final z = zombies[i];
      if (z.hitTimer > 0) z.hitTimer -= dt;

      if (!z.isLatchedToCar) {
        // Zombie chases car
        z.x += (currentSpeed + 35.0) * dt; // Chases from behind
        if (z.x + z.width >= car.x + 10) {
          z.isLatchedToCar = true;
          z.x = car.x + 10 - z.width;
        }
      } else {
        // Latching on rear of car & attacking vehicle!
        z.x = car.x + 10 - z.width;
        z.attackTimer += dt;
        if (z.attackTimer >= 0.8) {
          z.attackTimer = 0.0;
          _damageCar(z.type == CarZombieEnemyType.large ? 8.0 : 4.0);
        }
      }

      // Cleanup zombies too far behind
      if (z.x < car.x - 700) {
        zombies.removeAt(i);
      }
    }

    // 5. Update Bullets & Collisions
    for (int i = bullets.length - 1; i >= 0; i--) {
      final b = bullets[i];
      b.x += b.vx * dt;
      b.y += b.vy * dt;

      if (b.x < car.x - 650 || b.x > car.x + 500) {
        b.isAlive = false;
        bullets.removeAt(i);
        continue;
      }

      // Bullet hit test against zombies
      for (final z in zombies) {
        if (z.health <= 0) continue;
        if (b.bounds.overlaps(z.bounds)) {
          b.isAlive = false;
          z.health -= b.damage;
          z.hitTimer = 0.15;

          // Blood / Spark Particles
          for (int p = 0; i < 3; p++) {
            particles.add(CarZombieParticle(
              x: z.x + z.width / 2,
              y: z.y + z.height / 2,
              vx: (b.vx * 0.1) + (_random.nextDouble() - 0.5) * 80,
              vy: (_random.nextDouble() - 0.5) * 80,
              color: const Color(0xFFEF4444),
              size: 4.0,
              life: 0.3,
            ));
          }

          if (z.health <= 0) {
            zombiesDefeated++;
            score += z.type == CarZombieEnemyType.large ? 150 : 50;
            ZombieProgressController.instance.addZombiesDefeated(1);
            if (_random.nextDouble() < 0.25) {
              sessionCoins += 2;
              CharacterProgressController.instance.addCoins(2);
            }
          }
          break;
        }
      }

      if (!b.isAlive) {
        bullets.removeAt(i);
      }
    }

    // 6. Remove dead zombies
    zombies.removeWhere((z) => z.health <= 0);

    // 7. Update Road Obstacles & Car Collision
    for (final obs in obstacles) {
      if (!obs.isDestroyed && obs.bounds.overlaps(car.bounds)) {
        obs.isDestroyed = true;
        _damageCar(15.0);
        // Collision explosion particles
        for (int p = 0; p < 10; p++) {
          particles.add(CarZombieParticle(
            x: obs.x + obs.width / 2,
            y: obs.y + obs.height / 2,
            vx: (_random.nextDouble() - 0.5) * 200,
            vy: -100 - _random.nextDouble() * 150,
            color: const Color(0xFFF59E0B),
            size: 5.0,
            life: 0.5,
          ));
        }
      }
    }

    // 8. Update Collectibles
    for (final col in collectibles) {
      if (!col.isCollected && col.bounds.overlaps(car.bounds)) {
        col.isCollected = true;
        if (col.type == CarZombieCollectibleType.coin) {
          sessionCoins += 5;
          score += 100;
          CharacterProgressController.instance.addCoins(5);
        } else if (col.type == CarZombieCollectibleType.healthKit) {
          car.currentHp = min(car.maxHp, car.currentHp + 25.0);
        } else if (col.type == CarZombieCollectibleType.ammoCrate) {
          reserveAmmo = min(maxReserve, reserveAmmo + 40);
        }
      }
    }

    // 9. Update Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
      if (p.life <= 0) {
        particles.removeAt(i);
      }
    }

    notifyListeners();
  }

  void _damageCar(double amount) {
    car.currentHp -= amount;
    car.damageFlashTimer = 0.25;

    if (car.currentHp <= 0) {
      car.currentHp = 0;
      status = CarZombieGameStatus.gameOver;
      _saveHighScores();
    }
  }

  void _spawnZombieHordeBatch() {
    final double spawnX = car.x - 300 - _random.nextDouble() * 200;
    final double spawnY = roadY - 40 - _random.nextDouble() * 15;

    final roll = _random.nextDouble();
    late CarZombieEnemyType type;
    if (roll < 0.50) {
      type = CarZombieEnemyType.normal;
    } else if (roll < 0.75) {
      type = CarZombieEnemyType.fast;
    } else if (roll < 0.90) {
      type = CarZombieEnemyType.heavy;
    } else {
      type = CarZombieEnemyType.large;
    }

    zombies.add(CarZombieEnemy.create(
      id: 'z_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000)}',
      type: type,
      startX: spawnX,
      startY: spawnY,
    ));
  }

  void _spawnRoadSegmentObjects(double spawnX) {
    // 1. Obstacle
    if (_random.nextDouble() < 0.6) {
      final obsType = CarZombieObstacleType.values[_random.nextInt(CarZombieObstacleType.values.length)];
      obstacles.add(CarZombieObstacle(
        id: 'obs_${DateTime.now().microsecondsSinceEpoch}',
        type: obsType,
        x: spawnX,
        y: roadY - 35,
        width: 60,
        height: 40,
      ));
    }

    // 2. Collectible
    if (_random.nextDouble() < 0.5) {
      final colType = CarZombieCollectibleType.values[_random.nextInt(CarZombieCollectibleType.values.length)];
      collectibles.add(CarZombieCollectible(
        id: 'col_${DateTime.now().microsecondsSinceEpoch}',
        type: colType,
        x: spawnX + 200,
        y: roadY - 50,
      ));
    }
  }
}
