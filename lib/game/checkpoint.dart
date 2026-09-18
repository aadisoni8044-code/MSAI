import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CheckpointBanner extends PositionComponent {
  bool isActivated = false;
  double _time = 0;

  CheckpointBanner({required Vector2 position})
      : super(position: position, size: Vector2(36, 64));

  void activate() {
    isActivated = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt * 2.5;
  }

  @override
  void render(Canvas canvas) {
    // Pole
    final polePaint = Paint()..color = const Color(0xFF64748B);
    canvas.drawRect(Rect.fromLTWH(4, 0, 6, size.y), polePaint);

    // Orb at top of pole
    final orbColor = isActivated ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final orbPaint = Paint()..color = orbColor;
    canvas.drawCircle(const Offset(7, 4), 8, orbPaint);

    if (isActivated) {
      final glowPaint = Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(const Offset(7, 4), 14, glowPaint);
    }

    // Waving Banner
    final bannerPaint = Paint()
      ..color = isActivated ? const Color(0xFF10B981) : const Color(0xFF475569);

    final bannerPath = Path();
    bannerPath.moveTo(10, 8);
    final waveOffset = sin(_time) * 3;
    bannerPath.quadraticBezierTo(22, 12 + waveOffset, 34, 10);
    bannerPath.lineTo(34, 32);
    bannerPath.quadraticBezierTo(22, 34 + waveOffset, 10, 30);
    bannerPath.close();

    canvas.drawPath(bannerPath, bannerPaint);
  }
}
