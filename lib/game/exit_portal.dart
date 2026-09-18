import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ExitPortal extends PositionComponent {
  double _time = 0;

  ExitPortal({required Vector2 position})
      : super(position: position, size: Vector2(60, 90));

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    // Outer swirling glow
    final glowPaint = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.5 + 0.2 * sin(_time))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.x + 20, height: size.y + 20),
      glowPaint,
    );

    // Arch structure
    final archPaint = Paint()
      ..color = const Color(0xFF3B0764)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromLTWH(4, 4, size.x - 8, size.y),
      pi,
      pi,
      false,
      archPaint,
    );

    // Inner Void / Portal swirl
    final portalPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFE9D5FF),
          Color(0xFFC084FC),
          Color(0xFF7E22CE),
          Color(0xFF2E1065),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawOval(
      Rect.fromLTWH(8, 12, size.x - 16, size.y - 16),
      portalPaint,
    );

    // Rotating Energy Rings
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_time);

    final ringPaint = Paint()
      ..color = const Color(0xFFF3E8FF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x * 0.6, height: size.y * 0.3),
      ringPaint,
    );

    canvas.rotate(pi / 3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x * 0.5, height: size.y * 0.25),
      ringPaint,
    );

    canvas.restore();
  }
}
