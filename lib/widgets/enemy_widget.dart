import 'dart:math';
import 'package:flutter/material.dart';

import '../models/enemy_model.dart';
import '../services/game_service.dart';

class EnemyWidget extends StatelessWidget {
  final GameService gameService;

  const EnemyWidget({super.key, required this.gameService});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: EnemyPainter(gameService: gameService),
    );
  }
}

class EnemyPainter extends CustomPainter {
  final GameService gameService;

  EnemyPainter({required this.gameService}) : super(repaint: gameService);

  @override
  void paint(Canvas canvas, Size size) {
    final enemies = gameService.enemies;
    final time = gameService.levelTime;
    final camX = gameService.cameraX;
    final camY = gameService.cameraY;

    double shakeOffsetX = 0.0;
    double shakeOffsetY = 0.0;
    if (gameService.cameraShake > 0) {
      final rand = Random();
      shakeOffsetX = (rand.nextDouble() - 0.5) * gameService.cameraShake;
      shakeOffsetY = (rand.nextDouble() - 0.5) * gameService.cameraShake;
    }

    for (var enemy in enemies) {
      if (enemy.isDead && enemy.deathTimer <= 0) continue;

      double screenX = enemy.x - camX + shakeOffsetX;
      double screenY = enemy.y - camY + shakeOffsetY;

      canvas.save();
      canvas.translate(screenX, screenY);

      // Facing direction flip
      if (!enemy.facingRight) {
        canvas.translate(enemy.width, 0);
        canvas.scale(-1, 1);
      }

      // Death dissolve scale
      if (enemy.isDead) {
        double fade = (enemy.deathTimer / 0.8).clamp(0.0, 1.0);
        canvas.scale(fade, fade);
      }

      switch (enemy.type) {
        case EnemyType.forestBug:
          _drawForestBug(canvas, enemy, time);
          break;
        case EnemyType.shadowCreature:
          _drawShadowCreature(canvas, enemy, time);
          break;
        case EnemyType.flyingCreature:
          _drawFlyingCreature(canvas, enemy, time);
          break;
        case EnemyType.guardian:
          _drawGuardian(canvas, enemy, time);
          break;
      }

      canvas.restore();

      // Health bar above enemy in screen coordinates
      if (!enemy.isDead && enemy.health < enemy.maxHealth) {
        _drawHealthBar(canvas, enemy, screenX, screenY);
      }
    }
  }

  void _drawForestBug(Canvas canvas, EnemyModel enemy, double time) {
    double legCycle = sin(time * 15.0) * 4.0;

    // Body carapace
    final bodyRect = Rect.fromLTWH(4, 8, enemy.width - 8, enemy.height - 12);
    canvas.drawOval(
      bodyRect,
      Paint()..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFF2D6A4F),
    );

    // Glowing shell pattern
    canvas.drawCircle(Offset(enemy.width / 2, enemy.height / 2), 6, Paint()..color = const Color(0xFF52B788));

    // Skittering legs
    final legPaint = Paint()
      ..color = const Color(0xFF1B4332)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(8, 20), Offset(2, 30 + legCycle), legPaint);
    canvas.drawLine(Offset(18, 20), Offset(18, 32 - legCycle), legPaint);
    canvas.drawLine(Offset(28, 20), Offset(34, 30 + legCycle), legPaint);

    // Glowing Antennae
    canvas.drawLine(Offset(enemy.width - 8, 12), Offset(enemy.width + 4, 4), legPaint);
    canvas.drawCircle(Offset(enemy.width + 4, 4), 3, Paint()..color = const Color(0xFF74C69D));
  }

  void _drawShadowCreature(Canvas canvas, EnemyModel enemy, double time) {
    double floatY = sin(time * 8.0) * 3.0;

    // Smoky dark body
    final bodyPath = Path()
      ..moveTo(6, enemy.height)
      ..quadraticBezierTo(2, 10, enemy.width / 2, 4 + floatY)
      ..quadraticBezierTo(enemy.width - 2, 10, enemy.width - 6, enemy.height)
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFF1A1A2E),
    );

    // Glowing sinister red eyes
    final eyePaint = Paint()..color = const Color(0xFFFF0055);
    canvas.drawCircle(Offset(enemy.width - 12, 18 + floatY), 4, eyePaint);
    canvas.drawCircle(Offset(enemy.width - 24, 18 + floatY), 4, eyePaint);

    // Claws
    final clawPaint = Paint()
      ..color = const Color(0xFFE94560)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(enemy.width - 4, 28), Offset(enemy.width + 6, 32), clawPaint);
  }

  void _drawFlyingCreature(Canvas canvas, EnemyModel enemy, double time) {
    double wingFlap = sin(time * 18.0) * 12.0;

    // Bat-like wings
    final wingPath = Path();
    wingPath.moveTo(enemy.width / 2, enemy.height / 2);
    wingPath.quadraticBezierTo(enemy.width / 4, -10 + wingFlap, -10, 10);
    wingPath.quadraticBezierTo(enemy.width / 4, 20, enemy.width / 2, enemy.height / 2);

    canvas.drawPath(
      wingPath,
      Paint()..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFF4A154B),
    );

    // Core body
    canvas.drawCircle(
      Offset(enemy.width / 2, enemy.height / 2),
      14,
      Paint()..color = const Color(0xFF6B114D),
    );

    // Cyan glowing eye
    canvas.drawCircle(
      Offset(enemy.width / 2 + 6, enemy.height / 2 - 2),
      4,
      Paint()..color = const Color(0xFF00F5D4),
    );
  }

  void _drawGuardian(Canvas canvas, EnemyModel enemy, double time) {
    double breathe = sin(time * 4.0) * 2.0;

    // Giant Armored Body
    final bodyRect = Rect.fromLTWH(8, 16 + breathe, enemy.width - 16, enemy.height - 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFF2B2D42),
    );

    // Armored Helmet
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(12, breathe, enemy.width - 24, 24), const Radius.circular(6)),
      Paint()..color = const Color(0xFF8D99AE),
    );

    // Visor eye slot
    canvas.drawRect(
      Rect.fromLTWH(20, 10 + breathe, enemy.width - 32, 5),
      Paint()..color = const Color(0xFFD90429),
    );

    // Giant Ancient Sword
    final swordPaint = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 5;
    canvas.drawLine(
      Offset(enemy.width - 6, enemy.height - 10),
      Offset(enemy.width + 16, 10),
      swordPaint,
    );
  }

  void _drawHealthBar(Canvas canvas, EnemyModel enemy, double screenX, double screenY) {
    double barWidth = enemy.width;
    double barHeight = 5.0;
    double healthPct = (enemy.health / enemy.maxHealth).clamp(0.0, 1.0);

    double x = screenX;
    double y = screenY - 12;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(x, y, barWidth, barHeight),
      Paint()..color = Colors.black54,
    );

    // Fill
    canvas.drawRect(
      Rect.fromLTWH(x, y, barWidth * healthPct, barHeight),
      Paint()..color = const Color(0xFFEF476F),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
