import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/rendering/character_render_helper.dart';

class CharacterPainter extends CustomPainter {
  final PlayerState player;
  final double cameraX;
  final double cameraY;
  final double time;
  final CharacterData? customCharacter;

  CharacterPainter({
    required this.player,
    required this.cameraX,
    required this.cameraY,
    required this.time,
    this.customCharacter,
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
    final CharacterData character = customCharacter ?? CharacterProgressController.instance.selectedCharacter;

    CharacterRenderHelper.drawCharacter(
      canvas: canvas,
      character: character,
      w: w,
      h: h,
      topY: topY,
      time: time,
      armAngle: armAngle,
      legAngle1: legAngle1,
      legAngle2: legAngle2,
      isGrounded: player.isGrounded,
      isAttacking: player.isAttacking,
      attackTimer: player.attackTimer,
    );
  }

  @override
  bool shouldRepaint(covariant CharacterPainter oldDelegate) => true;
}
