import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/weapon.dart';

class HUDOverlay extends StatelessWidget {
  final GameController controller;
  final VoidCallback onOpenPause;
  final VoidCallback onOpenInventory;

  const HUDOverlay({
    super.key,
    required this.controller,
    required this.onOpenPause,
    required this.onOpenInventory,
  });

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    final waveManager = controller.waveManager;
    final weapon = player.activeWeapon;

    return SafeArea(
      child: Stack(
        children: [
          // Top Left: Health Bar & Quick Health Kit
          Positioned(
            top: 12,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        height: 14,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: LinearProgressIndicator(
                            value: player.health.percentage,
                            backgroundColor: Colors.grey.shade900,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              player.health.percentage > 0.4 ? Colors.greenAccent : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${player.health.current.round()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Health Kit Quick Button
                GestureDetector(
                  onTap: controller.handleUseHealthPack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.emerald.shade900.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.emeraldAccent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.medical_services, color: Colors.emeraldAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'MEDKIT (${player.healthKits})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Center: Wave & Kill Counters + Air-drop Banner
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Wave Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade900.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigoAccent),
                      ),
                      child: Text(
                        'WAVE ${waveManager.waveNumber}',
                        style: const TextStyle(
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.black,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Kills Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed, color: Colors.orangeAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'KILLS: ${player.killCount}',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Air-Drop Banner Notification
                if (waveManager.airDropNotificationMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.yellowAccent, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.redAccent, blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      waveManager.airDropNotificationMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.black,
                        fontSize: 13,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Top Right: Minimap, Inventory, Pause
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    // Inventory Button
                    IconButton(
                      onPressed: onOpenInventory,
                      icon: const Icon(Icons.backpack, color: Colors.amberAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pause Button
                    IconButton(
                      onPressed: onOpenPause,
                      icon: const Icon(Icons.pause, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Radar Minimap Widget
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6), width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: CustomPaint(
                        painter: MinimapPainter(controller: controller),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Left: Active Weapon Ammo Badge
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    weapon.isMelee ? Icons.hardware : Icons.adjust,
                    color: Colors.amberAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weapon.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        weapon.isReloading
                            ? 'RELOADING...'
                            : weapon.isMelee
                                ? 'READY'
                                : '${weapon.ammoInClip} / ${weapon.reserveAmmo}',
                        style: TextStyle(
                          color: weapon.isReloading ? Colors.orangeAccent : Colors.amberAccent,
                          fontWeight: FontWeight.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MinimapPainter extends CustomPainter {
  final GameController controller;

  MinimapPainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = 1.2; // Radar scale factor

    final player = controller.player;

    // Draw Radar grid lines
    final gridPaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, size.width * 0.25, gridPaint);
    canvas.drawCircle(center, size.width * 0.45, gridPaint);

    // Draw Zombies
    final zombiePaint = Paint()..color = Colors.redAccent;
    for (var zombie in controller.waveManager.activeZombies) {
      if (zombie.isAlive) {
        final dx = (zombie.position.x - player.position.x) * scale;
        final dz = (zombie.position.z - player.position.z) * scale;

        final pos = center + Offset(dx, dz);
        if ((pos - center).distance <= size.width / 2 - 4) {
          canvas.drawCircle(pos, 2.5, zombiePaint);
        }
      }
    }

    // Draw Air-Drop crate if active
    if (controller.waveManager.airDropPosition != null) {
      final drop = controller.waveManager.airDropPosition!;
      final dx = (drop.x - player.position.x) * scale;
      final dz = (drop.z - player.position.z) * scale;

      final pos = center + Offset(dx, dz);
      if ((pos - center).distance <= size.width / 2 - 4) {
        final dropPaint = Paint()..color = Colors.yellowAccent;
        canvas.drawCircle(pos, 4.0, dropPaint);
      }
    }

    // Draw Player dot & direction pointer
    final playerPaint = Paint()..color = Colors.cyanAccent;
    canvas.drawCircle(center, 3.5, playerPaint);

    final dirX = math.sin(player.yaw) * 8.0;
    final dirZ = math.cos(player.yaw) * 8.0;
    final pointerPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.0;
    canvas.drawLine(center, center + Offset(dirX, dirZ), pointerPaint);
  }

  @override
  bool shouldRepaint(covariant MinimapPainter oldDelegate) => true;
}
