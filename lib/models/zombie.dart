import 'dart:math' as math;
import 'vector3d.dart';
import 'health.dart';
import 'player.dart';

enum ZombieType { normal, fast, tank }

enum ZombieState { idle, chasing, attacking, dying, dead }

class Zombie {
  final String id;
  final ZombieType type;
  Vector3D position;
  double yaw = 0.0;

  final Health health;
  final double speed;
  final double attackDamage;
  final double attackRange;
  final double attackCooldown;
  final double radius = 0.8;

  ZombieState state = ZombieState.idle;
  double cooldownTimer = 0.0;
  double animPhase = 0.0;
  double deathTimer = 1.0; // Seconds to remain in dying state before disappearing

  Zombie({
    required this.id,
    required this.position,
    this.type = ZombieType.normal,
    double? maxHealth,
    double? speed,
    double? damage,
    double? range,
    double? cooldown,
  })  : health = Health(maxHealth: maxHealth ?? _getDefaultHealth(type)),
        speed = speed ?? _getDefaultSpeed(type),
        attackDamage = damage ?? _getDefaultDamage(type),
        attackRange = range ?? 1.6,
        attackCooldown = cooldown ?? 1.2;

  static double _getDefaultHealth(ZombieType type) {
    switch (type) {
      case ZombieType.normal:
        return 80.0; // Basic sword (100.0 damage) kills in 1 hit as required
      case ZombieType.fast:
        return 60.0;
      case ZombieType.tank:
        return 220.0;
    }
  }

  static double _getDefaultSpeed(ZombieType type) {
    switch (type) {
      case ZombieType.normal:
        return 3.2;
      case ZombieType.fast:
        return 5.2;
      case ZombieType.tank:
        return 2.1;
    }
  }

  static double _getDefaultDamage(ZombieType type) {
    switch (type) {
      case ZombieType.normal:
        return 12.0;
      case ZombieType.fast:
        return 8.0;
      case ZombieType.tank:
        return 25.0;
    }
  }

  bool get isAlive => health.isAlive && state != ZombieState.dead && state != ZombieState.dying;

  void update(double dt, Player player) {
    if (state == ZombieState.dead) return;

    if (health.isDead && state != ZombieState.dying) {
      state = ZombieState.dying;
      deathTimer = 0.8;
    }

    if (state == ZombieState.dying) {
      deathTimer -= dt;
      if (deathTimer <= 0.0) {
        state = ZombieState.dead;
      }
      return;
    }

    if (cooldownTimer > 0.0) {
      cooldownTimer -= dt;
    }

    // AI logic state updates will be processed by ZombieAI system
    animPhase += dt * (state == ZombieState.chasing ? 6.0 : 2.0);
  }

  bool tryAttack(Player player) {
    if (!isAlive || cooldownTimer > 0.0) return false;

    final dist = position.distanceToXZ(player.position);
    if (dist <= attackRange) {
      cooldownTimer = attackCooldown;
      state = ZombieState.attacking;
      player.health.takeDamage(attackDamage);
      return true;
    }
    return false;
  }

  void takeDamage(double damage) {
    if (!isAlive) return;
    health.takeDamage(damage);
    if (health.isDead) {
      state = ZombieState.dying;
      deathTimer = 0.8;
    }
  }

  void reuse({required String newId, required Vector3D newPosition, ZombieType? newType}) {
    position = Vector3D.copy(newPosition);
    health.reset();
    state = ZombieState.idle;
    cooldownTimer = 0.0;
    deathTimer = 0.8;
    animPhase = 0.0;
  }
}
