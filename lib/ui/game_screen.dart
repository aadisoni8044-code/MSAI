import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  late Ticker _ticker;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _ticker = createTicker(_onTick)..start();
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
  }

  @override
  void dispose() {
    _ticker.dispose();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    _engine.updateScreenSize(screenSize.width, screenSize.height);

    return Scaffold(
      backgroundColor: GameColors.skyBackground,
      body: ListenableBuilder(
        listenable: _engine,
        builder: (context, _) {
          return Stack(
            children: [
              // 1. Forest World & Platforms
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

              // 5. Game HUD
              SafeArea(
                child: GameHud(
                  currentHealth: _engine.player.currentHealth,
                  maxHealth: _engine.player.maxHealth,
                  coins: _engine.player.coins,
                  onPause: () => _engine.togglePause(),
                ),
              ),

              // 6. Mobile Touch Controls
              if (_engine.status == GameStatus.playing)
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: VirtualJoystick(
                    onChanged: (val) => _engine.setJoystickInput(val),
                  ),
                ),

              if (_engine.status == GameStatus.playing)
                Positioned(
                  right: 20,
                  bottom: 30,
                  child: ActionButtons(
                    onJump: () => _engine.jump(),
                    onAttack: () => _engine.attack(),
                  ),
                ),

              // 7. Pause Overlay
              if (_engine.status == GameStatus.paused)
                PauseOverlay(
                  onResume: () => _engine.togglePause(),
                  onRestart: () => _engine.initLevel(),
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
                  onRestart: () => _engine.initLevel(),
                ),

              // 9. Victory Overlay
              if (_engine.status == GameStatus.victory)
                VictoryOverlay(
                  coinsCollected: _engine.player.coins,
                  onReplay: () => _engine.initLevel(),
                ),
            ],
          );
        },
      ),
    );
  }
}
