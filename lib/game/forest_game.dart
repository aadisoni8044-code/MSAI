import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import 'checkpoint.dart';
import 'collectible.dart';
import 'enemy.dart';
import 'exit_portal.dart';
import 'parallax_bg.dart';
import 'particles.dart';
import 'platform.dart';
import 'player.dart';

enum GameState { start, playing, paused, gameOver, levelComplete }

class ForestGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late PlayerCharacter player;
  late CheckpointBanner checkpoint;
  late ExitPortal exitPortal;

  final List<ForestPlatform> platforms = [];
  final List<GlowingCrystal> crystals = [];
  final List<ForestEnemy> enemies = [];

  final Vector2 worldBounds = Vector2(3200, 600);
  Vector2 activeCheckpointPosition = Vector2(100, 420);

  int collectedCrystals = 0;
  int totalCrystals = 0;
  GameState gameState = GameState.start;

  double screenShakeTimer = 0.0;
  double screenShakeIntensity = 0.0;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport.size = Vector2(800, 450);
  }

  void startGame() {
    removeAll(children);
    platforms.clear();
    crystals.clear();
    enemies.clear();

    collectedCrystals = 0;
    activeCheckpointPosition = Vector2(100, 420);
    gameState = GameState.playing;

    // Background & Parallax
    add(ParallaxForestBackground(worldBounds: worldBounds));
    add(FireflyParticleSystem(count: 60, bounds: worldBounds));

    // Player
    player = PlayerCharacter(position: activeCheckpointPosition.clone());
    add(player);

    // Build Level Components
    _buildLevelLayout();

    // Camera follow player with bounds
    camera.follow(player);
    camera.setBounds(
      Rectangle.fromRect(Rect.fromLTWH(0, 0, worldBounds.x, worldBounds.y)),
    );

    AudioManager().playBgm();
  }

  void triggerScreenShake({double duration = 0.2, double intensity = 8.0}) {
    screenShakeTimer = duration;
    screenShakeIntensity = intensity;
  }

  void _buildLevelLayout() {
    // 1. Main Ground Platforms with small gaps
    _addPlatform(0, 480, 700, 120); // Starting ground
    _addPlatform(780, 480, 800, 120); // Mid section ground
    _addPlatform(1650, 480, 750, 120); // Post-checkpoint ground
    _addPlatform(2480, 480, 720, 120); // Final exit ground

    // 2. Elevated Platforms & Stepping Stones
    _addPlatform(300, 370, 140, 24);
    _addPlatform(500, 290, 150, 24);

    _addPlatform(720, 390, 100, 24); // Gap bridge
    _addPlatform(950, 330, 160, 24);
    _addPlatform(1200, 260, 180, 24);
    _addPlatform(1420, 360, 140, 24);

    // 3. Hidden Area Platforms (High Canopy Secret Vault)
    _addPlatform(1050, 150, 220, 24, isHiddenArea: true);
    _addPlatform(1320, 120, 180, 24, isHiddenArea: true);

    // 4. Post Checkpoint Elevated Stepping Stones
    _addPlatform(1800, 360, 130, 24);
    _addPlatform(2000, 280, 140, 24);
    _addPlatform(2200, 370, 130, 24);

    _addPlatform(2600, 360, 160, 24);
    _addPlatform(2820, 270, 180, 24);

    // Checkpoint
    checkpoint = CheckpointBanner(position: Vector2(1680, 416));
    add(checkpoint);

    // Exit Portal
    exitPortal = ExitPortal(position: Vector2(3050, 390));
    add(exitPortal);

    // Collectibles (Glowing Crystals)
    _addCrystal(330, 330);
    _addCrystal(530, 250);
    _addCrystal(980, 290);
    _addCrystal(1230, 220);
    _addCrystal(1450, 320);

    // Hidden area rich rewards
    _addCrystal(1080, 110, value: 2);
    _addCrystal(1140, 110, value: 2);
    _addCrystal(1360, 80, value: 3);

    _addCrystal(1830, 320);
    _addCrystal(2030, 240);
    _addCrystal(2230, 330);
    _addCrystal(2630, 320);
    _addCrystal(2860, 230);

    totalCrystals = crystals.length;

    // Enemies
    _addEnemy(400, 448, 200, 600);
    _addEnemy(900, 448, 800, 1150);
    _addEnemy(1750, 448, 1680, 2100);
    _addEnemy(2550, 448, 2500, 2900);
  }

  void _addPlatform(double x, double y, double w, double h, {bool isHiddenArea = false}) {
    final plat = ForestPlatform(
      position: Vector2(x, y),
      size: Vector2(w, h),
      isHiddenArea: isHiddenArea,
    );
    platforms.add(plat);
    add(plat);
  }

  void _addCrystal(double x, double y, {int value = 1}) {
    final crystal = GlowingCrystal(position: Vector2(x, y), value: value);
    crystals.add(crystal);
    add(crystal);
  }

  void _addEnemy(double x, double y, double left, double right) {
    final enemy = ForestEnemy(
      position: Vector2(x, y),
      leftBound: left,
      rightBound: right,
    );
    enemies.add(enemy);
    add(enemy);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState != GameState.playing) return;

    // Screen shake update
    if (screenShakeTimer > 0) {
      screenShakeTimer -= dt;
      final dx = (_random.nextDouble() - 0.5) * screenShakeIntensity;
      final dy = (_random.nextDouble() - 0.5) * screenShakeIntensity;
      camera.viewfinder.position += Vector2(dx, dy);
    }

    _handlePlayerPlatformCollisions();
    _handleCollectibleCollisions();
    _handleEnemyCollisions();
    _handleCheckpointAndExit();

    // Pitfall Death
    if (player.position.y > worldBounds.y + 100) {
      player.takeDamage();
      triggerScreenShake();
      AudioManager().playDamage();

      if (player.health <= 0) {
        gameState = GameState.gameOver;
        overlays.add('GameOver');
      } else {
        player.respawnAt(activeCheckpointPosition);
      }
    }
  }

  void _handlePlayerPlatformCollisions() {
    player.isOnGround = false;
    final playerRect = player.toRect();

    for (var plat in platforms) {
      final platRect = plat.toRect();

      if (playerRect.overlaps(platRect)) {
        // Checking if landing from above
        final prevBottom = player.position.y + player.size.y - player.velocity.y * 0.016;
        if (prevBottom <= plat.position.y + 12 && player.velocity.y >= 0) {
          player.position.y = plat.position.y - player.size.y;
          player.velocity.y = 0;
          player.isOnGround = true;
        }
      }
    }
  }

  void _handleCollectibleCollisions() {
    final playerRect = player.toRect();

    for (var crystal in crystals) {
      if (!crystal.isCollected && playerRect.overlaps(crystal.toRect())) {
        crystal.isCollected = true;
        collectedCrystals += crystal.value;
        add(CollectibleBurstEffect(center: crystal.position + crystal.size / 2));
        AudioManager().playCollect();
      }
    }
  }

  void _handleEnemyCollisions() {
    final playerRect = player.toRect();
    final attackRect = player.attackHitbox;

    for (var enemy in enemies) {
      if (enemy.isDefeated) continue;
      final enemyRect = enemy.toRect();

      // Attack enemy
      if (player.isAttacking && attackRect.overlaps(enemyRect)) {
        enemy.isDefeated = true;
        add(CollectibleBurstEffect(center: enemy.position + enemy.size / 2));
        triggerScreenShake(duration: 0.15, intensity: 6.0);
        AudioManager().playAttack();
        continue;
      }

      // Enemy touches player
      if (playerRect.overlaps(enemyRect)) {
        player.takeDamage();
        triggerScreenShake(duration: 0.25, intensity: 10.0);
        AudioManager().playDamage();

        if (player.health <= 0) {
          gameState = GameState.gameOver;
          overlays.add('GameOver');
        }
      }
    }
  }

  void _handleCheckpointAndExit() {
    final playerRect = player.toRect();

    // Checkpoint Activation
    if (!checkpoint.isActivated && playerRect.overlaps(checkpoint.toRect())) {
      checkpoint.activate();
      activeCheckpointPosition = checkpoint.position.clone();
      activeCheckpointPosition.y = 420; // safe ground level
      AudioManager().playCheckpoint();
    }

    // Exit Portal Completion
    if (playerRect.overlaps(exitPortal.toRect())) {
      gameState = GameState.levelComplete;
      AudioManager().playLevelComplete();
      overlays.add('LevelComplete');
    }
  }

  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      overlays.add('Pause');
    }
  }

  void resumeGame() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
      overlays.remove('Pause');
    }
  }
}
