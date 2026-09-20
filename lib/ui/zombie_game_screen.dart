import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';
import 'package:enchanted_forest_adventure/game/zombie_game_engine.dart';
import 'package:enchanted_forest_adventure/rendering/night_world_painter.dart';
import 'package:enchanted_forest_adventure/rendering/zombie_painter.dart';
import 'package:enchanted_forest_adventure/rendering/character_painter.dart';
import 'package:enchanted_forest_adventure/rendering/particle_painter.dart';
import 'package:enchanted_forest_adventure/widgets/virtual_joystick.dart';
import 'package:enchanted_forest_adventure/widgets/action_buttons.dart';
import 'package:enchanted_forest_adventure/ui/pause_overlay.dart';
import 'package:enchanted_forest_adventure/ui/game_over_overlay.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';

class ZombieGameScreen extends StatefulWidget {
  const ZombieGameScreen({super.key});

  @override
  State<ZombieGameScreen> createState() => _ZombieGameScreenState();
}

class _ZombieGameScreenState extends State<ZombieGameScreen> with SingleTickerProviderStateMixin {
  late ZombieGameEngine _engine;
  late Ticker _ticker;
  late final FocusNode _focusNode;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _engine = ZombieGameEngine();
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
        backgroundColor: const Color(0xFF030612),
        body: ListenableBuilder(
          listenable: _engine,
          builder: (context, _) {
            return Stack(
              children: [
                // 1. Night World Environment
                CustomPaint(
                  size: screenSize,
                  painter: NightWorldPainter(
                    nightWorld: _engine.nightWorld,
                    cameraX: _engine.cameraX,
                    cameraY: _engine.cameraY,
                    time: _time,
                  ),
                ),

                // 2. Zombie Horde Entities
                CustomPaint(
                  size: screenSize,
                  painter: ZombiePainter(
                    zombies: _engine.activeZombies,
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

                // 4. Particles (Spores, Sparks, Blood Hits)
                CustomPaint(
                  size: screenSize,
                  painter: ParticlePainter(
                    particles: _engine.particles,
                    cameraX: _engine.cameraX,
                    cameraY: _engine.cameraY,
                    time: _time,
                  ),
                ),

                // 5. Dedicated Zombie Mode HUD
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Health Bar (Top Left)
                        Row(
                          children: [
                            const Icon(Icons.favorite_rounded, color: Color(0xFFFF3333), size: 24),
                            const SizedBox(width: 6),
                            Text(
                              '${_engine.player.currentHealth}/${_engine.player.maxHealth}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Color(0xFFFF0000), blurRadius: 8)],
                              ),
                            ),
                          ],
                        ),

                        // WAVE Display (Top Center)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFF3333), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFFFF0000), blurRadius: 10, spreadRadius: -2),
                            ],
                          ),
                          child: Text(
                            'WAVE ${_engine.currentWave.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFFFF4D4D),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        // Zombies Left & Pause Button (Top Right)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: GameColors.uiGlassBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.coronavirus_rounded, color: Color(0xFFFF5252), size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_engine.zombiesRemainingInWave + _engine.activeZombies.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () => _engine.togglePause(),
                              icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Mobile Touch Controls
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
                    onRestart: () => _engine.initNightWorld(),
                    onQuit: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                      );
                    },
                  ),

                // 8. Game Over Overlay
                if (_engine.status == GameStatus.gameOver)
                  GameOverOverlay(
                    hasCheckpoint: false,
                    onRespawn: () => _engine.initNightWorld(),
                    onRestart: () => _engine.initNightWorld(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
