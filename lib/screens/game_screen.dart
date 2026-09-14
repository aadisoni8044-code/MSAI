import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../services/game_service.dart';
import '../widgets/world_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/enemy_widget.dart';
import '../widgets/game_hud.dart';
import '../widgets/mobile_controls.dart';
import 'pause_screen.dart';
import 'game_over_screen.dart';
import 'level_complete_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final gameService = GameService();
  late Ticker _ticker;
  Duration _lastFrameTime = Duration.zero;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      if (_lastFrameTime == Duration.zero) {
        _lastFrameTime = elapsed;
        return;
      }
      double dt = (elapsed - _lastFrameTime).inMicroseconds / 1000000.0;
      _lastFrameTime = elapsed;

      // Clamp max dt step to avoid instability
      dt = dt.clamp(0.001, 0.05);

      final size = MediaQuery.of(context).size;
      gameService.update(dt, size);
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    bool isDown = event is KeyDownEvent || event is KeyRepeatEvent;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
      gameService.keyLeft = isDown;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
      gameService.keyRight = isDown;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (isDown && !event.synthesized) gameService.triggerJump();
    } else if (event.logicalKey == LogicalKeyboardKey.keyJ) {
      if (isDown && !event.synthesized) gameService.triggerAttack();
    } else if (event.logicalKey == LogicalKeyboardKey.keyK) {
      if (isDown && !event.synthesized) gameService.triggerDash();
    } else if (event.logicalKey == LogicalKeyboardKey.escape && isDown && !event.synthesized) {
      setState(() {
        gameService.isPaused = !gameService.isPaused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030D18),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: AnimatedBuilder(
          animation: gameService,
          builder: (context, child) {
            return Stack(
              children: [
                // 1. World & Parallax Background
                WorldWidget(gameService: gameService),

                // 2. Enemies
                EnemyWidget(gameService: gameService),

                // 3. Player Character
                PlayerWidget(gameService: gameService),

                // 4. Gameplay HUD
                GameHudWidget(
                  gameService: gameService,
                  onPausePressed: () {
                    setState(() {
                      gameService.isPaused = true;
                    });
                  },
                ),

                // 5. Mobile Controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MobileControlsWidget(gameService: gameService),
                ),

                // 6. Pause Overlay
                if (gameService.isPaused)
                  PauseScreen(
                    gameService: gameService,
                    onResume: () {
                      setState(() {
                        gameService.isPaused = false;
                      });
                    },
                    onRestart: () {
                      gameService.loadLevel(gameService.progress.currentLevelId);
                    },
                  ),

                // 7. Game Over Overlay
                if (gameService.isGameOver)
                  GameOverScreen(
                    gameService: gameService,
                    onRetry: () {
                      gameService.respawnAtCheckpoint();
                    },
                  ),

                // 8. Level Complete Overlay
                if (gameService.isLevelComplete)
                  LevelCompleteScreen(gameService: gameService),
              ],
            );
          },
        ),
      ),
    );
  }
}
