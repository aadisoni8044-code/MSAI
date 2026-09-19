import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';

class ForestPainter extends CustomPainter {
  final LevelData levelData;
  final double cameraX;
  final double cameraY;
  final double time;

  ForestPainter({
    required this.levelData,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSkyBackground(canvas, size);
    _drawFarParallaxForest(canvas, size);
    _drawGodRays(canvas, size);
    _drawMidParallaxTrees(canvas, size);
    _drawPlatformsAndTerrain(canvas, size);
    _drawCheckpointsAndPortal(canvas, size);
  }

  void _drawSkyBackground(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GameColors.skyBackground,
          GameColors.deepForestTeal,
          GameColors.atmosphericHaze,
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, skyPaint);

    // Subtle background stars / distant bioluminescent dots
    final Paint starPaint = Paint()..color = const Color(0x66A6E3E9);
    for (int i = 0; i < 30; i++) {
      final double sx = ((i * 137.5) % size.width);
      final double sy = ((i * 83.1) % (size.height * 0.5));
      final double pulse = 1.0 + 0.5 * sin(time * 2 + i);
      canvas.drawCircle(Offset(sx, sy), 1.2 * pulse, starPaint);
    }
  }

  void _drawFarParallaxForest(Canvas canvas, Size size) {
    // Parallax factor 0.2
    final double farCamX = cameraX * 0.2;
    final Paint treePaint = Paint()..color = const Color(0xFF132A36);

    final Path path = Path();
    path.moveTo(0, size.height);

    const double treeSpacing = 180;
    final double startX = -((farCamX) % treeSpacing) - treeSpacing;

    for (double x = startX; x < size.width + treeSpacing * 2; x += treeSpacing) {
      final double treeHeight = 350 + sin(x * 0.01) * 80;
      final double topY = size.height - treeHeight - (cameraY * 0.1);

      path.lineTo(x, topY + 120);
      path.quadraticBezierTo(x + 40, topY - 30, x + 90, topY + 100);
      path.quadraticBezierTo(x + 140, topY - 10, x + treeSpacing, topY + 140);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, treePaint);
  }

  void _drawGodRays(Canvas canvas, Size size) {
    final Paint rayPaint = Paint()
      ..color = GameColors.godRayLight
      ..blendMode = BlendMode.screen;

    for (int i = 0; i < 4; i++) {
      final double rayOffset = (time * 15 + i * 200) % (size.width + 300) - 150;
      final double pulse = 0.6 + 0.4 * sin(time + i);

      final Path rayPath = Path()
        ..moveTo(rayOffset, -50)
        ..lineTo(rayOffset + 90, -50)
        ..lineTo(rayOffset - 120, size.height + 50)
        ..lineTo(rayOffset - 210, size.height + 50)
        ..close();

      rayPaint.color = GameColors.godRayLight.withValues(alpha: 0.12 * pulse);
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  void _drawMidParallaxTrees(Canvas canvas, Size size) {
    // Parallax factor 0.5
    final double midCamX = cameraX * 0.5;
    final double midCamY = cameraY * 0.3;

    final Paint barkPaint = Paint()..color = GameColors.ancientBarkDark;
    final Paint leafPaint = Paint()..color = const Color(0xFF1E4638);

    const double treeWidth = 80;
    const double treeInterval = 320;
    final double startX = -((midCamX) % treeInterval) - treeInterval;

    for (double x = startX; x < size.width + treeInterval; x += treeInterval) {
      final double treeY = size.height - 700 - midCamY;

      // Trunk
      final Path trunkPath = Path()
        ..moveTo(x, size.height)
        ..quadraticBezierTo(x + 10, treeY + 300, x + 20, treeY)
        ..lineTo(x + treeWidth - 20, treeY)
        ..quadraticBezierTo(x + treeWidth - 10, treeY + 300, x + treeWidth, size.height)
        ..close();

      canvas.drawPath(trunkPath, barkPaint);

      // Canopy Foliage
      canvas.drawCircle(Offset(x + treeWidth / 2, treeY - 20), 110, leafPaint);
      canvas.drawCircle(Offset(x - 20, treeY + 30), 80, leafPaint);
      canvas.drawCircle(Offset(x + treeWidth + 20, treeY + 40), 85, leafPaint);

      // Hanging Vines
      final Paint vinePaint = Paint()
        ..color = GameColors.vineGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      for (int v = 0; v < 3; v++) {
        final double vineX = x + 15 + v * 25;
        final double vineLen = 80 + sin(time * 1.5 + v) * 10;
        final Path vinePath = Path()
          ..moveTo(vineX, treeY + 80)
          ..quadraticBezierTo(vineX + sin(time + v) * 8, treeY + 80 + vineLen / 2, vineX, treeY + 80 + vineLen);
        canvas.drawPath(vinePath, vinePaint);
      }
    }
  }

  void _drawPlatformsAndTerrain(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    final Paint platBodyPaint = Paint()..color = GameColors.ancientBarkDark;
    final Paint mossTopPaint = Paint()..color = GameColors.mossyGreenBright;

    for (final plat in levelData.platforms) {
      // Cull offscreen platforms
      if (plat.x + plat.width < cameraX - 100 || plat.x > cameraX + size.width + 100) {
        continue;
      }

      final Rect rect = plat.bounds;

      // Platform Main Body (Earth/Root)
      final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, platBodyPaint);

      // Top Moss Layer
      final Path mossPath = Path();
      mossPath.moveTo(rect.left - 4, rect.top + 8);
      mossPath.lineTo(rect.left - 4, rect.top);

      for (double x = rect.left; x <= rect.right; x += 12) {
        final double wave = sin(x * 0.1) * 4;
        mossPath.lineTo(x, rect.top + wave);
      }

      mossPath.lineTo(rect.right + 4, rect.top);
      mossPath.lineTo(rect.right + 4, rect.top + 10);

      // Grass fringe details
      for (double x = rect.right; x >= rect.left; x -= 12) {
        mossPath.quadraticBezierTo(x, rect.top + 18, x - 6, rect.top + 10);
      }
      mossPath.close();

      canvas.drawPath(mossPath, mossTopPaint);

      // Root Bark Lines
      final Paint linePaint = Paint()
        ..color = GameColors.ancientBarkLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (double y = rect.top + 20; y < rect.bottom - 10; y += 18) {
        canvas.drawLine(
          Offset(rect.left + 10, y),
          Offset(rect.right - 10, y + sin(y) * 4),
          linePaint,
        );
      }

      // Hanging roots / vines under platforms
      final Paint rootPaint = Paint()
        ..color = GameColors.vineGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      for (double rx = rect.left + 20; rx < rect.right - 10; rx += 45) {
        final double rootLen = 15 + sin(rx + time) * 6;
        canvas.drawLine(
          Offset(rx, rect.bottom),
          Offset(rx + sin(rx) * 5, rect.bottom + rootLen),
          rootPaint,
        );
      }
    }

    // Collectibles (Coins & Potions)
    final Paint coinPaint = Paint()..color = GameColors.coinGold;
    final Paint coinGlowPaint = Paint()..color = GameColors.coinGlow.withValues(alpha: 0.4);

    for (final item in levelData.collectibles) {
      if (item.isCollected) continue;
      if (item.x + item.width < cameraX - 50 || item.x > cameraX + size.width + 50) continue;

      final double hover = sin(time * 4 + item.x) * 4;
      final Offset center = Offset(item.x + item.width / 2, item.y + item.height / 2 + hover);

      if (item.type == EntityType.coin) {
        canvas.drawCircle(center, 13, coinGlowPaint);
        canvas.drawCircle(center, 9, coinPaint);
        canvas.drawCircle(center, 5, Paint()..color = const Color(0xFFE9C46A));
      } else if (item.type == EntityType.healthPot) {
        // Red glowing flask
        final Paint potPaint = Paint()..color = const Color(0xFFE63946);
        canvas.drawCircle(center, 12, Paint()..color = const Color(0x66E63946));
        canvas.drawCircle(center, 8, potPaint);
        canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, center.dy - 10), width: 6, height: 6), potPaint);
      }
    }

    canvas.restore();
  }

  void _drawCheckpointsAndPortal(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    // Checkpoints (Ancient Shrines)
    for (final cp in levelData.checkpoints) {
      final Rect rect = cp.bounds;
      final Paint stonePaint = Paint()..color = const Color(0xFF343A40);

      // Stone Pillars
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + 15, 12, rect.height - 15), stonePaint);
      canvas.drawRect(Rect.fromLTWH(rect.right - 12, rect.top + 15, 12, rect.height - 15), stonePaint);
      canvas.drawRect(Rect.fromLTWH(rect.left - 4, rect.top, rect.width + 8, 15), stonePaint);

      // Orb Center
      final Color glowColor = cp.isActivated ? GameColors.shrineActive : GameColors.shrineInactive;
      final Offset orbCenter = Offset(rect.left + rect.width / 2, rect.top + 35);

      canvas.drawCircle(orbCenter, 18, Paint()..color = glowColor.withValues(alpha: 0.3));
      canvas.drawCircle(orbCenter, 10, Paint()..color = glowColor);

      if (cp.isActivated) {
        final double pulse = sin(time * 5) * 3;
        canvas.drawCircle(orbCenter, 10 + pulse, Paint()..color = Colors.white.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }

    // Goal Portal
    final portal = levelData.goalPortal;
    final Rect pRect = portal.bounds;
    final Offset pCenter = Offset(pRect.left + pRect.width / 2, pRect.top + pRect.height / 2);

    final Paint portalGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          GameColors.portalGlow,
          GameColors.portalPurple,
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pCenter, radius: 55));

    canvas.drawCircle(pCenter, 55, portalGlow);

    // Rotating Portal Energy Rings
    final Paint ringPaint = Paint()
      ..color = GameColors.portalGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int r = 0; r < 3; r++) {
      final double radius = 18 + r * 12;
      final double angle = time * (3 - r) * (r.isEven ? 1 : -1);

      canvas.save();
      canvas.translate(pCenter.dx, pCenter.dy);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 1.3), ringPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ForestPainter oldDelegate) => true;
}
