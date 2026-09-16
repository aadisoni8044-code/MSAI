import 'dart:math';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/level_objects.dart';
import 'visual_effects.dart';

class GamePainter extends CustomPainter {
  final GameService game;
  final ParallaxBackground background;

  GamePainter({required this.game})
      : background = ParallaxBackground(
          worldWidth: game.levelData.worldWidth,
          worldHeight: game.levelData.worldHeight,
        );

  @override
  void paint(Canvas canvas, Size size) {
    final cameraPos = game.camera.position;

    // 1. Render Multi-layered Parallax Background & Sky
    background.draw(canvas, size, cameraPos);

    // Apply Camera Translation & Screen Shake for World Rendering
    canvas.save();
    final shakeOffset = game.visualEffects.getShakeOffset();
    canvas.translate(-cameraPos.dx + shakeOffset.dx, -cameraPos.dy + shakeOffset.dy);

    // 2. Render Platforms & Ground
    _drawPlatforms(canvas);

    // 3. Render Checkpoints & Exit Portal
    _drawCheckpointsAndPortal(canvas);

    // 4. Render Collectibles (Crystals)
    _drawCollectibles(canvas);

    // 5. Render Enemies
    _drawEnemies(canvas);

    // 6. Render Player Character & Attack Effect
    _drawPlayer(canvas);

    canvas.restore();

    // 7. Render Foreground Fireflies Particle System (Fixed to Screen)
    game.visualEffects.drawFireflies(canvas);
  }

  void _drawPlatforms(Canvas canvas) {
    for (final platform in game.levelData.platforms) {
      final rect = platform.bounds;

      // Base Platform Body
      final Paint bodyPaint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), bodyPaint);

      // Top Grass / Foliage Edge
      final Paint grassPaint = Paint()..color = const Color(0xFF059669);
      final Rect grassRect = Rect.fromLTWH(rect.left, rect.top, rect.width, 10);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          grassRect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        grassPaint,
      );

      // Subtle Moss Detail Spots
      final Paint detailPaint = Paint()..color = const Color(0xFF10B981).withOpacity(0.6);
      for (double x = rect.left + 15; x < rect.right - 10; x += 30) {
        canvas.drawCircle(Offset(x, rect.top + 4), 3, detailPaint);
      }
    }
  }

  void _drawCheckpointsAndPortal(Canvas canvas) {
    // Checkpoints
    for (final cp in game.levelData.checkpoints) {
      final rect = cp.bounds;
      final Paint polePaint = Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 4;
      canvas.drawLine(Offset(rect.left + 8, rect.bottom), Offset(rect.left + 8, rect.top), polePaint);

      final Paint flagPaint = Paint()
        ..color = cp.isActivated ? const Color(0xFF10B981) : const Color(0xFF64748B);

      final Path flagPath = Path()
        ..moveTo(rect.left + 8, rect.top)
        ..lineTo(rect.left + 28, rect.top + 10)
        ..lineTo(rect.left + 8, rect.top + 20)
        ..close();
      canvas.drawPath(flagPath, flagPaint);

      if (cp.isActivated) {
        final Paint glow = Paint()
          ..color = const Color(0x6610B981)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(rect.left + 8, rect.top + 10), 16, glow);
      }
    }

    // Exit Portal
    final portal = game.levelData.exitPortal;
    final pRect = portal.bounds;
    final Offset center = pRect.center;

    final Paint outerGlow = Paint()
      ..color = const Color(0x992DD4BF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawOval(pRect, outerGlow);

    final Paint portalRing = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(pRect.deflate(4), portalRing);

    final Paint innerCore = Paint()..color = const Color(0xFFCCFBF1);
    canvas.drawCircle(center, 12, innerCore);
  }

  void _drawCollectibles(Canvas canvas) {
    for (final c in game.levelData.collectibles) {
      if (c.isCollected) continue;
      c.update(0.016); // Small step timer for floating effect

      final double floatY = sin(c.animTimer) * 4.0;
      final Offset pos = c.position + Offset(0, floatY);
      final Rect rect = Rect.fromLTWH(pos.dx, pos.dy, c.size.width, c.size.height);

      // Glow Effect
      final Paint glow = Paint()
        ..color = const Color(0xAA5EEAD4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(rect.center, 12, glow);

      // Diamond Crystal Shape
      final Path crystal = Path()
        ..moveTo(rect.center.dx, rect.top)
        ..lineTo(rect.right, rect.center.dy)
        ..lineTo(rect.center.dx, rect.bottom)
        ..lineTo(rect.left, rect.center.dy)
        ..close();

      final Paint crystalPaint = Paint()..color = const Color(0xFF2DD4BF);
      canvas.drawPath(crystal, crystalPaint);
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final enemy in game.levelData.enemies) {
      if (!enemy.isAlive) continue;

      final rect = enemy.bounds;

      if (enemy.type == EnemyType.slime) {
        final Paint slimePaint = Paint()
          ..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFFDC2626);
        final Path body = Path()
          ..moveTo(rect.left, rect.bottom)
          ..quadraticBezierTo(rect.center.dx, rect.top - 4, rect.right, rect.bottom)
          ..close();
        canvas.drawPath(body, slimePaint);

        // Eyes
        final Paint eyePaint = Paint()..color = Colors.yellow;
        canvas.drawCircle(Offset(rect.center.dx - 4, rect.center.dy), 3, eyePaint);
        canvas.drawCircle(Offset(rect.center.dx + 4, rect.center.dy), 3, eyePaint);
      } else if (enemy.type == EnemyType.goblin) {
        final Paint goblinPaint = Paint()
          ..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFF15803D);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), goblinPaint);

        // Eyes
        final Paint eyePaint = Paint()..color = Colors.redAccent;
        canvas.drawCircle(Offset(rect.center.dx - 5, rect.top + 10), 3, eyePaint);
        canvas.drawCircle(Offset(rect.center.dx + 5, rect.top + 10), 3, eyePaint);
      } else {
        // Flying Bat
        final Paint batPaint = Paint()
          ..color = enemy.hurtTimer > 0 ? Colors.white : const Color(0xFF7C3AED);
        canvas.drawCircle(rect.center, rect.width * 0.4, batPaint);

        // Wings
        final Path wings = Path()
          ..moveTo(rect.center.dx, rect.center.dy)
          ..lineTo(rect.left - 8, rect.top)
          ..lineTo(rect.left, rect.bottom)
          ..moveTo(rect.center.dx, rect.center.dy)
          ..lineTo(rect.right + 8, rect.top)
          ..lineTo(rect.right, rect.bottom);
        canvas.drawPath(wings, batPaint);
      }
    }
  }

  void _drawPlayer(Canvas canvas) {
    final player = game.player;

    // Flash when invulnerable
    if (player.isInvulnerable && (player.invulnerabilityTimer * 10).toInt() % 2 == 0) {
      return;
    }

    final rect = player.bounds;

    // Player Body (Cute Fantasy Adventurer Cloak & Character)
    final Paint cloakPaint = Paint()..color = const Color(0xFF0D9488); // Teal Cloak
    final Paint skinPaint = Paint()..color = const Color(0xFFFDE047); // Golden Glow Face/Hood Inner

    // Hood / Head
    canvas.drawCircle(Offset(rect.center.dx, rect.top + 14), 14, cloakPaint);
    canvas.drawCircle(Offset(rect.center.dx, rect.top + 15), 9, skinPaint);

    // Cute Adventurer Eyes
    final Paint eyePaint = Paint()..color = const Color(0xFF0F172A);
    final double eyeOffset = player.isFacingRight ? 3.0 : -3.0;
    canvas.drawCircle(Offset(rect.center.dx + eyeOffset - 2, rect.top + 14), 2, eyePaint);
    canvas.drawCircle(Offset(rect.center.dx + eyeOffset + 3, rect.top + 14), 2, eyePaint);

    // Body / Cloak Taper
    final Path bodyPath = Path()
      ..moveTo(rect.left + 4, rect.top + 22)
      ..lineTo(rect.right - 4, rect.top + 22)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    canvas.drawPath(bodyPath, cloakPaint);

    // Render Attack Slash Effect if attacking
    if (player.isAttacking) {
      final attackRect = player.attackBounds;
      final Paint slashGlow = Paint()
        ..color = const Color(0xAA5EEAD4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(attackRect, slashGlow);

      final Paint slashBlade = Paint()
        ..color = const Color(0xFFF0FDF4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final Path slashArc = Path();
      if (player.isFacingRight) {
        slashArc.addArc(attackRect, -pi / 3, (2 * pi) / 3);
      } else {
        slashArc.addArc(attackRect, (2 * pi) / 3, (2 * pi) / 3);
      }
      canvas.drawPath(slashArc, slashBlade);
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
