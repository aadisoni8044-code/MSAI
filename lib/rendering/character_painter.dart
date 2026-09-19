import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';

class CharacterPainter extends CustomPainter {
  final PlayerState player;
  final double cameraX;
  final double cameraY;
  final double time;

  CharacterPainter({
    required this.player,
    required this.cameraX,
    required this.cameraY,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (player.isInvulnerable && (time * 20).floor() % 2 == 0) {
      // Invulnerability flicker
      return;
    }

    canvas.save();
    canvas.translate(-cameraX, -cameraY);

    final double cx = player.x + player.width / 2;
    final double cy = player.y + player.height / 2;

    canvas.translate(cx, cy);

    // Flip horizontally if facing left
    if (!player.facingRight) {
      canvas.scale(-1.0, 1.0);
    }

    _drawHeroCharacter(canvas);

    canvas.restore();
  }

  void _drawHeroCharacter(Canvas canvas) {
    final double w = player.width;
    final double h = player.height;

    // Animation variables
    double bodyYOffset = 0;
    double legAngle1 = 0;
    double legAngle2 = 0;
    double armAngle = 0;

    switch (player.actionState) {
      case PlayerActionState.idle:
        bodyYOffset = sin(time * 4) * 2;
        break;
      case PlayerActionState.running:
        bodyYOffset = sin(time * 12).abs() * -3;
        legAngle1 = sin(time * 14) * 0.6;
        legAngle2 = -legAngle1;
        armAngle = sin(time * 14) * 0.5;
        break;
      case PlayerActionState.jumping:
      case PlayerActionState.falling:
        legAngle1 = 0.4;
        legAngle2 = -0.3;
        armAngle = -0.6;
        break;
      case PlayerActionState.attacking:
        armAngle = 1.2;
        break;
      case PlayerActionState.hurt:
      case PlayerActionState.dead:
        bodyYOffset = 4;
        break;
    }

    final double topY = -h / 2 + bodyYOffset;

    // Shadow on Ground
    if (player.isGrounded) {
      final Paint shadowPaint = Paint()..color = const Color(0x55000000);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, h / 2 - 2), width: w * 0.8, height: 8),
        shadowPaint,
      );
    }

    // 1. Cloak / Back Cape
    final Paint cloakPaint = Paint()..color = GameColors.playerAccentTeal;
    final Path cloakPath = Path()
      ..moveTo(-12, topY + 22)
      ..quadraticBezierTo(-22 - sin(time * 8) * 4, topY + 36, -16, topY + 46)
      ..lineTo(10, topY + 46)
      ..quadraticBezierTo(2, topY + 32, -8, topY + 22)
      ..close();
    canvas.drawPath(cloakPath, cloakPaint);

    // 2. Legs / Boots
    final Paint legPaint = Paint()..color = GameColors.ancientBarkDark;

    // Back Leg
    canvas.save();
    canvas.translate(-6, topY + 38);
    canvas.rotate(legAngle2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 14), const Radius.circular(3)), legPaint);
    canvas.restore();

    // Front Leg
    canvas.save();
    canvas.translate(6, topY + 38);
    canvas.rotate(legAngle1);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 14), const Radius.circular(3)), legPaint);
    canvas.restore();

    // 3. Torso / Tunic
    final Paint bodyPaint = Paint()..color = GameColors.playerBodyLight;
    final Rect bodyRect = Rect.fromLTWH(-w * 0.35, topY + 20, w * 0.7, 22);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), bodyPaint);

    // Belt
    final Paint beltPaint = Paint()..color = GameColors.playerWeapon;
    canvas.drawRect(Rect.fromLTWH(-w * 0.36, topY + 32, w * 0.72, 4), beltPaint);

    // 4. Skull / Spirit Mask Head
    final Paint maskPaint = Paint()..color = GameColors.playerMaskWhite;
    final Rect headRect = Rect.fromLTWH(-w * 0.42, topY - 2, w * 0.84, w * 0.84);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, const Radius.circular(16)), maskPaint);

    // Mask Snout / Horns
    final Path hornPath = Path()
      ..moveTo(w * 0.3, topY + 12)
      ..lineTo(w * 0.52, topY + 14)
      ..lineTo(w * 0.28, topY + 20)
      ..close();
    canvas.drawPath(hornPath, maskPaint);

    // Glowing Cute Eyes
    final Paint eyeGlow = Paint()..color = GameColors.playerGlow;
    final Paint eyePupil = Paint()..color = GameColors.skyBackground;

    final Offset frontEyeCenter = Offset(w * 0.12, topY + 10);
    final Offset backEyeCenter = Offset(-w * 0.12, topY + 10);

    // Eye glow circles
    canvas.drawCircle(frontEyeCenter, 6, eyeGlow);
    canvas.drawCircle(backEyeCenter, 5, eyeGlow);

    // Pupils
    canvas.drawCircle(Offset(frontEyeCenter.dx + 1.5, frontEyeCenter.dy), 3, eyePupil);
    canvas.drawCircle(Offset(backEyeCenter.dx + 1.5, backEyeCenter.dy), 2.5, eyePupil);

    // 5. Sword & Attack Animation Arc
    canvas.save();
    canvas.translate(8, topY + 26);
    canvas.rotate(armAngle);

    final Paint weaponPaint = Paint()..color = GameColors.playerWeapon;
    // Sword blade
    final Path swordPath = Path()
      ..moveTo(0, -2)
      ..lineTo(22, -4)
      ..lineTo(26, 0)
      ..lineTo(22, 4)
      ..lineTo(0, 2)
      ..close();
    canvas.drawPath(swordPath, weaponPaint);

    // Sword Hilt
    canvas.drawRect(const Rect.fromLTWH(-3, -6, 4, 12), Paint()..color = GameColors.ancientBarkDark);

    canvas.restore();

    // Attack Arc Visual Effect
    if (player.isAttacking) {
      final double progress = (0.28 - player.attackTimer) / 0.28;
      final Paint arcPaint = Paint()
        ..color = GameColors.playerGlow.withValues(alpha: 0.8 - progress * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;

      final Path arcPath = Path()
        ..addArc(
          Rect.fromCircle(center: Offset(10, topY + 15), radius: 36),
          -1.0 + progress * 0.5,
          1.8,
        );
      canvas.drawPath(arcPath, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CharacterPainter oldDelegate) => true;
}
