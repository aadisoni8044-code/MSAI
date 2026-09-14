import 'dart:math';
import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/game_service.dart';

class PlayerWidget extends StatelessWidget {
  final GameService gameService;

  const PlayerWidget({super.key, required this.gameService});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: PlayerPainter(gameService: gameService),
    );
  }
}

class PlayerPainter extends CustomPainter {
  final GameService gameService;

  PlayerPainter({required this.gameService}) : super(repaint: gameService);

  @override
  void paint(Canvas canvas, Size size) {
    final player = gameService.player;
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

    canvas.save();
    canvas.translate(player.x - camX + shakeOffsetX, player.y - camY + shakeOffsetY);

    // Apply facing direction flip around center
    if (!player.facingRight) {
      canvas.translate(player.width, 0);
      canvas.scale(-1, 1);
    }

    // Dash motion ghosting lines
    if (player.isDashing) {
      _drawDashAfterimages(canvas, player);
    }

    // Character drawing
    _drawCharacterBody(canvas, player, time);

    // Attack sword slash arc
    if (player.isAttacking) {
      _drawAttackSlash(canvas, player, time);
    }

    canvas.restore();
  }

  void _drawDashAfterimages(Canvas canvas, PlayerModel player) {
    final ghostPaint = Paint()
      ..color = const Color(0x6680FFDB)
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= 3; i++) {
      canvas.save();
      canvas.translate(-i * 18.0, 0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, player.width, player.height),
          const Radius.circular(12),
        ),
        ghostPaint,
      );
      canvas.restore();
    }
  }

  void _drawCharacterBody(Canvas canvas, PlayerModel player, double time) {
    double breatheY = sin(time * 6.0) * 2.0;

    // Flash colors on hurt / invulnerable
    Color cloakColor = const Color(0xFF1E88E5);
    Color hoodColor = const Color(0xFF1565C0);
    Color tunicColor = const Color(0xFF26A69A);
    Color eyeGlowColor = const Color(0xFF80FFDB);

    if (player.isHurt) {
      cloakColor = const Color(0xFFFF5252);
      hoodColor = const Color(0xFFFF1744);
    }

    // 1. Cloak / Body Base
    final cloakPath = Path();
    double walkCycle = sin(time * 12.0) * 8.0;

    switch (player.state) {
      case PlayerState.walk:
      case PlayerState.run:
        cloakPath.moveTo(8, 16);
        cloakPath.lineTo(player.width - 8, 16);
        cloakPath.lineTo(player.width + 4, player.height - 4 + walkCycle);
        cloakPath.lineTo(-4, player.height - 4 - walkCycle);
        cloakPath.close();
        break;

      case PlayerState.jump:
        cloakPath.moveTo(8, 16);
        cloakPath.lineTo(player.width - 8, 16);
        cloakPath.lineTo(player.width + 8, player.height + 4);
        cloakPath.lineTo(-6, player.height + 2);
        cloakPath.close();
        break;

      default:
        cloakPath.moveTo(8, 16 + breatheY);
        cloakPath.lineTo(player.width - 8, 16 + breatheY);
        cloakPath.lineTo(player.width + 2, player.height);
        cloakPath.lineTo(-2, player.height);
        cloakPath.close();
        break;
    }

    canvas.drawPath(cloakPath, Paint()..color = cloakColor);

    // 2. Explorer Tunic Inner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 20 + breatheY, player.width - 20, player.height - 24),
        const Radius.circular(6),
      ),
      Paint()..color = tunicColor,
    );

    // 3. Cute Explorer Hooded Head
    final headRect = Rect.fromLTWH(4, breatheY, player.width - 8, 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(14)),
      Paint()..color = hoodColor,
    );

    // Inner shadow face void
    final faceRect = Rect.fromLTWH(10, 8 + breatheY, player.width - 18, 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF09121D),
    );

    // Glowing Cute Eyes
    canvas.drawCircle(Offset(player.width - 14, 15 + breatheY), 3.5, Paint()..color = eyeGlowColor);
    canvas.drawCircle(Offset(player.width - 22, 15 + breatheY), 3.5, Paint()..color = eyeGlowColor);

    // 4. Explorer Backpack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, 18 + breatheY, 12, 18),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // 5. Weapon Holster / Blade Handle
    final hiltPaint = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 3.0;
    canvas.drawLine(
      Offset(player.width - 6, 22 + breatheY),
      Offset(player.width + 8, 16 + breatheY),
      hiltPaint,
    );
  }

  void _drawAttackSlash(Canvas canvas, PlayerModel player, double time) {
    final slashPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0x0064DFDF), Color(0xFF80FFDB), Color(0xFFFFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, 100, 100))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final slashPath = Path();
    slashPath.addArc(
      Rect.fromLTWH(player.width - 15, -15, 70, 80),
      -pi / 3,
      2 * pi / 3,
    );

    canvas.drawPath(slashPath, slashPaint);

    // Energy slash trail glow
    canvas.drawPath(
      slashPath,
      Paint()
        ..color = const Color(0x6680FFDB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
