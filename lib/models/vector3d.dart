import 'dart:math' as math;

/// Represents a 3D vector and point in space.
class Vector3D {
  double x;
  double y;
  double z;

  Vector3D(this.x, this.y, this.z);

  factory Vector3D.zero() => Vector3D(0.0, 0.0, 0.0);
  factory Vector3D.copy(Vector3D v) => Vector3D(v.x, v.y, v.z);

  Vector3D operator +(Vector3D v) => Vector3D(x + v.x, y + v.y, z + v.z);
  Vector3D operator -(Vector3D v) => Vector3D(x - v.x, y - v.y, z - v.z);
  Vector3D operator *(double scalar) => Vector3D(x * scalar, y * scalar, z * scalar);
  Vector3D operator /(double scalar) => Vector3D(x / scalar, y / scalar, z / scalar);

  double get lengthSquared => x * x + y * y + z * z;
  double get length => math.sqrt(lengthSquared);

  Vector3D normalized() {
    final len = length;
    if (len == 0.0) return Vector3D.zero();
    return this / len;
  }

  double dot(Vector3D v) => x * v.x + y * v.y + z * v.z;

  Vector3D cross(Vector3D v) {
    return Vector3D(
      y * v.z - z * v.y,
      z * v.x - x * v.z,
      x * v.y - y * v.x,
    );
  }

  double distanceTo(Vector3D v) {
    final dx = x - v.x;
    final dy = y - v.y;
    final dz = z - v.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  double distanceToXZ(Vector3D v) {
    final dx = x - v.x;
    final dz = z - v.z;
    return math.sqrt(dx * dx + dz * dz);
  }

  Vector3D rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3D(
      x * cosA + z * sinA,
      y,
      -x * sinA + z * cosA,
    );
  }

  Vector3D rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3D(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }

  Vector3D rotateZ(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3D(
      x * cosA - y * sinA,
      x * sinA + y * cosA,
      z,
    );
  }

  @override
  String toString() => 'Vector3D(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})';
}

/// A polygon in 3D space with transformed screen coordinates for rendering.
class Polygon3D {
  final List<Vector3D> vertices;
  final int colorValue;
  Vector3D? normal;
  double averageZ = 0.0;

  Polygon3D({
    required this.vertices,
    required this.colorValue,
    this.normal,
  }) {
    calculateNormal();
  }

  void calculateNormal() {
    if (vertices.length < 3) return;
    final v0 = vertices[0];
    final v1 = vertices[1];
    final v2 = vertices[2];
    final edge1 = v1 - v0;
    final edge2 = v2 - v0;
    normal = edge1.cross(edge2).normalized();
  }
}
