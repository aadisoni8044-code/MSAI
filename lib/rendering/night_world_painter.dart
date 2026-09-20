import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_mode_data.dart';

class NightWorldPainter extends CustomPainter {
  final ZombieModeData nightWorld;
  final double cameraX;
  final double cameraY;
  final double time;

  NightWorldPainter({
    required this.nightWorld,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark Sky Background
    final Rect screenRect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030612),
          Color(0xFF0A0F24),
          Color(0xFF0F172A),
        ],
      ).createShader(screenRect);
    canvas.drawRect(screenRect, skyPaint);

    // 2. Full Moon & Distant Night Clouds
    final Paint moonGlow = Paint()
      ..color = const Color(0x33D0E1FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(Offset(size.width * 0.75, 120), 75, moonGlow);

    final Paint moonBody = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(Offset(size.width * 0.75, 120), 45, moonBody);

    // Moon craters
    final Paint craterPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawCircle(Offset(size.width * 0.75 - 12, 110), 10, craterPaint);
    canvas.drawCircle(Offset(size.width * 0.75 + 14, 130), 8, craterPaint);

    // 3. Parallax Mountain & Dead Tree Silhouettes
    canvas.save();
    canvas.translate(-cameraX * 0.2, -cameraY * 0.1);
    final Paint bgSilhouette = Paint()..color = const Color(0xFF070B19);

    final Path bgMountains = Path()
      ..moveTo(0, size.height)
      ..lineTo(300, size.height - 280)
      ..lineTo(700, size.height - 180)
      ..lineTo(1200, size.height - 320)
      ..lineTo(1800, size.height - 200)
      ..lineTo(2500, size.height - 300)
      ..lineTo(3200, size.height - 220)
      ..lineTo(4000, size.height - 350)
      ..lineTo(4800, size.height)
      ..close();
    canvas.drawPath(bgMountains, bgSilhouette);
    canvas.restore();

    // 4. Main World Canvas (Translated by Camera)
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    // Draw Abandoned Watchtowers
    final Paint towerWood = Paint()..color = const Color(0xFF1E293B);
    final Paint towerMetal = Paint()..color = const Color(0xFF0F172A);
    final Paint towerBorder = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final tower in nightWorld.watchtowers) {
      if (tower.right < cameraX - 100 || tower.left > cameraX + size.width + 100) continue;

      // Tower Support Pillars
      canvas.drawRect(Rect.fromLTWH(tower.left + 20, tower.top, 24, tower.height), towerWood);
      canvas.drawRect(Rect.fromLTWH(tower.right - 44, tower.top, 24, tower.height), towerWood);

      // Diagonal Cross Beams
      final Path crossPath = Path()
        ..moveTo(tower.left + 20, tower.top + 50)
        ..lineTo(tower.right - 20, tower.top + 200)
        ..moveTo(tower.right - 20, tower.top + 50)
        ..lineTo(tower.left + 20, tower.top + 200);
      canvas.drawPath(crossPath, towerBorder);

      // Watchtower Roof
      final Path roof = Path()
        ..moveTo(tower.left - 20, tower.top)
        ..lineTo(tower.center.dx, tower.top - 45)
        ..lineTo(tower.right + 20, tower.top)
        ..close();
      canvas.drawPath(roof, towerMetal);
    }

    // Draw Platforms & Ground
    final Paint groundPaint = Paint()..color = const Color(0xFF090D16);
    final Paint surfaceGrass = Paint()..color = const Color(0xFF1E293B);
    final Paint platformBorder = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final plat in nightWorld.platforms) {
      if (plat.x + plat.width < cameraX - 100 || plat.x > cameraX + size.width + 100) continue;

      final Rect rect = plat.bounds;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), groundPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), platformBorder);

      // Top dark surface rim
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 6), surfaceGrass);
    }

    // Draw Collectibles
    final Paint coinPaint = Paint()..color = const Color(0xFFFFD166);
    final Paint potPaint = Paint()..color = const Color(0xFF80FFDB);

    for (final item in nightWorld.collectibles) {
      if (item.isCollected) continue;
      if (item.x + item.width < cameraX - 50 || item.x > cameraX + size.width + 50) continue;

      final bounceY = item.y + sin(time * 4 + item.x) * 4;
      if (item.type == EntityType.coin) {
        canvas.drawCircle(Offset(item.x + 11, bounceY + 11), 10, coinPaint);
      } else {
        canvas.drawRect(Rect.fromLTWH(item.x, bounceY, item.width, item.height), potPaint);
      }
    }

    canvas.restore();

    // 5. Foreground Atmospheric Night Fog
    final Paint fogPaint = Paint()
      ..color = const Color(0x1A0F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(size.width * 0.3 + sin(time) * 30, size.height * 0.8), 180, fogPaint);
    canvas.drawCircle(Offset(size.width * 0.8 - sin(time) * 30, size.height * 0.75), 220, fogPaint);
  }

  @override
  bool shouldRepaint(covariant NightWorldPainter oldDelegate) => true;
}
