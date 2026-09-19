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
    _drawFarParallaxLayer(canvas, size);
    _drawGodRaysAndAtmosphere(canvas, size);
    _drawMidParallaxLayer(canvas, size);
    _drawPlatformsAndTerrain(canvas, size);
    _drawCheckpointsAndPortal(canvas, size);
  }

  void _drawSkyBackground(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final List<Color> skyColors = _getSkyColors(levelData.theme);

    final Paint skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skyColors,
      ).createShader(rect);

    canvas.drawRect(rect, skyPaint);

    // Subtle background stars / distant glowing dust
    final Paint starPaint = Paint()..color = _getStarColor(levelData.theme);
    for (int i = 0; i < 35; i++) {
      final double sx = ((i * 137.5) % size.width);
      final double sy = ((i * 83.1) % (size.height * 0.5));
      final double pulse = 1.0 + 0.5 * sin(time * 2 + i);
      canvas.drawCircle(Offset(sx, sy), 1.3 * pulse, starPaint);
    }
  }

  List<Color> _getSkyColors(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.forest:
        return [GameColors.skyBackground, GameColors.deepForestTeal, GameColors.atmosphericHaze];
      case LevelTheme.fire:
        return [const Color(0xFF2B0903), const Color(0xFF5A1408), const Color(0xFF8D220F)];
      case LevelTheme.water:
        return [const Color(0xFF031926), const Color(0xFF0A3663), const Color(0xFF1B4978)];
      case LevelTheme.ice:
        return [const Color(0xFF0B2545), const Color(0xFF134074), const Color(0xFF4A90A4)];
      case LevelTheme.desert:
        return [const Color(0xFF3A1C02), const Color(0xFF6B3A0A), const Color(0xFF9E5C1B)];
      case LevelTheme.thunder:
        return [const Color(0xFF19002E), const Color(0xFF2B0040), const Color(0xFF3C096C)];
      case LevelTheme.poison:
        return [const Color(0xFF10002B), const Color(0xFF240046), const Color(0xFF3C096C)];
      case LevelTheme.sky:
        return [const Color(0xFF003049), const Color(0xFF125B8A), const Color(0xFF2A83B9)];
      case LevelTheme.shadow:
        return [const Color(0xFF03071E), const Color(0xFF0D1B2A), const Color(0xFF1B263B)];
      case LevelTheme.crystal:
        return [const Color(0xFF240046), const Color(0xFF5A189A), const Color(0xFF7B2CBF)];
    }
  }

  Color _getStarColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0x77FF6B6B);
      case LevelTheme.water:
        return const Color(0x774EA8DE);
      case LevelTheme.ice:
        return const Color(0x88CAF0F8);
      case LevelTheme.desert:
        return const Color(0x77FFD166);
      case LevelTheme.thunder:
        return const Color(0x88C77DFF);
      case LevelTheme.poison:
        return const Color(0x7700F5D4);
      case LevelTheme.crystal:
        return const Color(0x88F72585);
      default:
        return const Color(0x66A6E3E9);
    }
  }

  void _drawFarParallaxLayer(Canvas canvas, Size size) {
    final double farCamX = cameraX * 0.2;
    final Paint farPaint = Paint()..color = _getFarLayerColor(levelData.theme);

    final Path path = Path();
    path.moveTo(0, size.height);

    const double spacing = 200;
    final double startX = -((farCamX) % spacing) - spacing;

    for (double x = startX; x < size.width + spacing * 2; x += spacing) {
      final double h = 320 + sin(x * 0.01) * 80;
      final double topY = size.height - h - (cameraY * 0.1);

      if (levelData.theme == LevelTheme.ice || levelData.theme == LevelTheme.desert) {
        // Sharp mountain peaks
        path.lineTo(x + spacing / 2, topY);
        path.lineTo(x + spacing, topY + h);
      } else {
        // Curved tree or terrain silhouettes
        path.lineTo(x, topY + 100);
        path.quadraticBezierTo(x + 40, topY - 30, x + 100, topY + 80);
        path.quadraticBezierTo(x + 150, topY - 10, x + spacing, topY + 120);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, farPaint);
  }

  Color _getFarLayerColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF3D0C02);
      case LevelTheme.water:
        return const Color(0xFF041926);
      case LevelTheme.ice:
        return const Color(0xFF0D2838);
      case LevelTheme.desert:
        return const Color(0xFF4A2503);
      case LevelTheme.thunder:
        return const Color(0xFF1D0036);
      case LevelTheme.poison:
        return const Color(0xFF1B0033);
      case LevelTheme.sky:
        return const Color(0xFF0D3B66);
      case LevelTheme.shadow:
        return const Color(0xFF0A0F1D);
      case LevelTheme.crystal:
        return const Color(0xFF38004D);
      default:
        return const Color(0xFF132A36);
    }
  }

  void _drawGodRaysAndAtmosphere(Canvas canvas, Size size) {
    final Paint rayPaint = Paint()
      ..color = _getStarColor(levelData.theme)
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

      rayPaint.color = _getStarColor(levelData.theme).withValues(alpha: 0.12 * pulse);
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  void _drawMidParallaxLayer(Canvas canvas, Size size) {
    final double midCamX = cameraX * 0.5;
    final double midCamY = cameraY * 0.3;

    final Paint midBodyPaint = Paint()..color = _getMidLayerColor(levelData.theme);
    final Paint midDetailPaint = Paint()..color = _getMidAccentColor(levelData.theme);

    const double width = 80;
    const double interval = 320;
    final double startX = -((midCamX) % interval) - interval;

    for (double x = startX; x < size.width + interval; x += interval) {
      final double treeY = size.height - 680 - midCamY;

      if (levelData.theme == LevelTheme.crystal) {
        // Glowing Crystal Spire background elements
        final Path spirePath = Path()
          ..moveTo(x + width / 2, treeY)
          ..lineTo(x + width, treeY + 350)
          ..lineTo(x, treeY + 350)
          ..close();
        canvas.drawPath(spirePath, midDetailPaint);
      } else {
        // Trunk / Pillar
        final Path trunkPath = Path()
          ..moveTo(x, size.height)
          ..quadraticBezierTo(x + 10, treeY + 300, x + 20, treeY)
          ..lineTo(x + width - 20, treeY)
          ..quadraticBezierTo(x + width - 10, treeY + 300, x + width, size.height)
          ..close();

        canvas.drawPath(trunkPath, midBodyPaint);

        // Canopy / Cap
        canvas.drawCircle(Offset(x + width / 2, treeY - 20), 100, midDetailPaint);
      }
    }
  }

  Color _getMidLayerColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF260501);
      case LevelTheme.water:
        return const Color(0xFF082238);
      case LevelTheme.ice:
        return const Color(0xFF113247);
      case LevelTheme.desert:
        return const Color(0xFF331802);
      case LevelTheme.thunder:
        return const Color(0xFF140026);
      case LevelTheme.poison:
        return const Color(0xFF16002B);
      case LevelTheme.sky:
        return const Color(0xFF16425B);
      case LevelTheme.shadow:
        return const Color(0xFF0A0F1D);
      case LevelTheme.crystal:
        return const Color(0xFF2B003B);
      default:
        return GameColors.ancientBarkDark;
    }
  }

  Color _getMidAccentColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF5A1408);
      case LevelTheme.water:
        return const Color(0xFF1B4978);
      case LevelTheme.ice:
        return const Color(0xFF2C5E7A);
      case LevelTheme.desert:
        return const Color(0xFF6B3A0A);
      case LevelTheme.thunder:
        return const Color(0xFF3C096C);
      case LevelTheme.poison:
        return const Color(0xFF240046);
      case LevelTheme.sky:
        return const Color(0xFF2A83B9);
      case LevelTheme.shadow:
        return const Color(0xFF1B263B);
      case LevelTheme.crystal:
        return const Color(0xFF7B2CBF);
      default:
        return const Color(0xFF1E4638);
    }
  }

  void _drawPlatformsAndTerrain(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    final Paint platBodyPaint = Paint()..color = _getPlatformBodyColor(levelData.theme);
    final Paint platTopPaint = Paint()..color = _getPlatformTopColor(levelData.theme);

    for (final plat in levelData.platforms) {
      if (plat.x + plat.width < cameraX - 100 || plat.x > cameraX + size.width + 100) {
        continue;
      }

      final Rect rect = plat.bounds;
      final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      // Platform Main Body
      canvas.drawRRect(rrect, platBodyPaint);

      // Top Trim / Surface Layer
      final Path topPath = Path();
      topPath.moveTo(rect.left - 2, rect.top + 6);
      topPath.lineTo(rect.left - 2, rect.top);

      for (double x = rect.left; x <= rect.right; x += 12) {
        final double wave = sin(x * 0.1) * 3;
        topPath.lineTo(x, rect.top + wave);
      }

      topPath.lineTo(rect.right + 2, rect.top);
      topPath.lineTo(rect.right + 2, rect.top + 8);
      topPath.close();

      canvas.drawPath(topPath, platTopPaint);
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
        final Paint potPaint = Paint()..color = const Color(0xFFE63946);
        canvas.drawCircle(center, 12, Paint()..color = const Color(0x66E63946));
        canvas.drawCircle(center, 8, potPaint);
        canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, center.dy - 10), width: 6, height: 6), potPaint);
      }
    }

    canvas.restore();
  }

  Color _getPlatformBodyColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF1E1010);
      case LevelTheme.water:
        return const Color(0xFF0F2537);
      case LevelTheme.ice:
        return const Color(0xFF1B3B52);
      case LevelTheme.desert:
        return const Color(0xFF3D230D);
      case LevelTheme.thunder:
        return const Color(0xFF221133);
      case LevelTheme.poison:
        return const Color(0xFF280C3D);
      case LevelTheme.sky:
        return const Color(0xFF1B3C59);
      case LevelTheme.shadow:
        return const Color(0xFF111422);
      case LevelTheme.crystal:
        return const Color(0xFF3D0C4A);
      default:
        return GameColors.ancientBarkDark;
    }
  }

  Color _getPlatformTopColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFFFF4500);
      case LevelTheme.water:
        return const Color(0xFF00B4D8);
      case LevelTheme.ice:
        return const Color(0xFFCAF0F8);
      case LevelTheme.desert:
        return const Color(0xFFFFC6FF);
      case LevelTheme.thunder:
        return const Color(0xFFC77DFF);
      case LevelTheme.poison:
        return const Color(0xFF00F5D4);
      case LevelTheme.sky:
        return const Color(0xFFE0F1E7);
      case LevelTheme.shadow:
        return const Color(0xFF7B2CBF);
      case LevelTheme.crystal:
        return const Color(0xFFF72585);
      default:
        return GameColors.mossyGreenBright;
    }
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
