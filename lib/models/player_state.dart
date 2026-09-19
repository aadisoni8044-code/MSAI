import 'package:flutter/material.dart';

enum PlayerActionState {
  idle,
  running,
  jumping,
  falling,
  attacking,
  hurt,
  dead,
}

class PlayerState {
  double x;
  double y;
  double vx;
  double vy;
  double width;
  double height;
  bool isGrounded;
  bool facingRight;

  int maxHealth;
  int currentHealth;
  int coins;

  PlayerActionState actionState;
  double animationTimer;
  double attackTimer;
  double invulnerableTimer;

  bool get isAttacking => attackTimer > 0;
  bool get isInvulnerable => invulnerableTimer > 0;

  PlayerState({
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.width = 44,
    this.height = 54,
    this.isGrounded = false,
    this.facingRight = true,
    this.maxHealth = 5,
    this.currentHealth = 5,
    this.coins = 0,
    this.actionState = PlayerActionState.idle,
    this.animationTimer = 0,
    this.attackTimer = 0,
    this.invulnerableTimer = 0,
  });

  void reset(double startX, double startY) {
    x = startX;
    y = startY;
    vx = 0;
    vy = 0;
    isGrounded = false;
    facingRight = true;
    currentHealth = maxHealth;
    actionState = PlayerActionState.idle;
    animationTimer = 0;
    attackTimer = 0;
    invulnerableTimer = 0;
  }

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  Rect get attackBounds {
    final attackWidth = width * 1.2;
    final attackHeight = height * 0.9;
    final attackX = facingRight ? x + width * 0.5 : x - attackWidth + width * 0.5;
    final attackY = y + 5;
    return Rect.fromLTWH(attackX, attackY, attackWidth, attackHeight);
  }
}
