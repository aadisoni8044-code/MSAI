import 'package:flutter/material.dart';

enum CarZombieEnemyType {
  normal,
  fast,
  heavy,
  large,
}

enum CarZombieObstacleType {
  wreckCar,
  rock,
  barricade,
  tree,
}

enum CarZombieCollectibleType {
  coin,
  ammoCrate,
  healthKit,
}

class CarZombieVehicleState {
  double x;
  double y;
  double width;
  double height;
  double maxHp;
  double currentHp;
  double speed;
  double boostTimer;
  bool isBoosting;
  double damageFlashTimer;
  double wheelRotation;

  CarZombieVehicleState({
    this.x = 220.0,
    this.y = 520.0,
    this.width = 140.0,
    this.height = 65.0,
    this.maxHp = 100.0,
    this.currentHp = 100.0,
    this.speed = 460.0,
    this.boostTimer = 0.0,
    this.isBoosting = false,
    this.damageFlashTimer = 0.0,
    this.wheelRotation = 0.0,
  });

  void reset(double startY) {
    x = 220.0;
    y = startY;
    currentHp = maxHp;
    boostTimer = 0.0;
    isBoosting = false;
    damageFlashTimer = 0.0;
    wheelRotation = 0.0;
  }

  Rect get bounds => Rect.fromLTWH(x, y, width, height);
}

class CarZombieEnemy {
  final String id;
  final CarZombieEnemyType type;
  double x;
  double y;
  double width;
  double height;
  double speed;
  double health;
  double maxHealth;
  bool isAttackingCar;
  double attackTimer;
  double hitTimer;
  bool isLatchedToCar;

  CarZombieEnemy({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.health,
    required this.maxHealth,
    this.isAttackingCar = false,
    this.attackTimer = 0.0,
    this.hitTimer = 0.0,
    this.isLatchedToCar = false,
  });

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  static CarZombieEnemy create({
    required String id,
    required CarZombieEnemyType type,
    required double startX,
    required double startY,
  }) {
    switch (type) {
      case CarZombieEnemyType.fast:
        return CarZombieEnemy(
          id: id,
          type: type,
          x: startX,
          y: startY,
          width: 38,
          height: 48,
          speed: 520,
          health: 1.0,
          maxHealth: 1.0,
        );
      case CarZombieEnemyType.heavy:
        return CarZombieEnemy(
          id: id,
          type: type,
          x: startX,
          y: startY,
          width: 50,
          height: 60,
          speed: 380,
          health: 4.0,
          maxHealth: 4.0,
        );
      case CarZombieEnemyType.large:
        return CarZombieEnemy(
          id: id,
          type: type,
          x: startX,
          y: startY,
          width: 65,
          height: 75,
          speed: 340,
          health: 8.0,
          maxHealth: 8.0,
        );
      case CarZombieEnemyType.normal:
      default:
        return CarZombieEnemy(
          id: id,
          type: CarZombieEnemyType.normal,
          x: startX,
          y: startY,
          width: 42,
          height: 52,
          speed: 430,
          health: 2.0,
          maxHealth: 2.0,
        );
    }
  }
}

class CarZombieBullet {
  final String id;
  double x;
  double y;
  double vx;
  double vy;
  double damage;
  bool isAlive;

  CarZombieBullet({
    required this.id,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.damage = 1.0,
    this.isAlive = true,
  });

  Rect get bounds => Rect.fromLTWH(x - 4, y - 4, 8, 8);
}

class CarZombieObstacle {
  final String id;
  final CarZombieObstacleType type;
  double x;
  double y;
  double width;
  double height;
  double health;
  bool isDestroyed;

  CarZombieObstacle({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.health = 3.0,
    this.isDestroyed = false,
  });

  Rect get bounds => Rect.fromLTWH(x, y, width, height);
}

class CarZombieCollectible {
  final String id;
  final CarZombieCollectibleType type;
  double x;
  double y;
  double width;
  double height;
  bool isCollected;

  CarZombieCollectible({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 24.0,
    this.height = 24.0,
    this.isCollected = false,
  });

  Rect get bounds => Rect.fromLTWH(x, y, width, height);
}

class CarZombieParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double life;
  double maxLife;

  CarZombieParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    this.size = 3.0,
    this.life = 0.5,
    this.maxLife = 0.5,
  });
}
