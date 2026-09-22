import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/car_zombie_game_state.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/rendering/character_render_helper.dart';

class CarZombiePainter extends CustomPainter {
  final CarZombieVehicleState car;
  final List<CarZombieEnemy> zombies;
  final List<CarZombieBullet> bullets;
  final List<CarZombieObstacle> obstacles;
  final List<CarZombieCollectible> collectibles;
  final List<CarZombieParticle> particles;
  final double cameraX;
  final double roadY;
  final double time;
  final CharacterData selectedCharacter;

  CarZombiePainter({
    required this.car,
    required this.zombies,
    required this.bullets,
    required this.obstacles,
    required this.collectibles,
    required this.particles,
    required this.cameraX,
    required this.roadY,
    required this.time,
    required this.selectedCharacter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSkyAndParallax(canvas, size);
    _drawRoad(canvas, size);

    canvas.save();
    canvas.translate(-cameraX, 0);

    // 1. Road Obstacles & Collectibles
    _drawObstacles(canvas);
    _drawCollectibles(canvas);

    // 2. Zombies Chasing Behind Car
    _drawZombies(canvas);

    // 3. Car Vehicle & Selected Character
    _drawVehicle(canvas);

    // 4. Bullets, Muzzle Flashes, Particles
    _drawBulletsAndParticles(canvas);

    canvas.restore();
  }

  void _drawSkyAndParallax(Canvas canvas, Size size) {
    // Night Sky
    final Rect rect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E1B4B)],
      ).createShader(rect);

    canvas.drawRect(rect, skyPaint);

    // Moon
    canvas.drawCircle(Offset(size.width * 0.85, 60), 32, Paint()..color = const Color(0x33FDE68A));
    canvas.drawCircle(Offset(size.width * 0.85, 60), 22, Paint()..color = const Color(0xFFFEF08A));

    // Stars
    final Paint starPaint = Paint()..color = Colors.white70;
    for (int i = 0; i < 25; i++) {
      final double sx = ((i * 137.5) % size.width);
      final double sy = ((i * 73.1) % (size.height * 0.4));
      canvas.drawCircle(Offset(sx, sy), 1.2, starPaint);
    }

    // Parallax Mountain Silhouette
    final double farCamX = cameraX * 0.2;
    final Paint mountainPaint = Paint()..color = const Color(0xFF090D16);
    final Path mountainPath = Path()..moveTo(0, size.height);

    const double spacing = 180;
    final double startX = -((farCamX) % spacing) - spacing;
    for (double x = startX; x < size.width + spacing * 2; x += spacing) {
      final double peakY = roadY - 140 - (sin(x * 0.015) * 40).abs();
      mountainPath.lineTo(x + spacing / 2, peakY);
      mountainPath.lineTo(x + spacing, roadY - 60);
    }
    mountainPath.lineTo(size.width, size.height);
    mountainPath.close();
    canvas.drawPath(mountainPath, mountainPaint);
  }

  void _drawRoad(Canvas canvas, Size size) {
    final double roadHeight = size.height - roadY;
    final Rect roadRect = Rect.fromLTWH(0, roadY, size.width, roadHeight);

    // Asphalt Surface
    canvas.drawRect(roadRect, Paint()..color = const Color(0xFF1E293B));

    // Road Curb Top Line
    canvas.drawRect(Rect.fromLTWH(0, roadY - 4, size.width, 6), Paint()..color = const Color(0xFF334155));

    // Dashed Lane Center Line
    final Paint lanePaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 3.0;

    const double dashW = 40.0;
    const double dashGap = 30.0;
    final double dashStart = -((cameraX) % (dashW + dashGap));

    final double laneY = roadY + roadHeight * 0.5;
    for (double x = dashStart; x < size.width + dashW; x += (dashW + dashGap)) {
      canvas.drawLine(Offset(x, laneY), Offset(x + dashW, laneY), lanePaint);
    }
  }

  void _drawVehicle(Canvas canvas) {
    canvas.save();
    canvas.translate(car.x, car.y);

    final bool isDamageFlash = car.damageFlashTimer > 0;
    final Color chassisColor = isDamageFlash ? const Color(0xFFEF4444) : const Color(0xFF2563EB);
    final Color roofColor = isDamageFlash ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8);

    // Headlight Rays Beam (Firing forward)
    final Path headlightBeam = Path()
      ..moveTo(car.width - 5, car.height - 25)
      ..lineTo(car.width + 300, car.height - 50)
      ..lineTo(car.width + 300, car.height + 40)
      ..lineTo(car.width - 5, car.height - 10)
      ..close();

    final Paint beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(car.width, car.height - 50, 300, 90));
    canvas.drawPath(headlightBeam, beamPaint);

    // Car Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(car.width / 2, car.height + 2), width: car.width * 0.9, height: 12),
      Paint()..color = const Color(0x66000000),
    );

    // Car Roof / Cabin
    final Path cabinPath = Path()
      ..moveTo(25, 18)
      ..lineTo(45, 0)
      ..lineTo( car.width - 35, 0)
      ..lineTo(car.width - 15, 18)
      ..close();
    canvas.drawPath(cabinPath, Paint()..color = roofColor);

    // Glass Windshield & Selected Character Visible Inside
    final Path windowPath = Path()
      ..moveTo(48, 3)
      ..lineTo(car.width - 38, 3)
      ..lineTo(car.width - 20, 16)
      ..lineTo(30, 16)
      ..close();
    canvas.drawPath(windowPath, Paint()..color = const Color(0x9938BDF8));

    // Render Selected Character inside Driver Cabin!
    canvas.save();
    canvas.translate(car.width * 0.45, 12);
    CharacterRenderHelper.drawCharacter(
      canvas: canvas,
      character: selectedCharacter,
      w: 28,
      h: 42,
      topY: -20,
      time: time,
      armAngle: 0.8,
      legAngle1: 0,
      legAngle2: 0,
    );
    canvas.restore();

    // Car Main Body Chassis
    final RRect chassisRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 16, car.width, car.height - 22),
      const Radius.circular(10),
    );
    canvas.drawRRect(chassisRRect, Paint()..color = chassisColor);

    // Bumper & Grill
    canvas.drawRect(Rect.fromLTWH(car.width - 10, 26, 10, 18), Paint()..color = const Color(0xFF475569));
    canvas.drawRect(Rect.fromLTWH(0, 26, 8, 18), Paint()..color = const Color(0xFF334155));

    // Headlight Lens
    canvas.drawCircle(Offset(car.width - 4, 28), 5, Paint()..color = const Color(0xFFFEF08A));

    // Wheels (Front & Rear)
    _drawWheel(canvas, Offset(28, car.height - 6));
    _drawWheel(canvas, Offset(car.width - 32, car.height - 6));

    canvas.restore();
  }

  void _drawWheel(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(car.wheelRotation);

    // Tire Rubber
    canvas.drawCircle(Offset.zero, 15, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFF64748B));
    canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFF94A3B8));

    // Wheel Spokes
    final Paint spokePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(-10, 0), const Offset(10, 0), spokePaint);
    canvas.drawLine(const Offset(0, -10), const Offset(0, 10), spokePaint);

    canvas.restore();
  }

  void _drawZombies(Canvas canvas) {
    for (final z in zombies) {
      if (z.health <= 0) continue;
      canvas.save();
      canvas.translate(z.x + z.width / 2, z.y + z.height / 2);

      final bool isHit = z.hitTimer > 0;
      final Color bodyColor = isHit
          ? const Color(0xFFFF4D4D)
          : (z.type == CarZombieEnemyType.large ? const Color(0xFF0D1F13) : const Color(0xFF1E2D24));

      final double squish = sin(time * 12 + z.x) * 0.1;
      final double w = z.width * (1.0 + squish);
      final double h = z.height * (1.0 - squish);

      // Body & Head
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(8),
      );
      canvas.drawRRect(rrect, Paint()..color = bodyColor);

      // Glowing Eyes
      final Color eyeColor = z.type == CarZombieEnemyType.large ? const Color(0xFFFF3300) : const Color(0xFFFF5500);
      canvas.drawCircle(Offset(w * 0.2, -h * 0.25), 3.5, Paint()..color = eyeColor);
      canvas.drawCircle(Offset(-w * 0.2, -h * 0.25), 3.5, Paint()..color = eyeColor);

      // Arm reaching forward toward car
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, -h * 0.1, 14, 8), const Radius.circular(3)),
        Paint()..color = bodyColor,
      );

      canvas.restore();
    }
  }

  void _drawObstacles(Canvas canvas) {
    for (final obs in obstacles) {
      if (obs.isDestroyed) continue;

      canvas.save();
      canvas.translate(obs.x + obs.width / 2, obs.y + obs.height / 2);

      if (obs.type == CarZombieObstacleType.wreckCar) {
        // Wrecked Car
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: obs.width, height: obs.height), const Radius.circular(8)),
          Paint()..color = const Color(0xFF7F1D1D),
        );
        canvas.drawCircle(Offset(-obs.width * 0.3, obs.height * 0.3), 8, Paint()..color = const Color(0xFF0F172A));
        canvas.drawCircle(Offset(obs.width * 0.3, obs.height * 0.3), 8, Paint()..color = const Color(0xFF0F172A));
      } else if (obs.type == CarZombieObstacleType.rock) {
        // Road Rock
        final Path rockPath = Path()
          ..moveTo(-obs.width / 2, obs.height / 2)
          ..lineTo(-obs.width * 0.3, -obs.height / 2)
          ..lineTo(obs.width * 0.2, -obs.height * 0.4)
          ..lineTo(obs.width / 2, obs.height / 2)
          ..close();
        canvas.drawPath(rockPath, Paint()..color = const Color(0xFF475569));
      } else {
        // Barricade
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: obs.width, height: obs.height), Paint()..color = const Color(0xFFD97706));
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: obs.width * 0.8, height: obs.height * 0.4), Paint()..color = Colors.white70);
      }

      canvas.restore();
    }
  }

  void _drawCollectibles(Canvas canvas) {
    for (final col in collectibles) {
      if (col.isCollected) continue;

      final double hover = sin(time * 5 + col.x) * 4;
      final Offset center = Offset(col.x + col.width / 2, col.y + col.height / 2 + hover);

      if (col.type == CarZombieCollectibleType.coin) {
        canvas.drawCircle(center, 12, Paint()..color = GameColors.coinGlow.withValues(alpha: 0.4));
        canvas.drawCircle(center, 8, Paint()..color = GameColors.coinGold);
      } else if (col.type == CarZombieCollectibleType.ammoCrate) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 22, height: 20), const Radius.circular(4)),
          Paint()..color = const Color(0xFF10B981),
        );
      } else if (col.type == CarZombieCollectibleType.healthKit) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 22, height: 20), const Radius.circular(4)),
          Paint()..color = const Color(0xFFEF4444),
        );
      }
    }
  }

  void _drawBulletsAndParticles(Canvas canvas) {
    // Bullets
    final Paint bulletPaint = Paint()..color = const Color(0xFFFBBF24);
    final Paint bulletGlow = Paint()..color = const Color(0xAAFEF08A);

    for (final b in bullets) {
      if (!b.isAlive) continue;
      canvas.drawCircle(Offset(b.x, b.y), 6, bulletGlow);
      canvas.drawCircle(Offset(b.x, b.y), 3.5, bulletPaint);
    }

    // Particles
    for (final p in particles) {
      final double progress = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size * progress,
        Paint()..color = p.color.withValues(alpha: progress),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CarZombiePainter oldDelegate) => true;
}
