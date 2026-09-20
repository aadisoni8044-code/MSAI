import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_mode_data.dart';
import 'package:enchanted_forest_adventure/models/weapon_data.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';

enum ZombieGameState {
  weaponSelect,
  preparingWave,
  playing,
  paused,
  waveComplete,
  milestone,
  gameOver,
}

class ZombieGameEngine extends ChangeNotifier {
  late ZombieModeData nightWorld;
  late PlayerState player;

  ZombieGameState gameState = ZombieGameState.weaponSelect;
  GameStatus get status {
    if (gameState == ZombieGameState.paused) return GameStatus.paused;
    if (gameState == ZombieGameState.gameOver) return GameStatus.gameOver;
    return GameStatus.playing;
  }

  int currentWave = 1;
  int zombiesRemainingInWave = 0;
  int zombiesKilledInWave = 0;
  int totalZombiesKilledThisRun = 0;

  // Countdown & Prep
  double countdownTimer = 10.0;
  String warningMessage = "10 SECONDS LEFT — FIND A SAFE PLACE!";
  int pendingMilestone = 0; // 50 or 100

  final List<ZombieEntity> activeZombies = [];
  final List<ZombieType> _spawnQueue = [];

  double _spawnTimer = 0.0;
  double damageCooldownTimer = 0.0;

  // Camera & Screen
  double cameraX = 0;
  double cameraY = 0;
  double screenWidth = 390;
  double screenHeight = 844;

  // Camera Shake & Particles
  double cameraShakeTimer = 0;
  double cameraShakeIntensity = 0;
  final List<Particle> particles = [];
  final Random _random = Random();

  // Inputs
  double inputX = 0.0;
  bool keyLeft = false;
  bool keyRight = false;
  bool keyDown = false;
  bool isJumpHeld = false;

  ZombieGameEngine() {
    initNightWorld();
  }

  void updateScreenSize(double w, double h) {
    screenWidth = w;
    screenHeight = h;
  }

  void initNightWorld() {
    nightWorld = ZombieModeData.createNightWorld();
    player = PlayerState(x: nightWorld.playerStartX, y: nightWorld.playerStartY);
    gameState = ZombieGameState.weaponSelect;
    particles.clear();
    activeZombies.clear();

    currentWave = 1;
    totalZombiesKilledThisRun = 0;
    _setupWaveData(currentWave);

    _updateCamera(instant: true);
    notifyListeners();
  }

  void _setupWaveData(int waveNum) {
    currentWave = waveNum;
    zombiesKilledInWave = 0;
    _spawnQueue.clear();
    activeZombies.clear();

    final config = ZombieModeData.getWaveConfig(waveNum);
    zombiesRemainingInWave = config.totalZombies;

    for (int i = 0; i < config.normalCount; i++) {
      _spawnQueue.add(ZombieType.normal);
    }
    for (int i = 0; i < config.fastCount; i++) {
      _spawnQueue.add(ZombieType.fast);
    }
    for (int i = 0; i < config.largeCount; i++) {
      _spawnQueue.add(ZombieType.large);
    }

    _spawnQueue.shuffle(_random);
  }

  void startWeaponSelect() {
    gameState = ZombieGameState.weaponSelect;
    notifyListeners();
  }

  void startPreparationCountdown() {
    gameState = ZombieGameState.preparingWave;
    countdownTimer = 10.0;
    warningMessage = "10 SECONDS LEFT — FIND A SAFE PLACE!";
    notifyListeners();
  }

  void setJoystickInput(double x) {
    inputX = x.clamp(-1.0, 1.0);
  }

  void setKeyLeft(bool pressed) => keyLeft = pressed;
  void setKeyRight(bool pressed) => keyRight = pressed;
  void setKeyDown(bool pressed) => keyDown = pressed;

  void jump() {
    if (gameState != ZombieGameState.playing && gameState != ZombieGameState.preparingWave) return;
    isJumpHeld = true;
    if (player.isGrounded) {
      player.vy = -16.0;
      player.isGrounded = false;
      player.actionState = PlayerActionState.jumping;
      _addDustParticles(player.x + player.width / 2, player.y + player.height, 8);
    }
  }

  void releaseJump() {
    isJumpHeld = false;
    if (player.vy < -6.5) {
      player.vy = -6.5;
    }
  }

  void attack() {
    if (gameState != ZombieGameState.playing && gameState != ZombieGameState.preparingWave) return;
    if (player.attackTimer <= 0) {
      final weaponId = ZombieProgressController.instance.selectedWeapon;
      final weapon = WeaponData.getById(weaponId);

      player.attackTimer = 0.28 / weapon.fireRate;
      player.actionState = PlayerActionState.attacking;
      _triggerCameraShake(0.15, 3.5);
      _checkAttackCollisions(weapon);
    }
  }

  void togglePause() {
    if (gameState == ZombieGameState.playing || gameState == ZombieGameState.preparingWave) {
      gameState = ZombieGameState.paused;
    } else if (gameState == ZombieGameState.paused) {
      gameState = ZombieGameState.playing;
    }
    notifyListeners();
  }

  void tick(double dt) {
    if (gameState == ZombieGameState.paused || gameState == ZombieGameState.gameOver) return;

    final effectiveDt = dt.clamp(0.001, 0.05);

    if (gameState == ZombieGameState.preparingWave) {
      countdownTimer -= effectiveDt;
      if (countdownTimer <= 0) {
        countdownTimer = 0;
        gameState = ZombieGameState.playing;
      } else if (countdownTimer <= 3.0) {
        warningMessage = "GET READY! ZOMBIES INCOMING!";
      } else if (countdownTimer <= 6.0) {
        warningMessage = "HEAD TO THE WATCHTOWER FOR HIGH GROUND!";
      }

      // Allow player movement during countdown
      _updatePlayerMovement(effectiveDt);
      _updateParticles(effectiveDt);
      _updateCamera();
      notifyListeners();
      return;
    }

    if (gameState != ZombieGameState.playing) return;

    _updateSpawning(effectiveDt);
    _updateZombiesAI(effectiveDt);
    _updatePlayerMovement(effectiveDt);
    _checkZombieCollisions();
    _checkCollectibleCollisions();
    _updateParticles(effectiveDt);
    _updateCamera();

    player.animationTimer += effectiveDt;

    // Check wave clear transition
    if (zombiesRemainingInWave <= 0 && activeZombies.isEmpty) {
      _handleWaveCleared();
    }

    notifyListeners();
  }

  void _handleWaveCleared() {
    ZombieProgressController.instance.completeWave(currentWave);
    ZombieProgressController.instance.addZombiesDefeated(zombiesKilledInWave);

    final totalDefeated = ZombieProgressController.instance.totalZombiesDefeated;
    final controller = ZombieProgressController.instance;

    if (totalDefeated >= 100 && !controller.has100MilestoneShown) {
      pendingMilestone = 100;
      controller.setMilestoneShown(100);
      gameState = ZombieGameState.milestone;
    } else if (totalDefeated >= 50 && !controller.has50MilestoneShown) {
      pendingMilestone = 50;
      controller.setMilestoneShown(50);
      gameState = ZombieGameState.milestone;
    } else {
      gameState = ZombieGameState.waveComplete;
    }
  }

  void proceedToNextWave() {
    _setupWaveData(currentWave + 1);
    startWeaponSelect();
  }

  void dismissMilestone() {
    gameState = ZombieGameState.waveComplete;
    notifyListeners();
  }

  void _updateSpawning(double dt) {
    if (_spawnQueue.isEmpty) return;

    _spawnTimer += dt;
    // Spawn gradually every 0.8 seconds (max 15 zombies active concurrently)
    if (_spawnTimer >= 0.8 && activeZombies.length < 15) {
      _spawnTimer = 0;
      final type = _spawnQueue.removeAt(0);

      final spawnOnRight = _random.nextBool();
      double spawnX;
      if (spawnOnRight) {
        spawnX = player.x + screenWidth * 0.6 + _random.nextDouble() * 200;
      } else {
        spawnX = player.x - screenWidth * 0.6 - _random.nextDouble() * 200;
      }

      spawnX = spawnX.clamp(50.0, nightWorld.worldWidth - 100.0);
      const double spawnY = 640.0;

      activeZombies.add(ZombieEntity(
        id: 'z_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000)}',
        zombieType: type,
        x: spawnX,
        y: spawnY,
      ));
    }
  }

  void _updateZombiesAI(double dt) {
    final platformRects = nightWorld.platforms.map((p) => p.bounds).toList();

    for (int i = activeZombies.length - 1; i >= 0; i--) {
      final zombie = activeZombies[i];
      zombie.updateAI(
        targetX: player.x + player.width / 2,
        targetY: player.y + player.height / 2,
        dt: dt,
        platformRects: platformRects,
      );

      if (zombie.state == ZombieState.dead) {
        activeZombies.removeAt(i);
        zombiesRemainingInWave--;
        zombiesKilledInWave++;
        totalZombiesKilledThisRun++;
        player.coins += zombie.zombieType == ZombieType.large ? 10 : 3;
        _addSparkleParticles(zombie.x + zombie.width / 2, zombie.y + zombie.height / 2, const Color(0xFFFF5252));
      }
    }
  }

  void _updatePlayerMovement(double dt) {
    double combinedX = inputX;
    if (keyLeft && !keyRight) combinedX = -1.0;
    if (keyRight && !keyLeft) combinedX = 1.0;

    if (combinedX.abs() > 0.05) {
      player.vx = combinedX * 4.8;
      player.facingRight = combinedX > 0;
      if (player.isGrounded && !player.isAttacking) {
        player.actionState = PlayerActionState.running;
      }
    } else {
      player.vx *= 0.82;
      if (player.vx.abs() < 0.1) player.vx = 0;
      if (player.isGrounded && !player.isAttacking) {
        player.actionState = PlayerActionState.idle;
      }
    }

    if (player.attackTimer > 0) {
      player.attackTimer -= dt;
      if (player.attackTimer <= 0) player.attackTimer = 0;
    }

    if (player.invulnerableTimer > 0) {
      player.invulnerableTimer -= dt;
      if (player.invulnerableTimer <= 0) player.invulnerableTimer = 0;
    }

    if (damageCooldownTimer > 0) {
      damageCooldownTimer -= dt;
    }

    player.vy += 0.60;
    if (player.vy > 14) player.vy = 14;

    if (!player.isGrounded && player.vy > 0 && !player.isAttacking) {
      player.actionState = PlayerActionState.falling;
    }

    player.x += player.vx;
    _resolveHorizontalCollisions();

    player.y += player.vy;
    _resolveVerticalCollisions();

    if (player.x < 0) player.x = 0;
    if (player.x + player.width > nightWorld.worldWidth) {
      player.x = nightWorld.worldWidth - player.width;
    }

    if (player.y > nightWorld.worldHeight + 80) {
      _handlePlayerDeath();
    }
  }

  void _resolveHorizontalCollisions() {
    final playerRect = player.bounds;
    for (final plat in nightWorld.platforms) {
      final platRect = plat.bounds;
      if (playerRect.overlaps(platRect)) {
        if (player.vx > 0) player.x = platRect.left - player.width;
        if (player.vx < 0) player.x = platRect.right;
      }
    }
  }

  void _resolveVerticalCollisions() {
    player.isGrounded = false;
    final playerRect = player.bounds;

    for (final plat in nightWorld.platforms) {
      final platRect = plat.bounds;
      if (playerRect.overlaps(platRect)) {
        if (player.vy > 0 && (playerRect.bottom - player.vy) <= platRect.top + 12) {
          player.y = platRect.top - player.height;
          player.vy = 0;
          player.isGrounded = true;
        } else if (player.vy < 0 && (playerRect.top - player.vy) >= platRect.bottom - 12) {
          player.y = platRect.bottom;
          player.vy = 0;
        }
      }
    }
  }

  void _checkAttackCollisions(WeaponData weapon) {
    // Determine attack reach based on selected weapon range
    final baseBox = player.attackBounds;
    final double extraReach = weapon.range - 220.0;
    final attackBox = Rect.fromLTRB(
      player.facingRight ? baseBox.left : baseBox.left - extraReach,
      baseBox.top,
      player.facingRight ? baseBox.right + extraReach : baseBox.right,
      baseBox.bottom,
    );

    for (final zombie in activeZombies) {
      if (zombie.health > 0 && attackBox.overlaps(zombie.bounds)) {
        final damage = (1 * weapon.damageMultiplier).round();
        zombie.takeDamage(damage > 0 ? damage : 1);
        _addHitParticles(zombie.x + zombie.width / 2, zombie.y + zombie.height / 2, 12);
        _triggerCameraShake(0.2, 5.0);
      }
    }
  }

  void _checkZombieCollisions() {
    if (player.currentHealth <= 0 || player.isInvulnerable || damageCooldownTimer > 0) return;

    final playerRect = player.bounds;
    for (final zombie in activeZombies) {
      if (zombie.health > 0 && playerRect.overlaps(zombie.bounds)) {
        final damage = zombie.damage;
        player.currentHealth -= damage;
        player.invulnerableTimer = 1.0;
        damageCooldownTimer = 1.0;

        player.vy = -6.0;
        player.vx = player.x < zombie.x ? -6.0 : 6.0;
        player.actionState = PlayerActionState.hurt;

        _triggerCameraShake(0.3, 8.0);
        _addHitParticles(player.x + player.width / 2, player.y + player.height / 2, 12);

        if (player.currentHealth <= 0) {
          _handlePlayerDeath();
        }
        break;
      }
    }
  }

  void _checkCollectibleCollisions() {
    final playerRect = player.bounds;

    for (final item in nightWorld.collectibles) {
      if (!item.isCollected && playerRect.overlaps(item.bounds)) {
        item.isCollected = true;
        if (item.type == EntityType.coin) {
          player.coins += 1;
          _addSparkleParticles(item.x + item.width / 2, item.y + item.height / 2, const Color(0xFFFFD166));
        } else if (item.type == EntityType.healthPot) {
          player.currentHealth = (player.currentHealth + 1).clamp(0, player.maxHealth);
          _addSparkleParticles(item.x + item.width / 2, item.y + item.height / 2, const Color(0xFF80FFDB));
        }
      }
    }
  }

  void _handlePlayerDeath() {
    player.currentHealth = 0;
    player.actionState = PlayerActionState.dead;
    gameState = ZombieGameState.gameOver;
  }

  void _updateCamera({bool instant = false}) {
    final targetX = player.x + player.width / 2 - screenWidth / 2;
    final targetY = player.y + player.height / 2 - screenHeight * 0.55;

    final maxCamX = max(0.0, nightWorld.worldWidth - screenWidth);
    final maxCamY = max(0.0, nightWorld.worldHeight - screenHeight);

    final clampedTargetX = targetX.clamp(0.0, maxCamX);
    final clampedTargetY = targetY.clamp(0.0, maxCamY);

    if (instant) {
      cameraX = clampedTargetX;
      cameraY = clampedTargetY;
    } else {
      cameraX += (clampedTargetX - cameraX) * 0.12;
      cameraY += (clampedTargetY - cameraY) * 0.12;
    }

    if (cameraShakeTimer > 0) {
      cameraShakeTimer -= 0.016;
      cameraX += (_random.nextDouble() - 0.5) * cameraShakeIntensity;
      cameraY += (_random.nextDouble() - 0.5) * cameraShakeIntensity;
    }
  }

  void _triggerCameraShake(double duration, double intensity) {
    cameraShakeTimer = duration;
    cameraShakeIntensity = intensity;
  }

  void _updateParticles(double dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].isDead) particles.removeAt(i);
    }
  }

  void _addDustParticles(double x, double y, int count) {
    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 3,
        vy: -_random.nextDouble() * 2,
        size: _random.nextDouble() * 4 + 2,
        color: const Color(0x994A90A4),
        maxLife: 0.4 + _random.nextDouble() * 0.2,
      ));
    }
  }

  void _addHitParticles(double x, double y, int count) {
    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 7,
        vy: (_random.nextDouble() - 0.5) * 7,
        size: _random.nextDouble() * 5 + 3,
        color: const Color(0xFFFF3333),
        maxLife: 0.3 + _random.nextDouble() * 0.2,
      ));
    }
  }

  void _addSparkleParticles(double x, double y, Color color) {
    for (int i = 0; i < 10; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 4,
        vy: -_random.nextDouble() * 4,
        size: _random.nextDouble() * 4 + 2,
        color: color,
        maxLife: 0.5 + _random.nextDouble() * 0.3,
      ));
    }
  }
}
