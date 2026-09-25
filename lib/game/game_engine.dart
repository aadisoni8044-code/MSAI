import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';

enum GameStatus {
  playing,
  paused,
  gameOver,
  victory,
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double life;
  double maxLife;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.maxLife,
  }) : life = maxLife;

  bool get isDead => life <= 0;

  void update(double dt) {
    x += vx * dt * 60;
    y += vy * dt * 60;
    life -= dt;
  }
}

class GameEngine extends ChangeNotifier {
  int currentLevelNumber = 1;
  late LevelData levelData;
  late PlayerState player;

  GameStatus status = GameStatus.playing;

  // Physics constants
  static const double gravity = 0.60;
  static const double moveSpeed = 4.8;
  static const double jumpForce = -16.0;
  static const double minJumpCutoff = -6.5;
  static const double standardFriction = 0.82;
  static const double slipperyFriction = 0.96;

  // Checkpoint & Spawn
  double spawnX = 100;
  double spawnY = 500;
  String? activeCheckpointId;

  // Camera
  double cameraX = 0;
  double cameraY = 0;
  double screenWidth = 390;
  double screenHeight = 844;

  // Camera Shake
  double cameraShakeTimer = 0;
  double cameraShakeIntensity = 0;

  // Visual Particles
  final List<Particle> particles = [];
  final Random _random = Random();

  // Inputs
  double inputX = 0.0; // -1.0 to 1.0 (-1 left, +1 right from joystick)
  bool keyLeft = false;
  bool keyRight = false;
  bool keyDown = false;
  bool isJumpHeld = false;

  GameEngine({int initialLevel = 1}) {
    currentLevelNumber = initialLevel;
    initLevel(initialLevel);
  }

  void updateScreenSize(double w, double h) {
    screenWidth = w;
    screenHeight = h;
  }

  void initLevel([int? levelNum]) {
    if (levelNum != null) {
      currentLevelNumber = levelNum;
    }
    levelData = LevelData.createLevel(currentLevelNumber);
    spawnX = levelData.playerStartX;
    spawnY = levelData.playerStartY;
    player = PlayerState(x: spawnX, y: spawnY);
    status = GameStatus.playing;
    particles.clear();
    activeCheckpointId = null;
    _updateCamera(instant: true);
    notifyListeners();
  }

  void restartFromCheckpoint() {
    player.reset(spawnX, spawnY);
    status = GameStatus.playing;
    notifyListeners();
  }

  void setJoystickInput(double x) {
    inputX = x.clamp(-1.0, 1.0);
  }

  void setKeyLeft(bool pressed) {
    keyLeft = pressed;
  }

  void setKeyRight(bool pressed) {
    keyRight = pressed;
  }

  void setKeyDown(bool pressed) {
    keyDown = pressed;
  }

  void jump() {
    if (status != GameStatus.playing) return;
    isJumpHeld = true;
    if (player.isGrounded) {
      player.vy = jumpForce;
      player.isGrounded = false;
      player.actionState = PlayerActionState.jumping;

      // Dust particles on jump
      _addDustParticles(player.x + player.width / 2, player.y + player.height, 8);
    }
  }

  void releaseJump() {
    isJumpHeld = false;
    if (player.vy < minJumpCutoff) {
      player.vy = minJumpCutoff;
    }
  }

  void attack() {
    if (status != GameStatus.playing) return;
    if (player.attackTimer <= 0) {
      player.attackTimer = 0.28; // attack duration in seconds
      player.actionState = PlayerActionState.attacking;
      _triggerCameraShake(0.15, 3.0);
      _checkAttackCollisions();
    }
  }

  void togglePause() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
    } else if (status == GameStatus.paused) {
      status = GameStatus.playing;
    }
    notifyListeners();
  }

  void tick(double dt) {
    if (status != GameStatus.playing) return;

    // Limit dt to avoid delta jumps
    final effectiveDt = dt.clamp(0.001, 0.05);

    _updateEntities(effectiveDt);
    _updatePlayerMovement(effectiveDt);
    _updateParticles(effectiveDt);
    _checkCollisions();
    _updateCamera();

    player.animationTimer += effectiveDt;

    notifyListeners();
  }

  bool _isPlayerOnSlipperyPlatform() {
    final footRect = Rect.fromLTWH(player.x + 4, player.y + player.height - 2, player.width - 8, 6);
    for (final plat in levelData.platforms) {
      if (plat.type == EntityType.slipperyPlatform && footRect.overlaps(plat.bounds)) {
        return true;
      }
    }
    return false;
  }

  void _updatePlayerMovement(double dt) {
    final currentFriction = _isPlayerOnSlipperyPlatform() ? slipperyFriction : standardFriction;

    // Combine Joystick Input with Keyboard Input
    double combinedX = inputX;
    if (keyLeft && !keyRight) {
      combinedX = -1.0;
    } else if (keyRight && !keyLeft) {
      combinedX = 1.0;
    }

    // Horizontal Movement
    if (combinedX.abs() > 0.05) {
      player.vx = combinedX * moveSpeed;
      player.facingRight = combinedX > 0;
      if (player.isGrounded && !player.isAttacking) {
        player.actionState = PlayerActionState.running;
      }
    } else {
      player.vx *= currentFriction;
      if (player.vx.abs() < 0.1) player.vx = 0;
      if (player.isGrounded && !player.isAttacking) {
        player.actionState = PlayerActionState.idle;
      }
    }

    // Timers
    if (player.attackTimer > 0) {
      player.attackTimer -= dt;
      if (player.attackTimer <= 0) {
        player.attackTimer = 0;
      }
    }

    if (player.invulnerableTimer > 0) {
      player.invulnerableTimer -= dt;
      if (player.invulnerableTimer <= 0) {
        player.invulnerableTimer = 0;
      }
    }

    // Apply Gravity
    player.vy += gravity;
    if (player.vy > 14) player.vy = 14; // terminal velocity

    if (!player.isGrounded && player.vy > 0 && !player.isAttacking) {
      player.actionState = PlayerActionState.falling;
    }

    // Move X & Y
    player.x += player.vx;
    _resolveHorizontalCollisions();

    player.y += player.vy;
    _resolveVerticalCollisions();

    // Screen World Bound X
    if (player.x < 0) player.x = 0;
    if (player.x + player.width > levelData.worldWidth) {
      player.x = levelData.worldWidth - player.width;
    }

    // Pit Fall Death Check
    if (player.y > levelData.worldHeight + 80) {
      _handlePlayerDeath();
    }
  }

  void _resolveHorizontalCollisions() {
    final playerRect = player.bounds;
    for (final plat in levelData.platforms) {
      final platRect = plat.bounds;
      if (playerRect.overlaps(platRect)) {
        if (player.vx > 0) {
          player.x = platRect.left - player.width;
        } else if (player.vx < 0) {
          player.x = platRect.right;
        }
      }
    }
  }

  void _resolveVerticalCollisions() {
    player.isGrounded = false;
    final playerRect = player.bounds;

    for (final plat in levelData.platforms) {
      final platRect = plat.bounds;
      if (playerRect.overlaps(platRect)) {
        // Falling down onto platform
        if (player.vy > 0 && (playerRect.bottom - player.vy) <= platRect.top + 12) {
          player.y = platRect.top - player.height;
          player.vy = 0;
          player.isGrounded = true;

          // If on moving platform, carry player along
          if (plat.type == EntityType.movingPlatform) {
            player.x += plat.vx;
            player.y += plat.vy;
          }
        }
        // Jumping up into platform bottom
        else if (player.vy < 0 && (playerRect.top - player.vy) >= platRect.bottom - 12) {
          player.y = platRect.bottom;
          player.vy = 0;
        }
      }
    }
  }

  void _updateEntities(double dt) {
    for (final enemy in levelData.enemies) {
      if (enemy.health > 0) {
        enemy.update(dt);
      }
    }
    for (final plat in levelData.platforms) {
      if (plat.type == EntityType.movingPlatform) {
        plat.update(dt);
      }
    }
  }

  void _checkAttackCollisions() {
    final attackBox = player.attackBounds;

    for (final enemy in levelData.enemies) {
      if (enemy.health > 0 && attackBox.overlaps(enemy.bounds)) {
        enemy.health -= 1;
        _addHitParticles(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2, 12);
        _triggerCameraShake(0.2, 5.0);

        if (enemy.health <= 0) {
          // Defeated enemy particle explosion
          _addDefeatParticles(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2);
          player.coins += 5; // Bonus coins on defeat
          CharacterProgressController.instance.addCoins(5);
        }
      }
    }
  }

  void _checkCollisions() {
    final playerRect = player.bounds;

    // Enemy & Hazard collisions
    if (!player.isInvulnerable && player.currentHealth > 0) {
      // Enemy hit
      for (final enemy in levelData.enemies) {
        if (enemy.health > 0 && playerRect.overlaps(enemy.bounds)) {
          _takeDamage(1, knockbackRight: player.x < enemy.x);
          break;
        }
      }

      // Hazard hit (spikes, lava, poison, lightning)
      for (final hazard in levelData.hazards) {
        if (playerRect.overlaps(hazard.bounds)) {
          int damage = 1;
          if (hazard.type == EntityType.hazardLava) damage = 2;
          _takeDamage(damage, knockbackRight: player.x < hazard.x);
          break;
        }
      }
    }

    // Collectibles
    for (final item in levelData.collectibles) {
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

    // Checkpoints
    for (final cp in levelData.checkpoints) {
      if (!cp.isActivated && playerRect.overlaps(cp.bounds)) {
        cp.isActivated = true;
        activeCheckpointId = cp.id;
        spawnX = cp.x;
        spawnY = cp.y;
        _addSparkleParticles(cp.x + cp.width / 2, cp.y + cp.height / 2, const Color(0xFF72EFDD));
      }
    }

    // Goal Portal
    if (playerRect.overlaps(levelData.goalPortal.bounds)) {
      status = GameStatus.victory;
      _addSparkleParticles(levelData.goalPortal.x + 30, levelData.goalPortal.y + 45, const Color(0xFFC77DFF));
    }
  }

  void _takeDamage(int damage, {required bool knockbackRight}) {
    player.currentHealth -= damage;
    player.invulnerableTimer = 1.2;
    player.vy = -6.0;
    player.vx = knockbackRight ? -5.0 : 5.0;
    player.actionState = PlayerActionState.hurt;
    _triggerCameraShake(0.3, 8.0);
    _addHitParticles(player.x + player.width / 2, player.y + player.height / 2, 10);

    if (player.currentHealth <= 0) {
      _handlePlayerDeath();
    }
  }

  void _handlePlayerDeath() {
    player.currentHealth = 0;
    player.actionState = PlayerActionState.dead;
    status = GameStatus.gameOver;
  }

  void _updateCamera({bool instant = false}) {
    final targetX = player.x + player.width / 2 - screenWidth / 2;
    final targetY = player.y + player.height / 2 - screenHeight * 0.55;

    final maxCamX = max(0.0, levelData.worldWidth - screenWidth);
    final maxCamY = max(0.0, levelData.worldHeight - screenHeight);

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
      final shakeOffsetX = (_random.nextDouble() - 0.5) * cameraShakeIntensity;
      final shakeOffsetY = (_random.nextDouble() - 0.5) * cameraShakeIntensity;
      cameraX += shakeOffsetX;
      cameraY += shakeOffsetY;
    }
  }

  void _triggerCameraShake(double duration, double intensity) {
    cameraShakeTimer = duration;
    cameraShakeIntensity = intensity;
  }

  void _updateParticles(double dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].isDead) {
        particles.removeAt(i);
      }
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
        color: const Color(0xFFFF4D6D),
        maxLife: 0.3 + _random.nextDouble() * 0.2,
      ));
    }
  }

  void _addDefeatParticles(double x, double y) {
    for (int i = 0; i < 18; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 8,
        vy: (_random.nextDouble() - 0.5) * 8,
        size: _random.nextDouble() * 6 + 3,
        color: const Color(0xFF80FFDB),
        maxLife: 0.5 + _random.nextDouble() * 0.3,
      ));
    }
  }

  void _addSparkleParticles(double x, double y, Color color) {
    for (int i = 0; i < 12; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 4,
        vy: -_random.nextDouble() * 4,
        size: _random.nextDouble() * 4 + 2,
        color: color,
        maxLife: 0.6 + _random.nextDouble() * 0.3,
      ));
    }
  }
}
