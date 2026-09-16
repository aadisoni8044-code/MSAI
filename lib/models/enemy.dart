import 'package:flutter/material.dart';

enum EnemyType { slime, goblin, flyingBat }

class Enemy {
  final String id;
  Offset position;
  final Size size;
  final EnemyType type;

  Offset velocity;
  double moveSpeed;
  double minX;
  double maxX;
  bool isFacingRight;

  int maxHealth;
  int currentHealth;
  bool isAlive;
  double hurtTimer;
  static const double hurtDuration = 0.2;

  Enemy({
    required this.id,
    required Offset position,
    required double patrolDistance,
    this.type = EnemyType.slime,
    this.size = const Size(36, 32),
    this.moveSpeed = 70.0,
    this.maxHealth = 1,
  })  : position = position,
        velocity = Offset(moveSpeed, 0),
        minX = position.dx,
        maxX = position.dx + patrolDistance,
        isFacingRight = true,
        currentHealth = maxHealth,
        isAlive = true,
        hurtTimer = 0.0;

  void update(double dt) {
    if (!isAlive) return;

    if (hurtTimer > 0) {
      hurtTimer -= dt;
    }

    // Patrol logic
    if (type == EnemyType.flyingBat) {
      // Sine wave hovering
      position = Offset(
        position.dx + (isFacingRight ? moveSpeed * dt : -moveSpeed * dt),
        position.dy,
      );
    } else {
      position = Offset(
        position.dx + (isFacingRight ? moveSpeed * dt : -moveSpeed * dt),
        position.dy,
      );
    }

    if (position.dx >= maxX) {
      isFacingRight = false;
    } else if (position.dx <= minX) {
      isFacingRight = true;
    }
  }

  bool takeDamage(int amount) {
    if (!isAlive || hurtTimer > 0) return false;
    currentHealth -= amount;
    hurtTimer = hurtDuration;
    if (currentHealth <= 0) {
      currentHealth = 0;
      isAlive = false;
    }
    return true;
  }

  Rect get bounds => Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}
