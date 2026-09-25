import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';
import 'package:enchanted_forest_adventure/core/level_progress_controller.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';
import 'package:enchanted_forest_adventure/rendering/forest_painter.dart';
import 'package:enchanted_forest_adventure/rendering/character_painter.dart';
import 'package:enchanted_forest_adventure/rendering/enemy_painter.dart';
import 'package:enchanted_forest_adventure/rendering/particle_painter.dart';
import 'package:enchanted_forest_adventure/widgets/game_hud.dart';
import 'package:enchanted_forest_adventure/widgets/virtual_joystick.dart';
import 'package:enchanted_forest_adventure/widgets/action_buttons.dart';
import 'package:enchanted_forest_adventure/ui/pause_overlay.dart';
import 'package:enchanted_forest_adventure/ui/game_over_overlay.dart';
import 'package:enchanted_forest_adventure/ui/victory_overlay.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';
import 'package:enchanted_forest_adventure/ui/level_select_screen.dart';

class GameScreen extends StatefulWidget {
  final int initialLevel;

  const GameScreen({
    super.key,
    this.initialLevel = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  late Ticker _ticker;
  late final FocusNode _focusNode;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;
  bool _hasSavedProgress = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _engine = GameEngine(initialLevel: widget.initialLevel);
    _ticker = createTicker(_onTick)..start();
    SettingsController.instance.applyCurrentOrientation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    _time += dt;

    _engine.tick(dt);

    if (_engine.status == GameStatus.victory && !_hasSavedProgress) {
      _hasSavedProgress = true;
      LevelProgressController.instance.completeLevel(_engine.currentLevelNumber);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ticker.dispose();
    _engine.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    final bool isDown = event is KeyDownEvent;
    final bool isUp = event is KeyUpEvent;
    final bool isRepeat = event is KeyRepeatEvent;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyA) {
      if (isDown) _engine.setKeyLeft(true);
      if (isUp) _engine.setKeyLeft(false);
    } else if (key == LogicalKeyboardKey.keyD) {
      if (isDown) _engine.setKeyRight(true);
      if (isUp) _engine.setKeyRight(false);
    } else if (key == LogicalKeyboardKey.keyS) {
      if (isDown) _engine.setKeyDown(true);
      if (isUp) _engine.setKeyDown(false);
    } else if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.space) {
      if (isDown && !isRepeat) {
        _engine.jump();
      } else if (isUp) {
        _engine.releaseJump();
      }
    } else if (key == LogicalKeyboardKey.keyJ) {
      if (isDown && !isRepeat) {
        _engine.attack();
      }
    } else if (key == LogicalKeyboardKey.escape) {
      if (isDown && !isRepeat) {
        _engine.togglePause();
      }
    }
  }

  void _goToNextLevel() {
    setState(() {
      _hasSavedProgress = false;
      _engine.initLevel(_engine.currentLevelNumber + 1);
    });
  }

  void _openLevelSelect() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          onSelectLevel: (lvl) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GameScreen(initialLevel: lvl)),
            );
          },
          onBack: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    _engine.updateScreenSize(screenSize.width, screenSize.height);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: GameColors.skyBackground,
        body: ListenableBuilder(
        listenable: _engine,
        builder: (context, _) {
          return Stack(
            children: [
              // 1. World & Platforms
              CustomPaint(
                size: screenSize,
                painter: ForestPainter(
                  levelData: _engine.levelData,
                  cameraX: _engine.cameraX,
                  cameraY: _engine.cameraY,
                  time: _time,
                ),
              ),

              // 2. Enemies & Hazards
              CustomPaint(
                size: screenSize,
                painter: EnemyPainter(
                  levelData: _engine.levelData,
                  cameraX: _engine.cameraX,
                  cameraY: _engine.cameraY,
                  time: _time,
                ),
              ),

              // 3. Player Character
              CustomPaint(
                size: screenSize,
                painter: CharacterPainter(
                  player: _engine.player,
                  cameraX: _engine.cameraX,
                  cameraY: _engine.cameraY,
                  time: _time,
                ),
              ),

              // 4. Particles (Spores, Sparks, Leaves)
              CustomPaint(
                size: screenSize,
                painter: ParticlePainter(
                  particles: _engine.particles,
                  cameraX: _engine.cameraX,
                  cameraY: _engine.cameraY,
                  time: _time,
                ),
              ),

              // 5. Game HUD (Top SafeArea)
              SafeArea(
                child: GameHud(
                  currentHealth: _engine.player.currentHealth,
                  maxHealth: _engine.player.maxHealth,
                  coins: _engine.player.coins,
                  onPause: () => _engine.togglePause(),
                ),
              ),

              // 6. Mobile Touch Controls (Responsive Layout)
              if (_engine.status == GameStatus.playing)
                Positioned(
                  left: isLandscape ? padding.left + 24 : 20,
                  bottom: isLandscape ? 20 : 30,
                  child: VirtualJoystick(
                    onChanged: (val) => _engine.setJoystickInput(val),
                  ),
                ),

              if (_engine.status == GameStatus.playing)
                Positioned(
                  right: isLandscape ? padding.right + 24 : 20,
                  bottom: isLandscape ? 20 : 30,
                  child: ActionButtons(
                    onJump: () => _engine.jump(),
                    onJumpRelease: () => _engine.releaseJump(),
                    onAttack: () => _engine.attack(),
                  ),
                ),

              // 7. Pause Overlay
              if (_engine.status == GameStatus.paused)
                PauseOverlay(
                  onResume: () => _engine.togglePause(),
                  onRestart: () {
                    _hasSavedProgress = false;
                    _engine.initLevel();
                  },
                  onQuit: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    );
                  },
                ),

              // 8. Game Over Overlay
              if (_engine.status == GameStatus.gameOver)
                GameOverOverlay(
                  hasCheckpoint: _engine.activeCheckpointId != null,
                  onRespawn: () => _engine.restartFromCheckpoint(),
                  onRestart: () {
                    _hasSavedProgress = false;
                    _engine.initLevel();
                  },
                ),

              // 9. Victory Overlay
              if (_engine.status == GameStatus.victory)
                VictoryOverlay(
                  levelNumber: _engine.currentLevelNumber,
                  coinsCollected: _engine.player.coins,
                  onNextLevel: _goToNextLevel,
                  onReplay: () {
                    _hasSavedProgress = false;
                    _engine.initLevel();
                  },
                  onLevelSelect: _openLevelSelect,
                ),
            ],
          );
        },
      ),
    ),
    );
  }
}
