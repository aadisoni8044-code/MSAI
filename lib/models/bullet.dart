import 'vector3d.dart';

class Bullet {
  Vector3D position;
  final Vector3D velocity;
  final double damage;
  final double speed;
  final double maxLifetime;
  double lifetime = 0.0;
  bool isAlive = true;

  Bullet({
    required this.position,
    required Vector3D direction,
    required this.damage,
    this.speed = 45.0,
    this.maxLifetime = 1.5,
  }) : velocity = direction.normalized() * speed;

  void update(double dt) {
    if (!isAlive) return;

    position = position + velocity * dt;
    lifetime += dt;

    if (lifetime >= maxLifetime) {
      isAlive = false;
    }
  }

  bool checkHit(Vector3D targetPos, double hitRadius) {
    if (!isAlive) return false;
    final dist = position.distanceTo(targetPos);
    return dist <= hitRadius;
  }
}
