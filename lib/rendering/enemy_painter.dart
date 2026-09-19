import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';

class EnemyPainter extends CustomPainter {
  final LevelData levelData;
  final double cameraX;
  final double cameraY;
  final double time;

  EnemyPainter({
    required this.levelData,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    // Render Enemies
    for (final enemy in levelData.enemies) {
      if (enemy.health <= 0) continue;
      if (enemy.x + enemy.width < cameraX - 80 || enemy.x > cameraX + size.width + 80) continue;

      canvas.save();
      canvas.translate(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2);

      if (enemy.vx < 0) {
        canvas.scale(-1.0, 1.0);
      }

      switch (enemy.type) {
        case EntityType.enemySlime:
          _drawSlime(canvas, enemy);
          break;
        case EntityType.enemyShadow:
          _drawShadowStalker(canvas, enemy);
          break;
        case EntityType.enemyFire:
          _drawFireDemon(canvas, enemy);
          break;
        case EntityType.enemyIce:
          _drawIceGolem(canvas, enemy);
          break;
        case EntityType.enemyToxic:
          _drawToxicBeast(canvas, enemy);
          break;
        default:
          _drawSlime(canvas, enemy);
          break;
      }

      canvas.restore();
    }

    // Render Hazards
    for (final hazard in levelData.hazards) {
      if (hazard.x + hazard.width < cameraX - 100 || hazard.x > cameraX + size.width + 100) continue;

      if (hazard.type == EntityType.hazardSpike) {
        _drawSpikes(canvas, hazard);
      } else if (hazard.type == EntityType.hazardLava) {
        _drawLavaPool(canvas, hazard);
      } else if (hazard.type == EntityType.hazardPoison) {
        _drawPoisonPool(canvas, hazard);
      } else if (hazard.type == EntityType.hazardLightning) {
        _drawLightningArc(canvas, hazard);
      }
    }

    canvas.restore();
  }

  void _drawSlime(Canvas canvas, GameEntity enemy) {
    final double squish = sin(time * 8 + enemy.startX) * 0.15;
    final double w = enemy.width * (1.0 + squish);
    final double h = enemy.height * (1.0 - squish);

    final Paint slimePaint = Paint()..color = GameColors.slimeGreen;
    final Paint slimeGlow = Paint()..color = GameColors.slimeGlow;

    final Rect slimeRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final RRect rrect = RRect.fromRectAndCorners(
      slimeRect,
      topLeft: Radius.circular(w * 0.4),
      topRight: Radius.circular(w * 0.4),
      bottomLeft: Radius.circular(w * 0.2),
      bottomRight: Radius.circular(w * 0.2),
    );

    canvas.drawRRect(rrect, slimePaint);

    canvas.drawCircle(Offset(w * 0.15, -h * 0.1), 4, slimeGlow);
    canvas.drawCircle(Offset(-w * 0.15, -h * 0.1), 4, slimeGlow);

    canvas.drawCircle(Offset(w * 0.18, -h * 0.1), 2, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(-w * 0.12, -h * 0.1), 2, Paint()..color = Colors.black);

    final double bubbleY = -h * 0.4 + sin(time * 10) * 2;
    canvas.drawCircle(Offset(0, bubbleY), 3.5, slimeGlow);
  }

  void _drawShadowStalker(Canvas canvas, GameEntity enemy) {
    final double hover = sin(time * 5 + enemy.startX) * 4;
    final double w = enemy.width;
    final double h = enemy.height;

    final Paint shadowPaint = Paint()..color = GameColors.shadowEnemyBody;
    final Paint glowPaint = Paint()..color = GameColors.shadowEnemyGlow;

    final Path shadowPath = Path()
      ..moveTo(0, -h / 2 + hover)
      ..quadraticBezierTo(w / 2 + 6, -h / 4 + hover, w / 2, h / 4 + hover)
      ..quadraticBezierTo(w / 3, h / 2 + hover + 6, 0, h / 2 + hover)
      ..quadraticBezierTo(-w / 3, h / 2 + hover + 6, -w / 2, h / 4 + hover)
      ..quadraticBezierTo(-w / 2 - 6, -h / 4 + hover, 0, -h / 2 + hover)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);

    final Paint auraPaint = Paint()
      ..color = GameColors.shadowEnemyGlow.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(0, hover), w * 0.65, auraPaint);

    final Path eye1 = Path()
      ..moveTo(w * 0.05, -h * 0.1 + hover)
      ..lineTo(w * 0.3, -h * 0.15 + hover)
      ..lineTo(w * 0.22, -h * 0.02 + hover)
      ..close();

    final Path eye2 = Path()
      ..moveTo(-w * 0.05, -h * 0.1 + hover)
      ..lineTo(-w * 0.3, -h * 0.15 + hover)
      ..lineTo(-w * 0.22, -h * 0.02 + hover)
      ..close();

    canvas.drawPath(eye1, glowPaint);
    canvas.drawPath(eye2, glowPaint);
  }

  void _drawFireDemon(Canvas canvas, GameEntity enemy) {
    final double pulse = sin(time * 10 + enemy.startX) * 3;
    final double w = enemy.width + pulse;
    final double h = enemy.height;

    final Paint corePaint = Paint()..color = const Color(0xFFFF3300);
    final Paint flamePaint = Paint()..color = const Color(0xFFFFCC00);

    // Fiery body
    final Path path = Path()
      ..moveTo(0, -h / 2)
      ..lineTo(w / 2, 0)
      ..lineTo(w / 3, h / 2)
      ..lineTo(-w / 3, h / 2)
      ..lineTo(-w / 2, 0)
      ..close();

    canvas.drawPath(path, corePaint);

    // Glowing flame horns
    canvas.drawCircle(Offset(-w * 0.25, -h * 0.4), 6, flamePaint);
    canvas.drawCircle(Offset(w * 0.25, -h * 0.4), 6, flamePaint);

    // Yellow fiery eyes
    canvas.drawCircle(Offset(-w * 0.15, -h * 0.1), 3.5, flamePaint);
    canvas.drawCircle(Offset(w * 0.15, -h * 0.1), 3.5, flamePaint);
  }

  void _drawIceGolem(Canvas canvas, GameEntity enemy) {
    final double w = enemy.width;
    final double h = enemy.height;

    final Paint icePaint = Paint()..color = const Color(0xFF4EA8DE);
    final Paint glowPaint = Paint()..color = const Color(0xFFCAF0F8);

    // Angular ice crystal body
    final Path path = Path()
      ..moveTo(0, -h / 2)
      ..lineTo(w / 2 - 2, -h / 4)
      ..lineTo(w / 2, h / 3)
      ..lineTo(0, h / 2)
      ..lineTo(-w / 2, h / 3)
      ..lineTo(-w / 2 + 2, -h / 4)
      ..close();

    canvas.drawPath(path, icePaint);

    // Sharp icy highlights
    final Paint linePaint = Paint()
      ..color = const Color(0xFFCAF0F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, -h / 2), Offset(0, h / 2), linePaint);

    // Glowing ice blue eyes
    canvas.drawCircle(Offset(-w * 0.18, -h * 0.1), 3, glowPaint);
    canvas.drawCircle(Offset(w * 0.18, -h * 0.1), 3, glowPaint);
  }

  void _drawToxicBeast(Canvas canvas, GameEntity enemy) {
    final double w = enemy.width;
    final double h = enemy.height;

    final Paint toxicPaint = Paint()..color = const Color(0xFF5A189A);
    final Paint greenGlow = Paint()..color = const Color(0xFF00F5D4);

    final Rect rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, toxicPaint);

    // Toxic green glowing eyes
    canvas.drawCircle(Offset(-w * 0.18, -h * 0.15), 4, greenGlow);
    canvas.drawCircle(Offset(w * 0.18, -h * 0.15), 4, greenGlow);

    // Spitting poison bubbles
    final double b = sin(time * 6 + enemy.startX) * 3;
    canvas.drawCircle(Offset(0, -h * 0.4 + b), 4, greenGlow);
  }

  void _drawSpikes(Canvas canvas, GameEntity hazard) {
    final Paint spikePaint = Paint()..color = GameColors.hazardSpike;
    final Paint spikeGlowPaint = Paint()..color = GameColors.shadowEnemyGlow.withValues(alpha: 0.3);

    final double count = (hazard.width / 15).floorToDouble().clamp(1.0, 100.0);
    final double spikeW = hazard.width / count;

    for (int i = 0; i < count; i++) {
      final double sx = hazard.x + i * spikeW;
      final Path sPath = Path()
        ..moveTo(sx, hazard.y + hazard.height)
        ..lineTo(sx + spikeW / 2, hazard.y)
        ..lineTo(sx + spikeW, hazard.y + hazard.height)
        ..close();

      canvas.drawPath(sPath, spikePaint);
      canvas.drawCircle(Offset(sx + spikeW / 2, hazard.y + 3), 2.5, spikeGlowPaint);
    }
  }

  void _drawLavaPool(Canvas canvas, GameEntity hazard) {
    final Rect rect = hazard.bounds;
    final Paint lavaBase = Paint()..color = const Color(0xFFD90429);
    final Paint lavaGlow = Paint()..color = const Color(0xFFFF6B6B);
    final Paint bubblePaint = Paint()..color = const Color(0xFFFFD166);

    canvas.drawRect(rect, lavaBase);

    // Molten surface wave
    final Path wavePath = Path();
    wavePath.moveTo(rect.left, rect.top);
    for (double x = rect.left; x <= rect.right; x += 15) {
      final double wave = sin(x * 0.08 + time * 5) * 4;
      wavePath.lineTo(x, rect.top + wave);
    }
    wavePath.lineTo(rect.right, rect.bottom);
    wavePath.lineTo(rect.left, rect.bottom);
    wavePath.close();

    canvas.drawPath(wavePath, lavaGlow);

    // Bubbling magma bursts
    for (double x = rect.left + 20; x < rect.right - 10; x += 35) {
      final double bubble = sin(time * 4 + x) * 3;
      canvas.drawCircle(Offset(x, rect.top + 5 + bubble), 3.5, bubblePaint);
    }
  }

  void _drawPoisonPool(Canvas canvas, GameEntity hazard) {
    final Rect rect = hazard.bounds;
    final Paint poisonBase = Paint()..color = const Color(0xFF3C096C);
    final Paint toxicTop = Paint()..color = const Color(0xFF00F5D4);

    canvas.drawRect(rect, poisonBase);

    // Toxic surface wave
    final Path wavePath = Path();
    wavePath.moveTo(rect.left, rect.top);
    for (double x = rect.left; x <= rect.right; x += 15) {
      final double wave = sin(x * 0.1 + time * 4) * 3;
      wavePath.lineTo(x, rect.top + wave);
    }
    wavePath.lineTo(rect.right, rect.bottom);
    wavePath.lineTo(rect.left, rect.bottom);
    wavePath.close();

    canvas.drawPath(wavePath, toxicTop);

    // Poison gas bubbles
    for (double x = rect.left + 25; x < rect.right - 15; x += 40) {
      final double bubble = sin(time * 3 + x) * 4;
      canvas.drawCircle(Offset(x, rect.top + 4 + bubble), 4, toxicTop);
    }
  }

  void _drawLightningArc(Canvas canvas, GameEntity hazard) {
    final Rect rect = hazard.bounds;
    final Paint elecPaint = Paint()
      ..color = const Color(0xFFC77DFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Path bolt = Path();
    bolt.moveTo(rect.left, rect.top + rect.height / 2);

    for (double x = rect.left; x < rect.right; x += 20) {
      final double offset = (sin(x + time * 20) > 0 ? 1 : -1) * 8.0;
      bolt.lineTo(x + 10, rect.top + rect.height / 2 + offset);
    }
    bolt.lineTo(rect.right, rect.top + rect.height / 2);

    canvas.drawPath(bolt, elecPaint);
    canvas.drawRect(rect, Paint()..color = const Color(0x33C77DFF));
  }

  @override
  bool shouldRepaint(covariant EnemyPainter oldDelegate) => true;
}
