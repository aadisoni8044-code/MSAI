import 'package:flutter/material.dart';

class WeaponDropEntity {
  final String id;
  final String weaponId;
  final String weaponName;
  double x;
  double y;
  double vy;
  double width;
  double height;
  bool isLanded;
  bool isPickedUp;

  WeaponDropEntity({
    required this.id,
    required this.weaponId,
    required this.weaponName,
    required this.x,
    this.y = 20.0,
    this.vy = 2.5,
    this.width = 46.0,
    this.height = 46.0,
    this.isLanded = false,
    this.isPickedUp = false,
  });

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  void update(double dt, List<Rect> platformRects) {
    if (isPickedUp || isLanded) return;

    vy += 0.35; // Parachute/gravity speed
    if (vy > 6.0) vy = 6.0; // Terminal parachute velocity

    y += vy;

    // Check collision with platform or ground
    const double groundY = 654.0;
    if (y >= groundY) {
      y = groundY;
      vy = 0;
      isLanded = true;
      return;
    }

    final box = bounds;
    for (final plat in platformRects) {
      if (box.overlaps(plat) && vy > 0) {
        y = plat.top - height;
        vy = 0;
        isLanded = true;
        break;
      }
    }
  }
}
