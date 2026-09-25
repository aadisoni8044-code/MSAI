import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/zombie_entity.dart';
import 'package:enchanted_forest_adventure/models/weapon_drop_entity.dart';

class ZombiePainter extends CustomPainter {
  final List<ZombieEntity> zombies;
  final WeaponDropEntity? activeWeaponDrop;
  final double cameraX;
  final double cameraY;
  final double time;

  ZombiePainter({
    required this.zombies,
    this.activeWeaponDrop,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    // Draw active weapon supply drop if present
    if (activeWeaponDrop != null && !activeWeaponDrop!.isPickedUp) {
      _drawWeaponDrop(canvas, activeWeaponDrop!);
    }

    for (final zombie in zombies) {
      if (zombie.state == ZombieState.dead) continue;
      if (zombie.x + zombie.width < cameraX - 50 || zombie.x > cameraX + size.width + 50) continue;

      _drawZombie(canvas, zombie);
    }

    canvas.restore();
  }

  void _drawWeaponDrop(Canvas canvas, WeaponDropEntity drop) {
    canvas.save();
    canvas.translate(drop.x + drop.width / 2, drop.y + drop.height / 2);

    final Paint cratePaint = Paint()..color = const Color(0xFF10B981);
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Paint glowMask = Paint()
      ..color = const Color(0xAA10B981)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Draw Parachute if falling
    if (!drop.isLanded) {
      final Path parachute = Path()
        ..moveTo(-35, -35)
        ..quadraticBezierTo(0, -65, 35, -35)
        ..close();

      final Paint chutePaint = Paint()..color = const Color(0xEEFFFFFF);
      canvas.drawPath(parachute, chutePaint);

      final Paint linePaint = Paint()
        ..color = Colors.white70
        ..strokeWidth = 1.5;
      canvas.drawLine(const Offset(-35, -35), const Offset(-10, -15), linePaint);
      canvas.drawLine(const Offset(35, -35), const Offset(10, -15), linePaint);
    }

    // Glowing Aura
    canvas.drawCircle(Offset.zero, drop.width * 0.7, glowMask);

    // Crate Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-drop.width / 2, -drop.height / 2, drop.width, drop.height),
        const Radius.circular(8),
      ),
      cratePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-drop.width / 2, -drop.height / 2, drop.width, drop.height),
        const Radius.circular(8),
      ),
      borderPaint,
    );

    // Weapon Icon
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🔫',
        style: TextStyle(fontSize: 22),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    // Floating Pickup Prompt when landed
    if (drop.isLanded) {
      final double bounce = sin(time * 6) * 4;
      final promptPainter = TextPainter(
        text: const TextSpan(
          text: '⚡ WALK NEAR TO PICK UP AK-47 ⚡',
          style: TextStyle(
            color: Color(0xFF10B981),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 6)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      promptPainter.layout();
      promptPainter.paint(canvas, Offset(-promptPainter.width / 2, -drop.height / 2 - 20 + bounce));
    }

    canvas.restore();
  }

  void _drawZombie(Canvas canvas, ZombieEntity zombie) {
    canvas.save();

    final centerX = zombie.x + zombie.width / 2;
    final centerY = zombie.y + zombie.height / 2;
    canvas.translate(centerX, centerY);

    if (!zombie.facingRight) {
      canvas.scale(-1.0, 1.0);
    }

    final bool isHit = zombie.hitTimer > 0;

    if (zombie.zombieType == ZombieType.large) {
      _drawLargeZombie(canvas, zombie, isHit);
    } else if (zombie.zombieType == ZombieType.fast) {
      _drawFastZombie(canvas, zombie, isHit);
    } else {
      _drawNormalZombie(canvas, zombie, isHit);
    }

    if (zombie.zombieType == ZombieType.large && zombie.health > 0) {
      _drawHealthBar(canvas, zombie);
    }

    canvas.restore();
  }

  void _drawLargeZombie(Canvas canvas, ZombieEntity zombie, bool isHit) {
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

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2, -h / 2 + 12, w, h - 16), const Radius.circular(10)), bodyPaint);
    canvas.drawRect(Rect.fromLTWH(-w / 4, -h / 4, 16, 6), woundPaint);
    canvas.drawRect(Rect.fromLTWH(2, -h / 6, 12, 14), woundPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 3, -h / 2 - 6, w * 0.66, 22), const Radius.circular(6)), bodyPaint);

    canvas.drawCircle(Offset(w / 8, -h / 2 + 4), 5, eyeGlowMask);
    canvas.drawCircle(Offset(w / 8, -h / 2 + 4), 3, eyePaint);

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

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2 + 4, -h / 2 + 10, w - 8, h - 14), const Radius.circular(6)), bodyPaint);
    canvas.drawCircle(Offset(0, -h / 2 + 4), 12, bodyPaint);
    canvas.drawCircle(Offset(4, -h / 2 + 3), 3, eyePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, -h / 4, 16, 8), const Radius.circular(4)), bodyPaint);
  }

  void _drawFastZombie(Canvas canvas, ZombieEntity zombie, bool isHit) {
    final Color bodyColor = isHit ? const Color(0xFFFF4D4D) : const Color(0xFF16251C);
    final Color eyeGlow = const Color(0xFFFF0033);

    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint eyePaint = Paint()..color = eyeGlow;

    final double w = zombie.width;
    final double h = zombie.height;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2 + 4, -h / 2 + 8, w - 8, h - 10), const Radius.circular(5)), bodyPaint);
    canvas.drawCircle(Offset(2, -h / 2 + 3), 9, bodyPaint);
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
