import 'package:flutter/material.dart';

class Camera2D {
  Offset position;
  final Size viewportSize;
  final double worldWidth;
  final double worldHeight;
  final double smoothSpeed;

  Camera2D({
    required this.viewportSize,
    required this.worldWidth,
    required this.worldHeight,
    this.smoothSpeed = 5.0,
  }) : position = Offset.zero;

  void follow(Offset targetPosition, double dt) {
    // Center camera on target horizontally
    final double targetX = targetPosition.dx - (viewportSize.width / 2);
    // Keep camera bounded to world boundaries
    final double clampedX = targetX.clamp(0.0, (worldWidth - viewportSize.width).clamp(0.0, double.infinity));

    // Smooth interpolation
    final double newX = position.dx + (clampedX - position.dx) * (smoothSpeed * dt).clamp(0.0, 1.0);

    // For vertical, keep ground visible or slightly follow
    final double targetY = (targetPosition.dy - (viewportSize.height * 0.6)).clamp(
      0.0,
      (worldHeight - viewportSize.height).clamp(0.0, double.infinity),
    );
    final double newY = position.dy + (targetY - position.dy) * (smoothSpeed * dt).clamp(0.0, 1.0);

    position = Offset(newX, newY);
  }

  Rect get visibleArea => Rect.fromLTWH(position.dx, position.dy, viewportSize.width, viewportSize.height);

  Offset worldToScreen(Offset worldCoord) {
    return worldCoord - position;
  }
}
