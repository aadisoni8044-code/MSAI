import 'package:flutter/material.dart';

enum EntityType {
  platform,
  movingPlatform,
  slipperyPlatform,
  enemySlime,
  enemyShadow,
  enemyFire,
  enemyIce,
  enemyToxic,
  hazardSpike,
  hazardLava,
  hazardPoison,
  hazardLightning,
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

  // Patrol or animation or platform movement parameters
  double startX;
  double startY;
  double patrolRange;
  double moveRangeY;
  double vx;
  double vy;
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
    double? startY,
    this.patrolRange = 100,
    this.moveRangeY = 0,
    this.vx = 1.2,
    this.vy = 0,
    this.isActivated = false,
    this.isCollected = false,
    this.health = 1,
    this.animTimer = 0,
  })  : startX = startX ?? x,
        startY = startY ?? y;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  void update(double dt) {
    animTimer += dt;
    if (type == EntityType.enemySlime ||
        type == EntityType.enemyShadow ||
        type == EntityType.enemyFire ||
        type == EntityType.enemyIce ||
        type == EntityType.enemyToxic) {
      x += vx;
      if ((x - startX).abs() > patrolRange) {
        vx = -vx;
      }
    } else if (type == EntityType.movingPlatform) {
      if (patrolRange > 0) {
        x += vx;
        if ((x - startX).abs() > patrolRange) {
          vx = -vx;
        }
      }
      if (moveRangeY > 0) {
        y += vy;
        if ((y - startY).abs() > moveRangeY) {
          vy = -vy;
        }
      }
    }
  }
}
