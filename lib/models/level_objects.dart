import 'package:flutter/material.dart';

enum PlatformType { grassGround, woodenBridge, floatingStone, vineThick }

class PlatformBlock {
  final Rect bounds;
  final PlatformType type;

  const PlatformBlock({
    required this.bounds,
    this.type = PlatformType.grassGround,
  });

  double get x => bounds.left;
  double get y => bounds.top;
  double get width => bounds.width;
  double get height => bounds.height;
}

enum CollectibleType { glowingCrystal, goldCoin }

class Collectible {
  final String id;
  final Offset position;
  final Size size;
  final CollectibleType type;
  bool isCollected;
  double animTimer;

  Collectible({
    required this.id,
    required this.position,
    this.size = const Size(22, 22),
    this.type = CollectibleType.glowingCrystal,
  })  : isCollected = false,
        animTimer = 0.0;

  void update(double dt) {
    animTimer += dt * 3.0;
  }

  Rect get bounds => Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}

class Checkpoint {
  final String id;
  final Offset position;
  final Size size;
  bool isActivated;

  Checkpoint({
    required this.id,
    required this.position,
    this.size = const Size(32, 50),
  }) : isActivated = false;

  Rect get bounds => Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}

class ExitPortal {
  final Offset position;
  final Size size;

  ExitPortal({
    required this.position,
    this.size = const Size(48, 70),
  });

  Rect get bounds => Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}
