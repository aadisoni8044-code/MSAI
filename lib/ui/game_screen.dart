import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/game_controller.dart';
import '../game/renderer_3d.dart';
import 'hud_overlay.dart';
import 'controls_overlay.dart';
import 'inventory_dialog.dart';
import 'settings_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late final GameController controller;
  late final Ticker _ticker;
  Duration _lastFrameTime = Duration.zero;

  @override
  void initState() {
    super.initState() ;
    controller = GameController();
    controller.addListener(_onControllerUpdate);

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (_lastFrameTime == Duration.zero) {
      _lastFrameTime = elapsed;
      return;
    }

    final dt = (elapsed - _lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = elapsed;

    // Cap frame step to avoid large delta jumps
    final clampedDt = dt.clamp(0.001, 0.05);
    controller.update(clampedDt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
    super.dispose();
  }

  void _openPauseMenu() {
    if (!controller.isPaused) {
      controller.togglePause();
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SettingsDialog(controller: controller),
    );
  }

  void _openInventory() {
    showDialog(
      context: context,
      builder: (_) => InventoryDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. 3D Renderer Canvas
          Positioned.fill(
            child: CustomPaint(
              painter: Renderer3D(
                player: controller.player,
                zombies: controller.waveManager.activeZombies,
                bullets: controller.bullets,
                world: controller.world,
                viewportSize: size,
              ),
            ),
          ),

          // 2. Virtual Controls Overlay
          Positioned.fill(
            child: ControlsOverlay(controller: controller),
          ),

          // 3. HUD Overlay
          Positioned.fill(
            child: HUDOverlay(
              controller: controller,
              onOpenPause: _openPauseMenu,
              onOpenInventory: _openInventory,
            ),
          ),

          // 4. Game Over Screen
          if (controller.isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'YOU DIED',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.black,
                          fontSize: 42,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Zombies Defeated: ${controller.player.killCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        'Wave Reached: ${controller.waveManager.waveNumber}',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.restartGame();
                        },
                        icon: const Icon(Icons.replay),
                        label: const Text('RESTART SURVIVAL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
