import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ForestPlatform extends PositionComponent {
  final bool isOneWay;
  final bool isHiddenArea;
  final Color baseColor;
  final Color topMossColor;

  ForestPlatform({
    required Vector2 position,
    required Vector2 size,
    this.isOneWay = false,
    this.isHiddenArea = false,
    this.baseColor = const Color(0xFF1E293B),
    this.topMossColor = const Color(0xFF10B981),
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // Base Bark / Stone Body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isHiddenArea
            ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
            : [baseColor, const Color(0xFF0F172A)],
      ).createShader(rect);
    canvas.drawRRect(rrect, bodyPaint);

    // Platform Top Grass & Moss Layer
    final mossHeight = (size.y * 0.25).clamp(4.0, 10.0);
    final mossRect = Rect.fromLTWH(0, 0, size.x, mossHeight);
    final mossPaint = Paint()
      ..shader = LinearGradient(
        colors: isHiddenArea
            ? [const Color(0xFFA855F7), const Color(0xFF6366F1)]
            : [const Color(0xFF34D399), topMossColor],
      ).createShader(mossRect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        mossRect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      mossPaint,
    );

    // Decorative Grass Blades & Hanging Vines on Platform
    final detailPaint = Paint()
      ..color = isHiddenArea ? const Color(0xFFC084FC) : const Color(0xFF6EE7B7)
      ..style = PaintingStyle.fill;

    for (double x = 8; x < size.x - 8; x += 16) {
      final path = Path()
        ..moveTo(x - 3, 0)
        ..lineTo(x, -5)
        ..lineTo(x + 3, 0)
        ..close();
      canvas.drawPath(path, detailPaint);
    }

    // Small hanging vines underneath
    final vinePaint = Paint()
      ..color = isHiddenArea
          ? const Color(0xFF818CF8).withValues(alpha: 0.7)
          : const Color(0xFF059669).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double x = 20; x < size.x - 20; x += 35) {
      final vinePath = Path()
        ..moveTo(x, size.y)
        ..quadraticBezierTo(x + 4, size.y + 12, x - 2, size.y + 18);
      canvas.drawPath(vinePath, vinePaint);
    }

    // Outer subtle border glow
    final borderPaint = Paint()
      ..color = (isHiddenArea ? const Color(0xFFC084FC) : const Color(0xFF34D399))
          .withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }
}
