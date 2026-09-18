import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FireflyParticleSystem extends Component {
  final int count;
  final Vector2 bounds;
  final List<_Firefly> _fireflies = [];
  final Random _random = Random();

  FireflyParticleSystem({this.count = 45, required this.bounds});

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < count; i++) {
      _fireflies.add(_Firefly(
        position: Vector2(
          _random.nextDouble() * bounds.x,
          _random.nextDouble() * bounds.y,
        ),
        radius: 1.5 + _random.nextDouble() * 2.5,
        baseAlpha: 0.3 + _random.nextDouble() * 0.6,
        pulseSpeed: 1.5 + _random.nextDouble() * 2.5,
        vx: (_random.nextDouble() - 0.5) * 15,
        vy: (_random.nextDouble() - 0.5) * 12,
        color: _random.nextBool()
            ? const Color(0xFF64FFDA) // Cyan/Teal glow
            : const Color(0xFFA7F3D0), // Soft lime/emerald glow
      ));
    }
  }

  @override
  void update(double dt) {
    for (var firefly in _fireflies) {
      firefly.update(dt, bounds, _random);
    }
  }

  @override
  void render(Canvas canvas) {
    for (var firefly in _fireflies) {
      firefly.render(canvas);
    }
  }
}

class _Firefly {
  Vector2 position;
  double radius;
  double baseAlpha;
  double pulseSpeed;
  double vx;
  double vy;
  Color color;
  double time = 0;

  _Firefly({
    required this.position,
    required this.radius,
    required this.baseAlpha,
    required this.pulseSpeed,
    required this.vx,
    required this.vy,
    required this.color,
  });

  void update(double dt, Vector2 bounds, Random random) {
    time += dt * pulseSpeed;
    position.x += vx * dt;
    position.y += vy * dt;

    if (position.x < -20) position.x = bounds.x + 20;
    if (position.x > bounds.x + 20) position.x = -20;
    if (position.y < -20) position.y = bounds.y + 20;
    if (position.y > bounds.y + 20) position.y = -20;
  }

  void render(Canvas canvas) {
    final currentAlpha = (baseAlpha * (0.5 + 0.5 * sin(time))).clamp(0.0, 1.0);
    final paintGlow = Paint()
      ..color = color.withValues(alpha: currentAlpha * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final paintCore = Paint()
      ..color = color.withValues(alpha: currentAlpha);

    canvas.drawCircle(position.toOffset(), radius * 2.2, paintGlow);
    canvas.drawCircle(position.toOffset(), radius, paintCore);
  }
}

class CollectibleBurstEffect extends PositionComponent {
  final List<_Spark> _sparks = [];
  double _lifetime = 0.5;

  CollectibleBurstEffect({required Vector2 center}) : super(position: center) {
    final random = Random();
    for (int i = 0; i < 16; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 40 + random.nextDouble() * 80;
      _sparks.add(_Spark(
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        color: random.nextBool()
            ? const Color(0xFF00E5FF)
            : const Color(0xFFE040FB),
        size: 2.0 + random.nextDouble() * 3.0,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
      return;
    }
    for (var spark in _sparks) {
      spark.position += spark.velocity * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_lifetime / 0.5).clamp(0.0, 1.0);
    for (var spark in _sparks) {
      final paint = Paint()..color = spark.color.withValues(alpha: alpha);
      canvas.drawCircle(spark.position.toOffset(), spark.size, paint);
    }
  }
}

class _Spark {
  Vector2 position = Vector2.zero();
  Vector2 velocity;
  Color color;
  double size;

  _Spark({required this.velocity, required this.color, required this.size});
}
