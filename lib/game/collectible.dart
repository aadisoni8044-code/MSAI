import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GlowingCrystal extends PositionComponent {
  final int value;
  bool isCollected = false;
  double _animationTime = 0;
  final double _initialY;

  GlowingCrystal({
    required Vector2 position,
    this.value = 1,
  })  : _initialY = position.y,
        super(position: position, size: Vector2(24, 28));

  @override
  void update(double dt) {
    super.update(dt);
    if (isCollected) return;

    _animationTime += dt * 3.5;
    // Gentle floating bob animation
    position.y = _initialY + sin(_animationTime) * 4.0;
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;

    final center = Offset(size.x / 2, size.y / 2);

    // Glowing Aura
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4 + 0.2 * sin(_animationTime))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, 14, glowPaint);

    // Crystal Diamond Shape
    final path = Path()
      ..moveTo(size.x / 2, 0) // Top vertex
      ..lineTo(size.x, size.y * 0.4) // Right vertex
      ..lineTo(size.x / 2, size.y) // Bottom vertex
      ..lineTo(0, size.y * 0.4) // Left vertex
      ..close();

    final crystalGradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE0F7FA),
          Color(0xFF00E5FF),
          Color(0xFF00838F),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawPath(path, crystalGradient);

    // Facet Highlight line
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final linePath = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x / 2, size.y)
      ..moveTo(0, size.y * 0.4)
      ..lineTo(size.x, size.y * 0.4);

    canvas.drawPath(linePath, highlight);
  }
}
