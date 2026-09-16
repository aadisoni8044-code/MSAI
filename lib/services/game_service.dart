import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/level_objects.dart';
import '../game/level_data.dart';
import '../game/camera.dart';
import '../game/collision_system.dart';
import '../game/visual_effects.dart';
import 'audio_service.dart';

enum GameState { startMenu, playing, paused, gameOver, levelComplete }

class GameService extends ChangeNotifier {
  late LevelData levelData;
  late Player player;
  late Camera2D camera;
  late VisualEffects visualEffects;
  final AudioService _audio = AudioService();

  GameState state = GameState.startMenu;
  int score = 0;
  int totalCrystals = 0;
  Offset currentCheckpointPos = Offset.zero;

  // Touch control states
  bool moveLeftInput = false;
  bool moveRightInput = false;

  void initializeGame(Size viewportSize) {
    levelData = LevelData.level1();
    totalCrystals = levelData.collectibles.length;
    currentCheckpointPos = levelData.playerSpawn;

    player = Player(position: levelData.playerSpawn);
    camera = Camera2D(
      viewportSize: viewportSize,
      worldWidth: levelData.worldWidth,
      worldHeight: levelData.worldHeight,
    );
    visualEffects = VisualEffects(viewportSize);

    score = 0;
    state = GameState.startMenu;
    notifyListeners();
  }

  void startGame() {
    state = GameState.playing;
    _audio.playBGM('audio/forest_theme.mp3');
    notifyListeners();
  }

  void pauseGame() {
    if (state == GameState.playing) {
      state = GameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (state == GameState.paused) {
      state = GameState.playing;
      notifyListeners();
    }
  }

  void restartLevel() {
    levelData = LevelData.level1();
    player = Player(position: levelData.playerSpawn);
    currentCheckpointPos = levelData.playerSpawn;
    score = 0;
    state = GameState.playing;
    notifyListeners();
  }

  void respawnPlayer() {
    player.respawnAtCheckpoint(currentCheckpointPos);
    state = GameState.playing;
    notifyListeners();
  }

  // Input actions
  void setMoveLeft(bool active) {
    moveLeftInput = active;
  }

  void setMoveRight(bool active) {
    moveRightInput = active;
  }

  void handleJump() {
    if (state != GameState.playing) return;
    if (player.jump()) {
      _audio.playJump();
    }
  }

  void handleAttack() {
    if (state != GameState.playing) return;
    if (player.attack()) {
      _audio.playAttack();
    }
  }

  void update(double dt, Size viewportSize) {
    if (state != GameState.playing) return;

    // Process continuous movement inputs
    if (moveLeftInput) {
      player.moveLeft();
    } else if (moveRightInput) {
      player.moveRight();
    } else {
      player.stopHorizontal();
    }

    // Update Player physics & timers
    player.update(dt);

    // Platform collisions
    CollisionSystem.handlePlayerPlatforms(player, levelData.platforms, dt);

    // Fall out of level bounds checking
    if (player.position.dy > levelData.worldHeight + 100) {
      player.takeDamage(1, Offset.zero);
      if (player.state == PlayerState.dead) {
        state = GameState.gameOver;
        _audio.playHurt();
      } else {
        player.respawnAtCheckpoint(currentCheckpointPos);
      }
    }

    // Update Enemies
    for (final enemy in levelData.enemies) {
      enemy.update(dt);
    }

    // Attack collisions against enemies
    CollisionSystem.handleAttacks(player, levelData.enemies, (enemy) {
      if (enemy.takeDamage(1)) {
        score += 50;
        visualEffects.triggerShake(duration: 0.15, intensity: 4.0);
        _audio.playHurt();
      }
    });

    // Player touch collision with enemies
    CollisionSystem.handlePlayerEnemyCollisions(player, levelData.enemies, (enemy) {
      final double knockbackDx = player.position.dx < enemy.position.dx ? -220.0 : 220.0;
      if (player.takeDamage(1, Offset(knockbackDx, -260.0))) {
        visualEffects.triggerShake(duration: 0.3, intensity: 8.0);
        _audio.playHurt();
        if (player.state == PlayerState.dead) {
          state = GameState.gameOver;
        }
      }
    });

    // Collectibles collision
    CollisionSystem.handleCollectibles(player, levelData.collectibles, () {
      score += 100;
      _audio.playCollect();
    });

    // Checkpoint activation
    CollisionSystem.handleCheckpoints(player, levelData.checkpoints, (cp) {
      currentCheckpointPos = cp.position;
      _audio.playCheckpoint();
      visualEffects.triggerShake(duration: 0.1, intensity: 3.0);
    });

    // Exit Portal collision
    if (CollisionSystem.handleExitPortal(player, levelData.exitPortal)) {
      state = GameState.levelComplete;
      _audio.playLevelComplete();
    }

    // Camera follow player
    camera.follow(player.position, dt);

    // Visual effects update
    visualEffects.update(dt, viewportSize);

    notifyListeners();
  }
}
