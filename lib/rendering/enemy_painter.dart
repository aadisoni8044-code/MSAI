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
      if (enemy.x + enemy.width < cameraX - 50 || enemy.x > cameraX + size.width + 50) continue;

      canvas.save();
      canvas.translate(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2);

      if (enemy.vx < 0) {
        canvas.scale(-1.0, 1.0);
      }

      if (enemy.type == EntityType.enemySlime) {
        _drawSlime(canvas, enemy);
      } else if (enemy.type == EntityType.enemyShadow) {
        _drawShadowStalker(canvas, enemy);
      }

      canvas.restore();
    }

    // Render Spikes / Hazards
    final Paint spikePaint = Paint()..color = GameColors.hazardSpike;
    final Paint spikeGlowPaint = Paint()..color = GameColors.shadowEnemyGlow.withValues(alpha: 0.3);

    for (final spike in levelData.hazards) {
      if (spike.x + spike.width < cameraX - 50 || spike.x > cameraX + size.width + 50) continue;

      final double count = (spike.width / 15).floorToDouble();
      final double spikeW = spike.width / count;

      for (int i = 0; i < count; i++) {
        final double sx = spike.x + i * spikeW;
        final Path sPath = Path()
          ..moveTo(sx, spike.y + spike.height)
          ..lineTo(sx + spikeW / 2, spike.y)
          ..lineTo(sx + spikeW, spike.y + spike.height)
          ..close();

        canvas.drawPath(sPath, spikePaint);

        // Glowing red tips
        canvas.drawCircle(Offset(sx + spikeW / 2, spike.y + 3), 2.5, spikeGlowPaint);
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

    // Glowing Eyes
    canvas.drawCircle(Offset(w * 0.15, -h * 0.1), 4, slimeGlow);
    canvas.drawCircle(Offset(-w * 0.15, -h * 0.1), 4, slimeGlow);

    canvas.drawCircle(Offset(w * 0.18, -h * 0.1), 2, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(-w * 0.12, -h * 0.1), 2, Paint()..color = Colors.black);

    // Spore Bubbles
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

    // Floating Shadow Aura
    final Paint auraPaint = Paint()
      ..color = GameColors.shadowEnemyGlow.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(0, hover), w * 0.65, auraPaint);

    // Sharp Glowing Red Eyes
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

  @override
  bool shouldRepaint(covariant EnemyPainter oldDelegate) => true;
}
