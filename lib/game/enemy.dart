import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ForestEnemy extends PositionComponent {
  final double leftBound;
  final double rightBound;
  double speed = 60.0;
  bool movingRight = true;
  bool isDefeated = false;
  double animationTime = 0.0;

  ForestEnemy({
    required Vector2 position,
    required this.leftBound,
    required this.rightBound,
  }) : super(position: position, size: Vector2(36, 32));

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) return;

    animationTime += dt * 6.0;

    // Patrol AI movement
    if (movingRight) {
      position.x += speed * dt;
      if (position.x >= rightBound) {
        position.x = rightBound;
        movingRight = false;
      }
    } else {
      position.x -= speed * dt;
      if (position.x <= leftBound) {
        position.x = leftBound;
        movingRight = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (isDefeated) return;

    final center = Offset(size.x / 2, size.y / 2);

    // Dark Forest Creature (Mushroom Spore / Slime Hybrid)
    final creaturePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFEF4444), // Crimson Glowing Core
          Color(0xFF991B1B), // Dark Burgundy Body
          Color(0xFF450A0A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    final floatY = sin(animationTime) * 2;
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 4 + floatY, size.x - 4, size.y - 8),
      const Radius.circular(12),
    );
    canvas.drawRRect(bodyRRect, creaturePaint);

    // Glowing Red Eyes
    final eyeGlow = Paint()
      ..color = const Color(0xFFFCA5A5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final eyePaint = Paint()..color = Colors.white;

    final eyeOffsetX = movingRight ? 6.0 : -6.0;
    canvas.drawCircle(Offset(center.dx + eyeOffsetX - 4, center.dy - 2), 3, eyeGlow);
    canvas.drawCircle(Offset(center.dx + eyeOffsetX + 4, center.dy - 2), 3, eyeGlow);

    canvas.drawCircle(Offset(center.dx + eyeOffsetX - 4, center.dy - 2), 2, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeOffsetX + 4, center.dy - 2), 2, eyePaint);

    // Spikes/Mushroom Cap Cap Details
    final capPaint = Paint()..color = const Color(0xFFDC2626);
    for (double i = 6; i < size.x - 6; i += 8) {
      canvas.drawCircle(Offset(i, 6 + floatY), 3, capPaint);
    }
  }
}
