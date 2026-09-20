import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/zombie_entity.dart';

class ZombiePainter extends CustomPainter {
  final List<ZombieEntity> zombies;
  final double cameraX;
  final double cameraY;
  final double time;

  ZombiePainter({
    required this.zombies,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    for (final zombie in zombies) {
      if (zombie.state == ZombieState.dead) continue;
      if (zombie.x + zombie.width < cameraX - 50 || zombie.x > cameraX + size.width + 50) continue;

      _drawZombie(canvas, zombie);
    }

    canvas.restore();
  }

  void _drawZombie(Canvas canvas, ZombieEntity zombie) {
    canvas.save();

    // Flip X if facing left
    final centerX = zombie.x + zombie.width / 2;
    final centerY = zombie.y + zombie.height / 2;
    canvas.translate(centerX, centerY);

    if (!zombie.facingRight) {
      canvas.scale(-1.0, 1.0);
    }

    // Hit flash tint
    final bool isHit = zombie.hitTimer > 0;

    if (zombie.zombieType == ZombieType.large) {
      _drawLargeZombie(canvas, zombie, isHit);
    } else if (zombie.zombieType == ZombieType.fast) {
      _drawFastZombie(canvas, zombie, isHit);
    } else {
      _drawNormalZombie(canvas, zombie, isHit);
    }

    // Health Bar overhead for Large Zombies
    if (zombie.zombieType == ZombieType.large && zombie.health > 0) {
      _drawHealthBar(canvas, zombie);
    }

    canvas.restore();
  }

  void _drawLargeZombie(Canvas canvas, ZombieEntity zombie, bool isHit) {
    // Large Zombie Specs: Deep green / almost black body + reddish wounds + orange-red glowing eyes
    final Color bodyColor = isHit ? const Color(0xFFFF4D4D) : const Color(0xFF0D1F13);
    final Color woundColor = const Color(0xFF8B0000);
    final Color eyeGlow = const Color(0xFFFF3300);

    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint woundPaint = Paint()..color = woundColor;
    final Paint eyePaint = Paint()..color = eyeGlow;
    final Paint eyeGlowMask = Paint()
      ..color = eyeGlow.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final double w = zombie.width;
    final double h = zombie.height;

    // Muscular Torso & Legs
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2, -h / 2 + 12, w, h - 16), const Radius.circular(10)), bodyPaint);

    // Reddish Wounds on Chest
    canvas.drawRect(Rect.fromLTWH(-w / 4, -h / 4, 16, 6), woundPaint);
    canvas.drawRect(Rect.fromLTWH(2, -h / 6, 12, 14), woundPaint);

    // Large Head
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 3, -h / 2 - 6, w * 0.66, 22), const Radius.circular(6)), bodyPaint);

    // Orange-Red Glowing Eyes
    canvas.drawCircle(Offset(w / 8, -h / 2 + 4), 5, eyeGlowMask);
    canvas.drawCircle(Offset(w / 8, -h / 2 + 4), 3, eyePaint);

    // Heavy Arms
    final armWalkOffset = sin(time * 8) * 8;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w / 4, -h / 4 + armWalkOffset, 14, h * 0.5), const Radius.circular(6)), bodyPaint);
  }

  void _drawNormalZombie(Canvas canvas, ZombieEntity zombie, bool isHit) {
    final Color bodyColor = isHit ? const Color(0xFFFF4D4D) : const Color(0xFF1E2D24);
    final Color eyeGlow = const Color(0xFFFF5500);

    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint eyePaint = Paint()..color = eyeGlow;

    final double w = zombie.width;
    final double h = zombie.height;

    // Torso
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2 + 4, -h / 2 + 10, w - 8, h - 14), const Radius.circular(6)), bodyPaint);

    // Head
    canvas.drawCircle(Offset(0, -h / 2 + 4), 12, bodyPaint);

    // Glowing Orange/Red Eye
    canvas.drawCircle(Offset(4, -h / 2 + 3), 3, eyePaint);

    // Outstretched Arm
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, -h / 4, 16, 8), const Radius.circular(4)), bodyPaint);
  }

  void _drawFastZombie(Canvas canvas, ZombieEntity zombie, bool isHit) {
    final Color bodyColor = isHit ? const Color(0xFFFF4D4D) : const Color(0xFF16251C);
    final Color eyeGlow = const Color(0xFFFF0033);

    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint eyePaint = Paint()..color = eyeGlow;

    final double w = zombie.width;
    final double h = zombie.height;

    // Lean Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2 + 4, -h / 2 + 8, w - 8, h - 10), const Radius.circular(5)), bodyPaint);

    // Head
    canvas.drawCircle(Offset(2, -h / 2 + 3), 9, bodyPaint);

    // Sharp Red Glowing Eye
    canvas.drawCircle(Offset(5, -h / 2 + 2), 2.5, eyePaint);
  }

  void _drawHealthBar(Canvas canvas, ZombieEntity zombie) {
    const double barWidth = 48.0;
    const double barHeight = 6.0;
    final double topY = -zombie.height / 2 - 16;

    final Paint bgPaint = Paint()..color = Colors.black87;
    final Paint fillPaint = Paint()..color = const Color(0xFFFF3333);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, topY, barWidth, barHeight), const Radius.circular(3)),
      bgPaint,
    );

    final double healthPercent = (zombie.health / zombie.maxHealth).clamp(0.0, 1.0);
    if (healthPercent > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, topY, barWidth * healthPercent, barHeight), const Radius.circular(3)),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ZombiePainter oldDelegate) => true;
}
