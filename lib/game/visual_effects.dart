import 'dart:math';
import 'package:flutter/material.dart';

class ParallaxBackground {
  final double worldWidth;
  final double worldHeight;

  ParallaxBackground({
    required this.worldWidth,
    required this.worldHeight,
  });

  void draw(Canvas canvas, Size viewportSize, Offset cameraPos) {
    // 1. Sky Gradient & Atmospheric Glow (Fixed to Screen)
    final Rect bgRect = Rect.fromLTWH(0, 0, viewportSize.width, viewportSize.height);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF070F1E), // Dark midnight blue
          Color(0xFF0F2C3E), // Teal forest atmospheric horizon
          Color(0xFF134E4A), // Deep teal green base glow
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(bgRect);

    canvas.drawRect(bgRect, skyPaint);

    // Glowing Moon / Atmospheric Light
    final Paint moonGlow = Paint()
      ..color = const Color(0x335EEAD4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(Offset(viewportSize.width * 0.75, viewportSize.height * 0.25), 90, moonGlow);

    // 2. Far Background Layer (Distant Forest Silhouette / Mountains) - Parallax factor 0.15
    _drawFarMountains(canvas, viewportSize, cameraPos.dx * 0.15);

    // 3. Mid Background Layer (Twisted Ancient Trees & Hanging Vines) - Parallax factor 0.4
    _drawMidForest(canvas, viewportSize, cameraPos.dx * 0.4);

    // 4. Foreground Vegetation Layer (Bushes & Canopy Silhouettes) - Parallax factor 0.75
    _drawForegroundFoliage(canvas, viewportSize, cameraPos.dx * 0.75);
  }

  void _drawFarMountains(Canvas canvas, Size size, double offsetX) {
    final Paint farPaint = Paint()
      ..color = const Color(0xFF0F3843).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double startX = -(offsetX % 600);

    for (double x = startX - 600; x < size.width + 600; x += 600) {
      path.moveTo(x, size.height);
      path.quadraticBezierTo(x + 150, size.height - 180, x + 300, size.height - 90);
      path.quadraticBezierTo(x + 450, size.height - 240, x + 600, size.height);
    }
    path.lineTo(size.width + 600, size.height);
    path.lineTo(-600, size.height);
    path.close();

    canvas.drawPath(path, farPaint);
  }

  void _drawMidForest(Canvas canvas, Size size, double offsetX) {
    final Paint treePaint = Paint()
      ..color = const Color(0xFF0B242A)
      ..style = PaintingStyle.fill;

    final Paint vinePaint = Paint()
      ..color = const Color(0xFF134E4A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final double startX = -(offsetX % 350);

    for (double x = startX - 350; x < size.width + 350; x += 350) {
      // Large twisted trunk
      final Path trunk = Path();
      trunk.moveTo(x + 80, size.height);
      trunk.quadraticBezierTo(x + 60, size.height * 0.5, x + 110, size.height * 0.1);
      trunk.lineTo(x + 150, size.height * 0.1);
      trunk.quadraticBezierTo(x + 120, size.height * 0.5, x + 160, size.height);
      trunk.close();
      canvas.drawPath(trunk, treePaint);

      // Twisted Canopy
      canvas.drawCircle(Offset(x + 130, size.height * 0.1), 85, treePaint);
      canvas.drawCircle(Offset(x + 80, size.height * 0.15), 65, treePaint);

      // Hanging Vines
      canvas.drawLine(Offset(x + 100, size.height * 0.2), Offset(x + 95, size.height * 0.45), vinePaint);
      canvas.drawLine(Offset(x + 140, size.height * 0.18), Offset(x + 145, size.height * 0.4), vinePaint);
    }
  }

  void _drawForegroundFoliage(Canvas canvas, Size size, double offsetX) {
    final Paint foliagePaint = Paint()
      ..color = const Color(0xFF04181C).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final double startX = -(offsetX % 250);
    for (double x = startX - 250; x < size.width + 250; x += 250) {
      canvas.drawOval(
        Rect.fromLTWH(x, size.height - 40, 180, 70),
        foliagePaint,
      );
    }
  }
}

class Firefly {
  Offset position;
  double radius;
  double speed;
  double angle;
  double opacity;
  double pulseSpeed;

  Firefly({
    required this.position,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
    required this.pulseSpeed,
  });

  void update(double dt, Size viewportSize) {
    angle += (Random().nextDouble() - 0.5) * 0.5;
    position += Offset(cos(angle) * speed * dt, sin(angle) * speed * dt);

    opacity += sin(angle * pulseSpeed) * 0.02;
    opacity = opacity.clamp(0.2, 0.95);

    // Screen bounds wrap around
    if (position.dx < -20) position = Offset(viewportSize.width + 20, position.dy);
    if (position.dx > viewportSize.width + 20) position = Offset(-20, position.dy);
    if (position.dy < -20) position = Offset(position.dx, viewportSize.height + 20);
    if (position.dy > viewportSize.height + 20) position = Offset(position.dx, -20);
  }
}

class VisualEffects {
  final List<Firefly> fireflies = [];
  final Random _random = Random();
  double screenShakeTimer = 0.0;
  double screenShakeIntensity = 0.0;

  VisualEffects(Size viewportSize, {int fireflyCount = 25}) {
    for (int i = 0; i < fireflyCount; i++) {
      fireflies.add(Firefly(
        position: Offset(
          _random.nextDouble() * viewportSize.width,
          _random.nextDouble() * viewportSize.height,
        ),
        radius: 2.0 + _random.nextDouble() * 3.0,
        speed: 15.0 + _random.nextDouble() * 25.0,
        angle: _random.nextDouble() * 2 * pi,
        opacity: 0.3 + _random.nextDouble() * 0.6,
        pulseSpeed: 1.0 + _random.nextDouble() * 2.0,
      ));
    }
  }

  void triggerShake({double duration = 0.25, double intensity = 6.0}) {
    screenShakeTimer = duration;
    screenShakeIntensity = intensity;
  }

  void update(double dt, Size viewportSize) {
    if (screenShakeTimer > 0) {
      screenShakeTimer -= dt;
      if (screenShakeTimer <= 0) {
        screenShakeTimer = 0.0;
        screenShakeIntensity = 0.0;
      }
    }

    for (final f in fireflies) {
      f.update(dt, viewportSize);
    }
  }

  Offset getShakeOffset() {
    if (screenShakeTimer <= 0) return Offset.zero;
    return Offset(
      (_random.nextDouble() - 0.5) * screenShakeIntensity * 2,
      (_random.nextDouble() - 0.5) * screenShakeIntensity * 2,
    );
  }

  void drawFireflies(Canvas canvas) {
    for (final f in fireflies) {
      final Paint glowPaint = Paint()
        ..color = Color.fromRGBO(94, 234, 212, f.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(f.position, f.radius * 2, glowPaint);

      final Paint corePaint = Paint()
        ..color = Color.fromRGBO(240, 253, 250, f.opacity + 0.1);
      canvas.drawCircle(f.position, f.radius * 0.7, corePaint);
    }
  }
}
