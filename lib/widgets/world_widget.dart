import 'dart:math';
import 'package:flutter/material.dart';

import '../models/level_model.dart';
import '../services/game_service.dart';

class WorldWidget extends StatelessWidget {
  final GameService gameService;

  const WorldWidget({super.key, required this.gameService});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ForestWorldPainter(gameService: gameService),
    );
  }
}

class ForestWorldPainter extends CustomPainter {
  final GameService gameService;

  ForestWorldPainter({required this.gameService}) : super(repaint: gameService);

  @override
  void paint(Canvas canvas, Size size) {
    final level = gameService.currentLevel;
    if (level == null) return;

    final camX = gameService.cameraX;
    final camY = gameService.cameraY;
    final time = gameService.levelTime;

    // Apply camera shake translation
    double shakeOffsetX = 0.0;
    double shakeOffsetY = 0.0;
    if (gameService.cameraShake > 0) {
      final rand = Random();
      shakeOffsetX = (rand.nextDouble() - 0.5) * gameService.cameraShake;
      shakeOffsetY = (rand.nextDouble() - 0.5) * gameService.cameraShake;
    }

    canvas.save();
    canvas.translate(-camX + shakeOffsetX, -camY + shakeOffsetY);

    // LAYER 1: Deep Sky & Radiant Atmospheric Gradient
    _drawSkyGradient(canvas, size, level, camX, camY);

    // LAYER 2: Distant Mountain Silhouettes (Parallax 0.1)
    _drawDistantMountains(canvas, size, level, camX * 0.1);

    // LAYER 3: Far Ancient Canopy & Deep Trunks (Parallax 0.25)
    _drawFarTrees(canvas, size, level, camX * 0.25);

    // LAYER 4: Mid Trees & Ambient Glow (Parallax 0.5)
    _drawMidTrees(canvas, size, level, camX * 0.5, time);

    // LAYER 5: Large Foreground Ancient Tree Trunks (Parallax 0.8)
    _drawForegroundTrees(canvas, size, level, camX * 0.8);

    // LAYER 6: Drifting Fog & Particle Mist
    _drawFogAndParticles(canvas, size, level, camX, time);

    // LAYER 7: Hanging Vines & Dense Ambient Vegetation
    _drawHangingVines(canvas, size, level, camX, time);

    // LAYER 8: Solid Platforms & Ground Mechanics
    _drawPlatforms(canvas, level);

    // LAYER 9: Collectibles, Checkpoints & Exit Portal
    _drawCollectiblesAndPortals(canvas, level, time);

    // Dynamic Game Particles (Sparks, Dust, Attack impacts)
    _drawGameParticles(canvas);

    canvas.restore();
  }

  void _drawSkyGradient(Canvas canvas, Size size, LevelModel level, double camX, double camY) {
    final rect = Rect.fromLTWH(camX, camY, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF030D18),
          level.primaryColor,
          level.secondaryColor,
          const Color(0xFF091F2C),
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _drawDistantMountains(Canvas canvas, Size size, LevelModel level, double scrollX) {
    final path = Path();
    path.moveTo(scrollX - 200, 500);

    for (double x = scrollX - 200; x < scrollX + size.width + 400; x += 180) {
      double height = 120 + sin(x * 0.005) * 60 + cos(x * 0.012) * 30;
      path.lineTo(x + 90, 450 - height);
      path.lineTo(x + 180, 500);
    }
    path.lineTo(scrollX + size.width + 400, 700);
    path.lineTo(scrollX - 200, 700);
    path.close();

    final paint = Paint()
      ..color = level.primaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void _drawFarTrees(Canvas canvas, Size size, LevelModel level, double scrollX) {
    final paint = Paint()
      ..color = level.primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (double x = scrollX - 100; x < scrollX + size.width + 300; x += 140) {
      double trunkWidth = 35 + (sin(x) * 10).abs();
      canvas.drawRect(Rect.fromLTWH(x, 150, trunkWidth, 450), paint);

      // Far foliage clusters
      canvas.drawCircle(Offset(x + trunkWidth / 2, 140), 60, paint);
      canvas.drawCircle(Offset(x + trunkWidth / 2 - 30, 170), 45, paint);
      canvas.drawCircle(Offset(x + trunkWidth / 2 + 30, 170), 45, paint);
    }
  }

  void _drawMidTrees(Canvas canvas, Size size, LevelModel level, double scrollX, double time) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF0A2E33)
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = const Color(0xFF145358)
      ..style = PaintingStyle.fill;

    for (double x = scrollX - 150; x < scrollX + size.width + 300; x += 220) {
      double sway = sin(time * 1.5 + x) * 4.0;
      // Massive ancient trunk
      canvas.drawRect(Rect.fromLTWH(x, 100, 60, 500), trunkPaint);

      // Mid-layer branches & glowing leaf shapes
      canvas.drawCircle(Offset(x + 30 + sway, 100), 85, leafPaint);
      canvas.drawCircle(Offset(x - 20 + sway, 130), 65, leafPaint);
      canvas.drawCircle(Offset(x + 80 + sway, 130), 65, leafPaint);
    }
  }

  void _drawForegroundTrees(Canvas canvas, Size size, LevelModel level, double scrollX) {
    final trunkPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF071F22), Color(0xFF0D373B)],
      ).createShader(Rect.fromLTWH(0, 0, level.worldWidth, size.height));

    for (double x = scrollX - 200; x < scrollX + size.width + 400; x += 450) {
      final path = Path();
      // Gnarled tree trunk base with roots
      path.moveTo(x, 600);
      path.quadraticBezierTo(x + 30, 400, x + 15, 0);
      path.lineTo(x + 105, 0);
      path.quadraticBezierTo(x + 90, 400, x + 130, 600);
      path.lineTo(x + 180, 650);
      path.lineTo(x - 40, 650);
      path.close();

      canvas.drawPath(path, trunkPaint);
    }
  }

  void _drawFogAndParticles(Canvas canvas, Size size, LevelModel level, double camX, double time) {
    final fogPaint = Paint()..color = level.fogColor;

    for (int i = 0; i < 4; i++) {
      double fogX = (camX * 0.8 + time * (20 + i * 15)) % (size.width + 400) - 200 + camX;
      double fogY = 200.0 + i * 90.0 + sin(time + i) * 20.0;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(fogX, fogY), width: 400, height: 120),
        fogPaint,
      );
    }
  }

  void _drawHangingVines(Canvas canvas, Size size, LevelModel level, double camX, double time) {
    final vinePaint = Paint()
      ..color = const Color(0xFF1B6B63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    for (double x = camX - 50; x < camX + size.width + 100; x += 110) {
      double length = 80 + (sin(x * 0.05) * 40).abs();
      double sway = sin(time * 2.0 + x) * 8.0;

      final path = Path();
      path.moveTo(x, 0);
      path.quadraticBezierTo(x + sway, length / 2, x + sway / 2, length);

      canvas.drawPath(path, vinePaint);

      // Vine glowing leaf tips
      canvas.drawCircle(Offset(x + sway / 2, length), 4, Paint()..color = const Color(0xFF64DFDF));
    }
  }

  void _drawPlatforms(Canvas canvas, LevelModel level) {
    final platformPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E5B5A), Color(0xFF0F3B3E), Color(0xFF082224)],
      ).createShader(Rect.fromLTWH(0, 0, level.worldWidth, level.worldHeight));

    final topEdgePaint = Paint()
      ..color = const Color(0xFF64DFDF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final spikePaint = Paint()..color = const Color(0xFFEF476F);

    for (var p in level.platforms) {
      if (p.isBroken) continue;

      if (p.type == PlatformType.spike) {
        // Draw lethal spike teeth
        final spikePath = Path();
        double count = p.width / 16;
        for (int i = 0; i < count; i++) {
          double sx = p.x + i * 16;
          spikePath.moveTo(sx, p.y + p.height);
          spikePath.lineTo(sx + 8, p.y);
          spikePath.lineTo(sx + 16, p.y + p.height);
        }
        canvas.drawPath(spikePath, spikePaint);
        continue;
      }

      // Draw rounded platform base
      RRect rrect = RRect.fromRectAndRadius(p.rect, const Radius.circular(8));
      canvas.drawRRect(rrect, platformPaint);

      // Top glowing bioluminescent moss edge
      canvas.drawLine(
        Offset(p.x + 4, p.y + 1.5),
        Offset(p.x + p.width - 4, p.y + 1.5),
        topEdgePaint,
      );
    }
  }

  void _drawCollectiblesAndPortals(Canvas canvas, LevelModel level, double time) {
    for (var c in level.collectibles) {
      if (c.isCollected) continue;

      double floatY = c.y + sin(time * 4.0 + c.x) * 6.0;

      switch (c.type) {
        case CollectibleType.energyCrystal:
          // Glowing Diamond Crystal
          final path = Path()
            ..moveTo(c.x, floatY - 14)
            ..lineTo(c.x + 10, floatY)
            ..lineTo(c.x, floatY + 14)
            ..lineTo(c.x - 10, floatY)
            ..close();

          canvas.drawPath(
            path,
            Paint()..color = const Color(0xFF64DFDF),
          );
          // Glow aura
          canvas.drawCircle(
            Offset(c.x, floatY),
            16,
            Paint()..color = const Color(0x4464DFDF),
          );
          break;

        case CollectibleType.coin:
          canvas.drawCircle(Offset(c.x, floatY), 9, Paint()..color = const Color(0xFFFFD166));
          canvas.drawCircle(Offset(c.x, floatY), 6, Paint()..color = const Color(0xFFFFF099));
          break;

        case CollectibleType.healthPickup:
          canvas.drawCircle(Offset(c.x, floatY), 11, Paint()..color = const Color(0xFF06D6A0));
          // Heart cross symbol
          final paintCross = Paint()
            ..color = Colors.white
            ..strokeWidth = 3;
          canvas.drawLine(Offset(c.x - 5, floatY), Offset(c.x + 5, floatY), paintCross);
          canvas.drawLine(Offset(c.x, floatY - 5), Offset(c.x, floatY + 5), paintCross);
          break;

        case CollectibleType.secretRune:
          canvas.drawCircle(Offset(c.x, floatY), 12, Paint()..color = const Color(0xFFF72585));
          canvas.drawCircle(Offset(c.x, floatY), 18, Paint()..color = const Color(0x44F72585));
          break;
      }
    }

    // Checkpoints
    for (var cp in level.checkpoints) {
      Color flagColor = cp.isActive ? const Color(0xFF4CC9F0) : const Color(0xFF555555);
      canvas.drawRect(Rect.fromLTWH(cp.x - 3, cp.y - 48, 6, 48), Paint()..color = Colors.grey);
      final flagPath = Path()
        ..moveTo(cp.x + 3, cp.y - 48)
        ..lineTo(cp.x + 28, cp.y - 36)
        ..lineTo(cp.x + 3, cp.y - 24)
        ..close();
      canvas.drawPath(flagPath, Paint()..color = flagColor);
    }

    // Exit Portal
    final portalRect = level.exitPortal;
    canvas.drawOval(
      portalRect,
      Paint()
        ..shader = SweepGradient(
          colors: const [Color(0xFF80FFDB), Color(0xFF5390D9), Color(0xFF7209B7), Color(0xFF80FFDB)],
          transform: GradientRotation(time * 3.0),
        ).createShader(portalRect),
    );
    canvas.drawOval(
      portalRect.deflate(8),
      Paint()..color = const Color(0x66FFFFFF),
    );
  }

  void _drawGameParticles(Canvas canvas) {
    for (var p in gameService.particles) {
      double alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
