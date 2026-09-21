import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class LobbyBackgroundPainter extends CustomPainter {
  final double time;
  final double parallaxOffsetX;

  LobbyBackgroundPainter({
    required this.time,
    this.parallaxOffsetX = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Deep Night Sky Gradient
    final Rect skyRect = Rect.fromLTWH(0, 0, w, h);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF040817),
          Color(0xFF0B192C),
          Color(0xFF1E3A5F),
          GameColors.deepForestTeal,
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Full Moon & Soft Aura
    final Offset moonCenter = Offset(w * 0.78 + parallaxOffsetX * 0.05, h * 0.22);
    final Paint moonGlow = Paint()
      ..color = const Color(0x6680FFDB)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(moonCenter, 70, moonGlow);

    final Paint moonPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFC77DFF), Color(0xFF72EFDD)],
        stops: [0.3, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 32));
    canvas.drawCircle(moonCenter, 32, moonPaint);

    // 3. Layer 1: Distant Mountain Silhouettes
    _drawMountains(canvas, size, parallaxOffsetX * 0.15);

    // 4. Layer 2: Moving Mist / Fog
    _drawMistLayer(canvas, size);

    // 5. Layer 3: Forest Tree Silhouettes
    _drawForestLayer(canvas, size, parallaxOffsetX * 0.35);

    // 6. Layer 4: Floating Fireflies / Spores
    _drawFireflies(canvas, size);
  }

  void _drawMountains(Canvas canvas, Size size, double offset) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    final double startX = -100 + offset;
    path.moveTo(startX, h);
    path.lineTo(startX, h * 0.55);
    path.quadraticBezierTo(startX + w * 0.2, h * 0.38, startX + w * 0.35, h * 0.50);
    path.quadraticBezierTo(startX + w * 0.5, h * 0.32, startX + w * 0.7, h * 0.48);
    path.quadraticBezierTo(startX + w * 0.85, h * 0.35, startX + w + 200, h * 0.55);
    path.lineTo(startX + w + 200, h);
    path.close();

    final Paint mountainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F1E2E), Color(0xFF0A1522)],
      ).createShader(Rect.fromLTWH(0, h * 0.3, w, h * 0.7));

    canvas.drawPath(path, mountainPaint);
  }

  void _drawMistLayer(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double fogOffset = sin(time * 0.8) * 30;

    final Rect fogRect = Rect.fromLTWH(-50 + fogOffset, h * 0.45, w + 100, h * 0.3);
    final Paint fogPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x0080FFDB),
          Color(0x2280FFDB),
          Color(0x0080FFDB),
        ],
      ).createShader(fogRect);

    canvas.drawRect(fogRect, fogPaint);
  }

  void _drawForestLayer(Canvas canvas, Size size, double offset) {
    final double w = size.width;
    final double h = size.height;
    final Paint treePaint = Paint()..color = const Color(0xFF060F17);

    final double startX = -80 + offset;

    // Draw stylized pine/oak tree silhouettes
    for (double x = startX; x < w + 150; x += 90) {
      final treeH = 140 + sin(x * 0.05) * 40;
      final Path tree = Path();
      tree.moveTo(x, h);
      tree.lineTo(x + 15, h - treeH * 0.3);
      tree.lineTo(x - 20, h - treeH * 0.25);
      tree.lineTo(x + 10, h - treeH * 0.6);
      tree.lineTo(x - 15, h - treeH * 0.55);
      tree.lineTo(x + 5, h - treeH);
      tree.lineTo(x + 25, h - treeH * 0.55);
      tree.lineTo(x + 10, h - treeH * 0.6);
      tree.lineTo(x + 35, h - treeH * 0.25);
      tree.lineTo(x + 20, h - treeH * 0.3);
      tree.lineTo(x + 30, h);
      tree.close();

      canvas.drawPath(tree, treePaint);
    }
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Random rand = Random(42);

    for (int i = 0; i < 24; i++) {
      final baseDx = rand.nextDouble() * w;
      final baseDy = rand.nextDouble() * h * 0.8 + h * 0.1;
      final floatX = sin(time * 2 + i) * 18;
      final floatY = cos(time * 1.5 + i) * 12;
      final pulse = (sin(time * 4 + i) + 1.0) / 2.0;

      final Offset pos = Offset((baseDx + floatX) % w, (baseDy + floatY) % h);
      final double radius = 1.5 + pulse * 2.5;

      final Paint fireflyGlow = Paint()
        ..color = GameColors.playerGlow.withValues(alpha: 0.3 + pulse * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final Paint fireflyCore = Paint()
        ..color = Color.lerp(const Color(0xFF80FFDB), const Color(0xFFFFD166), pulse)!;

      canvas.drawCircle(pos, radius * 2.5, fireflyGlow);
      canvas.drawCircle(pos, radius, fireflyCore);
    }
  }

  @override
  bool shouldRepaint(covariant LobbyBackgroundPainter oldDelegate) => true;
}
