import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'forest_game.dart';

class ParallaxForestBackground extends Component with HasGameReference<ForestGame> {
  final Vector2 worldBounds;

  ParallaxForestBackground({required this.worldBounds});

  @override
  void render(Canvas canvas) {
    final cameraX = game.camera.viewfinder.position.x;
    final sizeX = worldBounds.x;
    final sizeY = worldBounds.y;

    // Layer 0: Deep Atmospheric Gradient (Teal / Dark Blue)
    final bgGradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF04101E),
          Color(0xFF0D253A),
          Color(0xFF133B4D),
          Color(0xFF091D28),
        ],
        stops: [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, sizeX, sizeY));
    canvas.drawRect(Rect.fromLTWH(0, 0, sizeX, sizeY), bgGradient);

    // Distant soft moon / magical canopy glow
    final moonGlow = Paint()
      ..color = const Color(0xFF64FFDA).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(sizeX * 0.3, sizeY * 0.25), 180, moonGlow);

    // Layer 1: Far Silhouette Mountains & Ancient Trees (Scroll factor 0.1)
    _renderFarTrees(canvas, cameraX * 0.1, sizeX, sizeY);

    // Layer 2: Mid-distance Twisted Trees & Canopy (Scroll factor 0.25)
    _renderMidForest(canvas, cameraX * 0.25, sizeX, sizeY);

    // Layer 3: Near Forest Vines & Glowing Spores (Scroll factor 0.5)
    _renderNearVines(canvas, cameraX * 0.5, sizeX, sizeY);
  }

  void _renderFarTrees(Canvas canvas, double offsetX, double width, double height) {
    final paint = Paint()
      ..color = const Color(0xFF0A3042).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, height);
    for (double x = 0; x <= width + 100; x += 120) {
      final treeHeight = 220 + sin(x * 0.01) * 60;
      path.lineTo(x, height - treeHeight);
      path.lineTo(x + 40, height - treeHeight - 30);
      path.lineTo(x + 80, height - treeHeight + 20);
    }
    path.lineTo(width + 200, height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _renderMidForest(Canvas canvas, double offsetX, double width, double height) {
    final paintTree = Paint()
      ..color = const Color(0xFF0A222D)
      ..style = PaintingStyle.fill;

    final paintLeaf = Paint()
      ..color = const Color(0xFF0F3A3E)
      ..style = PaintingStyle.fill;

    for (double x = -offsetX % 200 - 100; x < width + 200; x += 220) {
      final trunkX = x;
      final trunkWidth = 35.0;
      final trunkHeight = 320.0;
      final trunkRect = Rect.fromLTWH(trunkX, height - trunkHeight, trunkWidth, trunkHeight);

      canvas.drawRect(trunkRect, paintTree);

      // Curved twisted branch
      final branchPath = Path();
      branchPath.moveTo(trunkX + trunkWidth / 2, height - trunkHeight + 80);
      branchPath.quadraticBezierTo(
        trunkX - 50, height - trunkHeight + 20,
        trunkX - 80, height - trunkHeight - 30,
      );
      branchPath.lineTo(trunkX - 70, height - trunkHeight - 25);
      branchPath.close();
      canvas.drawPath(branchPath, paintTree);

      // Canopy foliage clusters
      canvas.drawCircle(Offset(trunkX + 15, height - trunkHeight - 20), 70, paintLeaf);
      canvas.drawCircle(Offset(trunkX - 40, height - trunkHeight + 10), 50, paintLeaf);
      canvas.drawCircle(Offset(trunkX + 60, height - trunkHeight + 15), 55, paintLeaf);
    }
  }

  void _renderNearVines(Canvas canvas, double offsetX, double width, double height) {
    final vinePaint = Paint()
      ..color = const Color(0xFF134E4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final leafPaint = Paint()
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.fill;

    for (double x = -offsetX % 150 - 50; x < width + 150; x += 150) {
      final vinePath = Path();
      vinePath.moveTo(x, 0);
      final vineLength = 100 + sin(x) * 40;
      vinePath.quadraticBezierTo(x + 15, vineLength / 2, x - 10, vineLength);
      canvas.drawPath(vinePath, vinePaint);

      // Hanging leaves on vine
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - 10, vineLength), width: 12, height: 18),
        leafPaint,
      );
    }
  }
}
