import 'package:flutter/material.dart';

enum PlatformType {
  normal,
  moving,
  crumbling,
  passThrough,
  spike,
}

class PlatformModel {
  final String id;
  double x;
  double y;
  final double width;
  final double height;
  final PlatformType type;
  final double moveMinX;
  final double moveMaxX;
  final double moveSpeed;
  int moveDirection;
  bool isBroken;
  double crumbleTimer;

  PlatformModel({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.type = PlatformType.normal,
    this.moveMinX = 0,
    this.moveMaxX = 0,
    this.moveSpeed = 0,
    this.moveDirection = 1,
    this.isBroken = false,
    this.crumbleTimer = 0,
  });

  Rect get rect => Rect.fromLTWH(x, y, width, height);
}

enum CollectibleType {
  energyCrystal,
  coin,
  healthPickup,
  secretRune,
}

class CollectibleModel {
  final String id;
  final double x;
  final double y;
  final CollectibleType type;
  bool isCollected;
  double animTimer;

  CollectibleModel({
    required this.id,
    required this.x,
    required this.y,
    required this.type,
    this.isCollected = false,
    this.animTimer = 0.0,
  });

  Rect get rect => Rect.fromLTWH(x - 12, y - 12, 24, 24);
}

class CheckpointModel {
  final String id;
  final double x;
  final double y;
  bool isActive;

  CheckpointModel({
    required this.id,
    required this.x,
    required this.y,
    this.isActive = false,
  });

  Rect get rect => Rect.fromLTWH(x - 16, y - 48, 32, 48);
}

class LevelModel {
  final int id;
  final String name;
  final String subtitle;
  final double worldWidth;
  final double worldHeight;
  final Offset spawnPoint;
  final Rect exitPortal;
  final Color primaryColor;
  final Color secondaryColor;
  final Color fogColor;

  final List<PlatformModel> platforms;
  final List<CollectibleModel> collectibles;
  final List<CheckpointModel> checkpoints;

  LevelModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.worldWidth,
    required this.worldHeight,
    required this.spawnPoint,
    required this.exitPortal,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fogColor,
    required this.platforms,
    required this.collectibles,
    required this.checkpoints,
  });
}
