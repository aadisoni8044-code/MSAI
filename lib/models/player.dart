import 'package:flutter/material.dart';

enum PlayerState { idle, running, jumping, falling, attacking, hurt, dead }

class Player {
  // Position and Dimensions
  Offset position;
  final Size size;

  // Velocity and Acceleration
  Offset velocity;
  double moveSpeed;
  double jumpForce;
  double gravity;

  // State
  PlayerState state;
  bool isGrounded;
  bool isFacingRight;

  // Health
  int maxHealth;
  int currentHealth;
  bool isInvulnerable;
  double invulnerabilityTimer;
  static const double invulnerabilityDuration = 1.2; // seconds

  // Attack state
  bool isAttacking;
  double attackTimer;
  static const double attackDuration = 0.35; // seconds
  double attackCooldown;
  static const double attackCooldownDuration = 0.45;

  // Initial Spawn / Checkpoint
  Offset spawnPosition;

  Player({
    required this.position,
    this.size = const Size(36, 48),
    this.moveSpeed = 220.0,
    this.jumpForce = -420.0,
    this.gravity = 1100.0,
  })  : velocity = Offset.zero,
        state = PlayerState.idle,
        isGrounded = false,
        isFacingRight = true,
        maxHealth = 3,
        currentHealth = 3,
        isInvulnerable = false,
        invulnerabilityTimer = 0.0,
        isAttacking = false,
        attackTimer = 0.0,
        attackCooldown = 0.0,
        spawnPosition = position;

  void moveLeft() {
    velocity = Offset(-moveSpeed, velocity.dy);
    isFacingRight = false;
    if (isGrounded && !isAttacking) {
      state = PlayerState.running;
    }
  }

  void moveRight() {
    velocity = Offset(moveSpeed, velocity.dy);
    isFacingRight = true;
    if (isGrounded && !isAttacking) {
      state = PlayerState.running;
    }
  }

  void stopHorizontal() {
    velocity = Offset(0, velocity.dy);
    if (isGrounded && !isAttacking && state != PlayerState.hurt) {
      state = PlayerState.idle;
    }
  }

  bool jump() {
    if (isGrounded) {
      velocity = Offset(velocity.dx, jumpForce);
      isGrounded = false;
      state = PlayerState.jumping;
      return true;
    }
    return false;
  }

  bool attack() {
    if (attackCooldown <= 0.0 && !isAttacking) {
      isAttacking = true;
      attackTimer = attackDuration;
      attackCooldown = attackCooldownDuration;
      state = PlayerState.attacking;
      return true;
    }
    return false;
  }

  bool takeDamage(int amount, Offset knockback) {
    if (isInvulnerable || state == PlayerState.dead) return false;

    currentHealth -= amount;
    if (currentHealth <= 0) {
      currentHealth = 0;
      state = PlayerState.dead;
    } else {
      state = PlayerState.hurt;
      isInvulnerable = true;
      invulnerabilityTimer = invulnerabilityDuration;
      velocity = knockback;
    }
    return true;
  }

  void respawnAtCheckpoint(Offset checkpointPos) {
    spawnPosition = checkpointPos;
    position = checkpointPos;
    velocity = Offset.zero;
    currentHealth = maxHealth;
    state = PlayerState.idle;
    isInvulnerable = false;
    invulnerabilityTimer = 0.0;
    isAttacking = false;
    attackTimer = 0.0;
  }

  void update(double dt) {
    // Apply gravity
    if (!isGrounded) {
      velocity = Offset(velocity.dx, velocity.dy + gravity * dt);
      if (velocity.dy > 0 && state != PlayerState.attacking && state != PlayerState.hurt) {
        state = PlayerState.falling;
      }
    }

    // Update Timers
    if (isInvulnerable) {
      invulnerabilityTimer -= dt;
      if (invulnerabilityTimer <= 0) {
        isInvulnerable = false;
        invulnerabilityTimer = 0.0;
      }
    }

    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) {
        isAttacking = false;
        attackTimer = 0.0;
        if (isGrounded) {
          state = velocity.dx.abs() > 10 ? PlayerState.running : PlayerState.idle;
        }
      }
    }

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }

    // Apply Position Movement
    position += velocity * dt;
  }

  Rect get bounds => Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  Rect get attackBounds {
    final double attackWidth = 34.0;
    final double attackHeight = 40.0;
    final double attackX = isFacingRight
        ? position.dx + size.width
        : position.dx - attackWidth;
    final double attackY = position.dy + 4.0;
    return Rect.fromLTWH(attackX, attackY, attackWidth, attackHeight);
  }
}
