import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/game/car_zombie_game_engine.dart';
import 'package:enchanted_forest_adventure/rendering/car_zombie_painter.dart';

class CarZombieGameScreen extends StatefulWidget {
  const CarZombieGameScreen({super.key});

  @override
  State<CarZombieGameScreen> createState() => _CarZombieGameScreenState();
}

class _CarZombieGameScreenState extends State<CarZombieGameScreen> with SingleTickerProviderStateMixin {
  late CarZombieGameEngine _engine;
  late Ticker _ticker;
  late final FocusNode _focusNode;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _engine = CarZombieGameEngine();
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
    final bool isRepeat = event is KeyRepeatEvent;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyJ || key == LogicalKeyboardKey.space) {
      if (isDown) _engine.shoot();
    } else if (key == LogicalKeyboardKey.keyR) {
      if (isDown && !isRepeat) _engine.reload();
    } else if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.shiftLeft) {
      if (isDown && !isRepeat) _engine.triggerBoost();
    } else if (key == LogicalKeyboardKey.escape) {
      if (isDown && !isRepeat) _engine.togglePause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final selectedCharacter = CharacterProgressController.instance.selectedCharacter;

    _engine.updateScreenSize(screenSize.width, screenSize.height);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ListenableBuilder(
          listenable: _engine,
          builder: (context, _) {
            return Stack(
              children: [
                // 1. Live 60 FPS Highway Chase Canvas
                CustomPaint(
                  size: screenSize,
                  painter: CarZombiePainter(
                    car: _engine.car,
                    zombies: _engine.zombies,
                    bullets: _engine.bullets,
                    obstacles: _engine.obstacles,
                    collectibles: _engine.collectibles,
                    particles: _engine.particles,
                    cameraX: _engine.car.x - 220.0,
                    roadY: _engine.roadY,
                    time: _time,
                    selectedCharacter: selectedCharacter,
                  ),
                ),

                // 2. Top HUD Bar
                _buildTopHud(),

                // 3. Bottom Touch Controls (Fire, Reload, Boost)
                if (_engine.status == CarZombieGameStatus.playing)
                  _buildBottomControls(),

                // 4. Pause Overlay
                if (_engine.status == CarZombieGameStatus.paused)
                  _buildPauseOverlay(),

                // 5. Game Over / Car Destroyed Overlay
                if (_engine.status == CarZombieGameStatus.gameOver)
                  _buildGameOverOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Group: Car HP Bar & Distance
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xDD0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car_rounded, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CAR HP ${(_engine.car.currentHp / _engine.car.maxHp * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 80,
                              height: 6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: _engine.car.currentHp / _engine.car.maxHp,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation(
                                    _engine.car.currentHp > 40 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Distance Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xDD0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.route_rounded, color: Color(0xFF38BDF8), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${_engine.distanceMeters.toInt()} m',
                          style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Right Group: Coins + Score + Pause Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xDD0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: GameColors.coinGold, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${_engine.sessionCoins}',
                          style: const TextStyle(color: GameColors.coinGold, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xDD0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFC77DFF), width: 1.5),
                    ),
                    child: Text(
                      'SCORE: ${_engine.score}',
                      style: const TextStyle(color: Color(0xFFC77DFF), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xDD0F172A),
                      side: const BorderSide(color: Colors.white30),
                    ),
                    icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 20),
                    onPressed: () => _engine.togglePause(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: Boost Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xEE0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
            onPressed: () => _engine.triggerBoost(),
            icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
            label: const Text('BOOST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ),

          // Right: Reload & Fire Buttons + Weapon Ammo Badge
          Row(
            children: [
              // Ammo Badge & Reload Button
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xEE0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _engine.isReloading
                          ? 'RELOADING...'
                          : 'AMMO: ${_engine.currentClip} / ${_engine.reserveAmmo}',
                      style: TextStyle(
                        color: _engine.currentClip == 0 ? const Color(0xFFEF4444) : const Color(0xFF80FFDB),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xEE3B82F6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _engine.reload(),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    label: const Text('RELOAD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Fire Button
              SizedBox(
                width: 76,
                height: 76,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xEEEF4444),
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 8,
                    side: const BorderSide(color: Color(0xFFFCA5A5), width: 2),
                  ),
                  onPressed: () => _engine.shoot(),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 30),
                      Text('FIRE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('GAME PAUSED', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size.fromHeight(44)),
                onPressed: () => _engine.togglePause(),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text('RESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), minimumSize: const Size.fromHeight(44)),
                onPressed: () => _engine.restart(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('RESTART RUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(44)),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70),
                label: const Text('EXIT TO MENU', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE1E1B4B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFF3333), width: 2.0),
            boxShadow: const [BoxShadow(color: Color(0x66FF3333), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CAR DESTROYED!', style: TextStyle(color: Color(0xFFFF4D4D), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('DISTANCE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${_engine.distanceMeters.toInt()} m', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('DEFEATED', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${_engine.zombiesDefeated}', style: const TextStyle(color: Color(0xFFFF4D4D), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('COINS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${_engine.sessionCoins}', style: const TextStyle(color: GameColors.coinGold, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size.fromHeight(44)),
                onPressed: () => _engine.restart(),
                icon: const Icon(Icons.replay_rounded, color: Colors.white),
                label: const Text('TRY AGAIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(44)),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70),
                label: const Text('EXIT TO LOBBY', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
