import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_mode_data.dart';
import 'package:enchanted_forest_adventure/models/weapon_data.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/zombie_audio_controller.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';

enum ZombieGameState {
  weaponSelect,
  preparingWave,
  playing,
  paused,
  waveComplete,
  milestone,
  gameOver,
  completed,
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
  int totalZombiesForWave = 10;
  int zombiesSpawned = 0;
  int zombiesDefeatedInWave = 0;
  int totalZombiesKilledThisRun = 0;

  int get zombiesRemainingInWave => max(0, totalZombiesForWave - zombiesDefeatedInWave);

  // Countdown & Prep
  double countdownTimer = 10.0;
  int _lastCountdownSecond = 10;
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
    zombiesSpawned = 0;
    zombiesDefeatedInWave = 0;
    _spawnQueue.clear();
    activeZombies.clear();

    final config = ZombieModeData.getWaveConfig(waveNum);
    totalZombiesForWave = config.totalZombies;

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
    _lastCountdownSecond = 10;
    warningMessage = "10 SECONDS LEFT — FIND A SAFE PLACE!";
    ZombieAudioController.instance.playCountdownBeep(10);
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

      ZombieAudioController.instance.playPlayerAttack(isHeavy: weaponId == 'ak47');
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

  bool _isPlayerOnWatchtower() {
    for (final towerRect in nightWorld.watchtowers) {
      if (towerRect.contains(Offset(player.x + player.width / 2, player.y + player.height))) {
        return true;
      }
    }
    return false;
  }

  void tick(double dt) {
    if (gameState == ZombieGameState.paused ||
        gameState == ZombieGameState.gameOver ||
        gameState == ZombieGameState.completed ||
        gameState == ZombieGameState.waveComplete ||
        gameState == ZombieGameState.weaponSelect ||
        gameState == ZombieGameState.milestone) {
      return;
    }

    final effectiveDt = dt.clamp(0.001, 0.05);

    if (gameState == ZombieGameState.preparingWave) {
      countdownTimer -= effectiveDt;
      final currentSec = countdownTimer.ceil();

      if (currentSec != _lastCountdownSecond && currentSec > 0) {
        _lastCountdownSecond = currentSec;
        ZombieAudioController.instance.playCountdownBeep(currentSec);
      }

      if (countdownTimer <= 0) {
        countdownTimer = 0;
        gameState = ZombieGameState.playing;
        ZombieAudioController.instance.playWaveWarning();
        ZombieAudioController.instance.playZombieScream();
      } else if (countdownTimer <= 3.0) {
        warningMessage = "GET READY! ZOMBIES INCOMING!";
      } else if (countdownTimer <= 6.0) {
        warningMessage = "HEAD TO THE WATCHTOWER FOR HIGH GROUND!";
      }

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

    final isOnTower = _isPlayerOnWatchtower();
    ZombieAudioController.instance.updateHordeIntensity(
      nearbyZombieCount: activeZombies.length,
      isPlayerOnTower: isOnTower,
    );

    // Periodic ambient chase sounds
    if (activeZombies.isNotEmpty) {
      double minZombieDist = 9999.0;
      for (final z in activeZombies) {
        final dist = (z.x - player.x).abs();
        if (dist < minZombieDist) minZombieDist = dist;
      }
      ZombieAudioController.instance.playChaseAmbience(activeZombies.length, minDistance: minZombieDist);
    }

    // Check wave clear transition: All required wave zombies spawned AND all defeated
    if (zombiesSpawned >= totalZombiesForWave && activeZombies.isEmpty && zombiesDefeatedInWave >= totalZombiesForWave) {
      _handleWaveCleared();
    }

    notifyListeners();
  }

  void _handleWaveCleared() {
    ZombieProgressController.instance.completeWave(currentWave);
    ZombieProgressController.instance.addZombiesDefeated(zombiesDefeatedInWave);

    final totalDefeated = ZombieProgressController.instance.totalZombiesDefeated;
    final controller = ZombieProgressController.instance;

    if (currentWave >= 10) {
      // Wave 10 completed - Final Victory state
      gameState = ZombieGameState.completed;
      return;
    }

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
    if (currentWave >= 10) {
      gameState = ZombieGameState.completed;
      notifyListeners();
      return;
    }
    _setupWaveData(currentWave + 1);
    startWeaponSelect();
  }

  void dismissMilestone() {
    gameState = ZombieGameState.waveComplete;
    notifyListeners();
  }

  void _updateSpawning(double dt) {
    if (gameState != ZombieGameState.playing) return;
    if (_spawnQueue.isEmpty || zombiesSpawned >= totalZombiesForWave) return;

    _spawnTimer += dt;
    // Spawn gradually every 0.8 seconds (max 15 zombies active concurrently)
    if (_spawnTimer >= 0.8 && activeZombies.length < 15 && zombiesSpawned < totalZombiesForWave) {
      _spawnTimer = 0;
      final type = _spawnQueue.removeAt(0);
      zombiesSpawned++;

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

      final dist = (spawnX - player.x).abs();
      ZombieAudioController.instance.playSpatialGrowl(distance: dist, isLarge: type == ZombieType.large);
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

      final dist = (zombie.x - player.x).abs();

      if (zombie.vx.abs() > 0.5 && zombie.isGrounded) {
        ZombieAudioController.instance.playZombieFootstep(
          isLarge: zombie.zombieType == ZombieType.large,
          distance: dist,
        );
      }

      if (zombie.state == ZombieState.dead) {
        activeZombies.removeAt(i);
        zombiesDefeatedInWave++;
        totalZombiesKilledThisRun++;
        player.coins += zombie.zombieType == ZombieType.large ? 10 : 3;

        ZombieAudioController.instance.playZombieDeath(
          isLarge: zombie.zombieType == ZombieType.large,
          distance: dist,
        );
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

        for (final towerRect in nightWorld.watchtowers) {
          if (towerRect.contains(Offset(player.x + player.width / 2, player.y + player.height))) {
            ZombieAudioController.instance.playTowerStep();
            break;
          }
        }
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

        final isHeavy = weapon.id == 'ak47' || damage > 1;
        ZombieAudioController.instance.playHitImpact(isHeavy: isHeavy);
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

        final dist = (zombie.x - player.x).abs();
        ZombieAudioController.instance.playZombieAttack(
          isLarge: zombie.zombieType == ZombieType.large,
          distance: dist,
        );
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
