import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerCharacter extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  final double gravity = 980.0;
  final double moveSpeed = 220.0;
  final double jumpForce = -420.0;

  bool isOnGround = false;
  bool facingRight = true;
  bool isAttacking = false;
  double attackTimer = 0.0;
  final double attackDuration = 0.35;

  int health = 3;
  bool isInvincible = false;
  double invincibilityTimer = 0.0;
  final double invincibilityDuration = 1.2;

  double walkAnimationTime = 0.0;
  Vector2 spawnPosition;

  PlayerCharacter({required Vector2 position})
      : spawnPosition = position.clone(),
        super(position: position, size: Vector2(38, 52));

  void moveLeft() {
    velocity.x = -moveSpeed;
    facingRight = false;
  }

  void moveRight() {
    velocity.x = moveSpeed;
    facingRight = true;
  }

  void stopMoving() {
    velocity.x = 0;
  }

  void jump() {
    if (isOnGround) {
      velocity.y = jumpForce;
      isOnGround = false;
    }
  }

  void attack() {
    if (!isAttacking) {
      isAttacking = true;
      attackTimer = attackDuration;
    }
  }

  void takeDamage() {
    if (isInvincible) return;
    health--;
    isInvincible = true;
    invincibilityTimer = invincibilityDuration;
  }

  void respawnAt(Vector2 checkpointPos) {
    position = checkpointPos.clone();
    velocity = Vector2.zero();
    health = 3;
    isInvincible = false;
    invincibilityTimer = 0;
  }

  Rect get attackHitbox {
    if (!isAttacking) return Rect.zero;
    final attackWidth = 32.0;
    final attackHeight = 40.0;
    final x = facingRight ? position.x + size.x : position.x - attackWidth;
    final y = position.y + 6;
    return Rect.fromLTWH(x, y, attackWidth, attackHeight);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Invincibility cooldown
    if (isInvincible) {
      invincibilityTimer -= dt;
      if (invincibilityTimer <= 0) {
        isInvincible = false;
      }
    }

    // Attack cooldown
    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) {
        isAttacking = false;
      }
    }

    // Physics update
    velocity.y += gravity * dt;
    position += velocity * dt;

    if (velocity.x != 0 && isOnGround) {
      walkAnimationTime += dt * 12;
    } else {
      walkAnimationTime = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isInvincible && (invincibilityTimer * 10).floor() % 2 == 0) {
      canvas.saveLayer(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.white.withValues(alpha: 0.4));
    }

    canvas.save();
    if (!facingRight) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    // Shadow below character
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromLTWH(4, size.y - 6, size.x - 8, 8),
      shadowPaint,
    );

    // Adventurer Cape
    final capePaint = Paint()..color = const Color(0xFF0F766E);
    final capePath = Path()
      ..moveTo(6, 16)
      ..quadraticBezierTo(-4 + sin(walkAnimationTime) * 3, 30, 2, 44)
      ..lineTo(14, 44)
      ..lineTo(18, 16)
      ..close();
    canvas.drawPath(capePath, capePaint);

    // Body / Tunic
    final tunicPaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 18, 18, 22),
        const Radius.circular(5),
      ),
      tunicPaint,
    );

    // Belt
    final beltPaint = Paint()..color = const Color(0xFF854D0E);
    canvas.drawRect(Rect.fromLTWH(10, 30, 18, 4), beltPaint);

    // Head / Cute Face
    final skinPaint = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawCircle(const Offset(19, 12), 10, skinPaint);

    // Adventurer Hood / Hair
    final hoodPaint = Paint()..color = const Color(0xFF0D9488);
    final hoodPath = Path()
      ..moveTo(9, 12)
      ..quadraticBezierTo(19, 0, 29, 12)
      ..quadraticBezierTo(24, 6, 19, 6)
      ..quadraticBezierTo(14, 6, 9, 12)
      ..close();
    canvas.drawPath(hoodPath, hoodPaint);

    // Eye
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(22, 11), 2.5, eyePaint);

    final eyeGlint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(23, 10), 1.0, eyeGlint);

    // Legs
    final legPaint = Paint()..color = const Color(0xFF1E293B);
    final leftLegOffset = sin(walkAnimationTime) * 4;
    final rightLegOffset = -sin(walkAnimationTime) * 4;

    canvas.drawRect(Rect.fromLTWH(12 + leftLegOffset, 40, 5, 10), legPaint);
    canvas.drawRect(Rect.fromLTWH(21 + rightLegOffset, 40, 5, 10), legPaint);

    // Boots
    final bootPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(12 + leftLegOffset, 48, 7, 4), bootPaint);
    canvas.drawRect(Rect.fromLTWH(21 + rightLegOffset, 48, 7, 4), bootPaint);

    // Sword & Attack Arc
    if (isAttacking) {
      final swordPaint = Paint()
        ..color = const Color(0xFFE0F2FE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      final attackArc = Path()
        ..moveTo(26, 8)
        ..quadraticBezierTo(44, 20, 28, 42);
      canvas.drawPath(attackArc, swordPaint);

      final slashGlow = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(attackArc, slashGlow);
    } else {
      final hiltPaint = Paint()..color = const Color(0xFFF59E0B);
      canvas.drawRect(Rect.fromLTWH(25, 22, 3, 10), hiltPaint);
    }

    canvas.restore();

    if (isInvincible && (invincibilityTimer * 10).floor() % 2 == 0) {
      canvas.restore();
    }
  }
}
