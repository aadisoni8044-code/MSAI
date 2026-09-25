import 'package:flutter/material.dart';

enum ZombieType {
  normal,
  fast,
  large,
}

enum ZombieState {
  idle,
  chasing,
  attacking,
  hit,
  dying,
  dead,
}

class ZombieEntity {
  final String id;
  final ZombieType zombieType;
  double x;
  double y;
  double width;
  double height;

  double vx;
  double vy;
  bool isGrounded;
  bool facingRight;

  int health;
  int maxHealth;
  double speed;
  int damage;

  ZombieState state;
  double animTimer;
  double attackCooldown;
  double hitTimer;

  // Jump ability for climbing watchtowers & platforms
  double jumpCooldown;

  ZombieEntity({
    required this.id,
    required this.zombieType,
    required this.x,
    required this.y,
  })  : width = zombieType == ZombieType.large
            ? 58
            : zombieType == ZombieType.fast
                ? 36
                : 42,
        height = zombieType == ZombieType.large
            ? 64
            : zombieType == ZombieType.fast
                ? 40
                : 48,
        speed = zombieType == ZombieType.large
            ? 1.4
            : zombieType == ZombieType.fast
                ? 3.2
                : 2.1,
        health = zombieType == ZombieType.large ? 5 : 1,
        maxHealth = zombieType == ZombieType.large ? 5 : 1,
        damage = zombieType == ZombieType.large ? 2 : 1,
        vx = 0,
        vy = 0,
        isGrounded = false,
        facingRight = true,
        state = ZombieState.chasing,
        animTimer = 0,
        attackCooldown = 0,
        hitTimer = 0,
        jumpCooldown = 0;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  void takeDamage(int amount) {
    if (state == ZombieState.dying || state == ZombieState.dead) return;
    health -= amount;
    hitTimer = 0.25;
    state = ZombieState.hit;
    if (health <= 0) {
      health = 0;
      state = ZombieState.dying;
      animTimer = 0;
    }
  }

  void updateAI({
    required double targetX,
    required double targetY,
    required double dt,
    required List<Rect> platformRects,
  }) {
    animTimer += dt;

    if (hitTimer > 0) {
      hitTimer -= dt;
      if (hitTimer <= 0) {
        hitTimer = 0;
        if (health > 0) state = ZombieState.chasing;
      }
    }

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }

    if (jumpCooldown > 0) {
      jumpCooldown -= dt;
    }

    if (state == ZombieState.dying) {
      if (animTimer >= 0.4) {
        state = ZombieState.dead;
      }
      return;
    }

    if (state == ZombieState.dead) return;

    // Apply gravity
    vy += 0.60;
    if (vy > 12) vy = 12;

    // Chase player X
    final dx = targetX - (x + width / 2);
    if (dx.abs() > 8) {
      facingRight = dx > 0;
      vx = facingRight ? speed : -speed;
    } else {
      vx = 0;
    }

    // Attempt to jump onto elevated platform/tower if player is higher
    final dy = targetY - (y + height);
    if (dy < -30 && isGrounded && jumpCooldown <= 0) {
      vy = zombieType == ZombieType.large ? -12.5 : -14.0;
      isGrounded = false;
      jumpCooldown = 1.2;
    }

    // Move X
    x += vx;
    _resolveHorizontalCollisions(platformRects);

    // Move Y
    y += vy;
    _resolveVerticalCollisions(platformRects);
  }

  void _resolveHorizontalCollisions(List<Rect> platformRects) {
    final selfRect = bounds;
    for (final plat in platformRects) {
      if (selfRect.overlaps(plat)) {
        if (vx > 0) {
          x = plat.left - width;
          // Jump over obstacle if moving right
          if (isGrounded && jumpCooldown <= 0) {
            vy = -12.0;
            isGrounded = false;
            jumpCooldown = 1.0;
          }
        } else if (vx < 0) {
          x = plat.right;
          // Jump over obstacle if moving left
          if (isGrounded && jumpCooldown <= 0) {
            vy = -12.0;
            isGrounded = false;
            jumpCooldown = 1.0;
          }
        }
      }
    }
  }

  void _resolveVerticalCollisions(List<Rect> platformRects) {
    isGrounded = false;
    final selfRect = bounds;

    for (final plat in platformRects) {
      if (selfRect.overlaps(plat)) {
        if (vy > 0 && (selfRect.bottom - vy) <= plat.top + 12) {
          y = plat.top - height;
          vy = 0;
          isGrounded = true;
        } else if (vy < 0 && (selfRect.top - vy) >= plat.bottom - 12) {
          y = plat.bottom;
          vy = 0;
        }
      }
    }
  }
}
