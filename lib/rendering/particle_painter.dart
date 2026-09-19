import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double cameraX;
  final double cameraY;
  final double time;

  ParticlePainter({
    required this.particles,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawAmbientSpores(canvas, size);
    _drawFallingLeaves(canvas, size);
    _drawDynamicParticles(canvas, size);
  }

  void _drawAmbientSpores(Canvas canvas, Size size) {
    final Paint sporeGlow = Paint()
      ..color = GameColors.foliageGlow.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final Paint sporeCore = Paint()..color = Colors.white.withValues(alpha: 0.8);

    for (int i = 0; i < 25; i++) {
      final double sx = ((i * 157.3 + time * 18) % (size.width + 100)) - 50;
      final double sy = ((i * 91.7 + sin(time * 0.8 + i) * 30) % (size.height + 100)) - 50;
      final double sizePulse = 2.0 + sin(time * 2 + i) * 1.0;

      canvas.drawCircle(Offset(sx, sy), sizePulse * 2, sporeGlow);
      canvas.drawCircle(Offset(sx, sy), sizePulse * 0.8, sporeCore);
    }
  }

  void _drawFallingLeaves(Canvas canvas, Size size) {
    final Paint leafPaint = Paint()..color = GameColors.mossyGreenBright.withValues(alpha: 0.7);

    for (int i = 0; i < 12; i++) {
      final double lx = ((i * 213.1 + time * 35 + sin(time + i) * 40) % (size.width + 120)) - 60;
      final double ly = ((i * 127.4 + time * 25) % (size.height + 100)) - 50;
      final double rot = time * 2 + i;

      canvas.save();
      canvas.translate(lx, ly);
      canvas.rotate(rot);

      final Path leafPath = Path()
        ..moveTo(0, -6)
        ..quadraticBezierTo(5, 0, 0, 6)
        ..quadraticBezierTo(-5, 0, 0, -6)
        ..close();

      canvas.drawPath(leafPath, leafPaint);
      canvas.restore();
    }
  }

  void _drawDynamicParticles(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    for (final p in particles) {
      if (p.isDead) continue;
      final double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      final Paint pPaint = Paint()
        ..color = p.color.withValues(alpha: p.color.a * opacity);

      canvas.drawCircle(Offset(p.x, p.y), p.size * opacity, pPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
