import 'package:flutter/material.dart';

enum EntityType {
  platform,
  enemySlime,
  enemyShadow,
  hazardSpike,
  coin,
  healthPot,
  checkpoint,
  goalPortal,
}

class GameEntity {
  final String id;
  final EntityType type;
  double x;
  double y;
  double width;
  double height;

  // Patrol or animation parameters
  double startX;
  double patrolRange;
  double vx;
  bool isActivated;
  bool isCollected;
  int health;
  double animTimer;

  GameEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    double? startX,
    this.patrolRange = 100,
    this.vx = 1.2,
    this.isActivated = false,
    this.isCollected = false,
    this.health = 1,
    this.animTimer = 0,
  }) : startX = startX ?? x;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  void update(double dt) {
    animTimer += dt;
    if (type == EntityType.enemySlime || type == EntityType.enemyShadow) {
      x += vx;
      if ((x - startX).abs() > patrolRange) {
        vx = -vx;
      }
    }
  }
}
