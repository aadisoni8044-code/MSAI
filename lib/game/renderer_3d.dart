import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/vector3d.dart';
import '../models/player.dart';
import '../models/zombie.dart';
import '../models/weapon.dart';
import '../models/bullet.dart';
import '../models/item.dart';
import '../systems/map_world.dart';

class Renderer3D extends CustomPainter {
  final Player player;
  final List<Zombie> zombies;
  final List<Bullet> bullets;
  final MapWorld world;
  final Size viewportSize;

  // Camera settings
  final double fov = 70.0;
  final Vector3D lightDirection = Vector3D(0.4, 0.9, -0.5).normalized();

  Renderer3D({
    required this.player,
    required this.zombies,
    required this.bullets,
    required this.world,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;
    final halfWidth = width / 2.0;
    final halfHeight = height / 2.0;
    final fovFactor = halfWidth / math.tan((fov / 2.0) * math.pi / 180.0);

    // Dark Survival Background
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Camera position: Third-person behind player
    final camDist = 6.5;
    final camHeight = 3.2 + math.sin(player.pitch) * 2.0;

    final camX = player.position.x - math.sin(player.yaw) * camDist;
    final camY = player.position.y + camHeight;
    final camZ = player.position.z - math.cos(player.yaw) * camDist;
    final cameraPos = Vector3D(camX, camY, camZ);

    final cosY = math.cos(-player.yaw);
    final sinY = math.sin(-player.yaw);
    final cosP = math.cos(-player.pitch);
    final sinP = math.sin(-player.pitch);

    // Transform world point to screen point
    ScreenPoint? projectPoint(Vector3D point) {
      // 1. Translate relative to camera
      final tx = point.x - cameraPos.x;
      final ty = point.y - cameraPos.y;
      final tz = point.z - cameraPos.z;

      // 2. Rotate around Y (Yaw)
      final rx = tx * cosY + tz * sinY;
      final rz = -tx * sinY + tz * cosY;

      // 3. Rotate around X (Pitch)
      final ry = ty * cosP - rz * sinP;
      final fz = ty * sinP + rz * cosP;

      if (fz <= 0.2) return null; // Behind camera or near plane clip

      final sx = halfWidth + (rx * fovFactor) / fz;
      final sy = halfHeight - (ry * fovFactor) / fz;

      return ScreenPoint(sx, sy, fz);
    }

    List<Polygon3D> renderPolygons = [];

    // --- 1. Ground Plane and Roads ---
    _generateGroundPolygons(projectPoint, cameraPos, renderPolygons);

    // --- 2. Map Obstacles (Buildings, Houses, Vehicles, Trees) ---
    for (var obs in world.obstacles) {
      _generateBoxPolygons(obs.min, obs.max, obs.colorHex, projectPoint, renderPolygons);
    }

    // --- 3. Items / Collectibles / Air-Drop ---
    for (var item in world.items) {
      if (!item.isCollected) {
        _generateItemPolygons(item, projectPoint, renderPolygons);
      }
    }

    // --- 4. Zombies ---
    for (var zombie in zombies) {
      if (zombie.state != ZombieState.dead) {
        _generateZombiePolygons(zombie, projectPoint, renderPolygons);
      }
    }

    // --- 5. Player ---
    _generatePlayerPolygons(player, projectPoint, renderPolygons);

    // --- 6. Z-Sorting (Painter's Algorithm) ---
    renderPolygons.sort((a, b) => b.averageZ.compareTo(a.averageZ));

    // --- 7. Draw Polygons ---
    for (var poly in renderPolygons) {
      final path = Path();
      bool first = true;
      for (var v in poly.vertices) {
        if (first) {
          path.moveTo(v.x, v.y);
          first = false;
        } else {
          path.lineTo(v.x, v.y);
        }
      }
      path.close();

      // Lighting computation
      double lightIntensity = 0.8;
      if (poly.normal != null) {
        final dot = poly.normal!.dot(lightDirection).clamp(0.0, 1.0);
        lightIntensity = 0.35 + dot * 0.65;
      }

      final baseColor = Color(poly.colorValue);
      final shadedColor = Color.fromARGB(
        baseColor.alpha,
        (baseColor.red * lightIntensity).round().clamp(0, 255),
        (baseColor.green * lightIntensity).round().clamp(0, 255),
        (baseColor.blue * lightIntensity).round().clamp(0, 255),
      );

      final paint = Paint()
        ..color = shadedColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }

    // --- 8. Bullets & Muzzle Effects ---
    final bulletPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    for (var bullet in bullets) {
      final sp = projectPoint(bullet.position);
      if (sp != null && sp.x >= 0 && sp.x <= width && sp.y >= 0 && sp.y <= height) {
        final r = (3.0 * (10.0 / sp.z)).clamp(1.5, 6.0);
        canvas.drawCircle(Offset(sp.x, sp.y), r, bulletPaint);
      }
    }
  }

  void _generateGroundPolygons(
      ScreenPoint? Function(Vector3D) project, Vector3D cameraPos, List<Polygon3D> out) {
    // Large ground grid segments
    final gridSize = 20.0;
    final minX = -100.0;
    final maxX = 100.0;
    final minZ = -100.0;
    final maxZ = 100.0;

    for (double x = minX; x < maxX; x += gridSize) {
      for (double z = minZ; z < maxZ; z += gridSize) {
        final p1 = Vector3D(x, 0, z);
        final p2 = Vector3D(x + gridSize, 0, z);
        final p3 = Vector3D(x + gridSize, 0, z + gridSize);
        final p4 = Vector3D(x, 0, z + gridSize);

        final sp1 = project(p1);
        final sp2 = project(p2);
        final sp3 = project(p3);
        final sp4 = project(p4);

        if (sp1 != null && sp2 != null && sp3 != null && sp4 != null) {
          final avgZ = (sp1.z + sp2.z + sp3.z + sp4.z) / 4.0;

          // Road or grass color check
          final isRoad = (x.abs() < 12.0 || z.abs() < 12.0);
          final colorVal = isRoad ? 0xFF1E293B : 0xFF1C2D24;

          out.add(Polygon3D(
            vertices: [
              Vector3D(sp1.x, sp1.y, sp1.z),
              Vector3D(sp2.x, sp2.y, sp2.z),
              Vector3D(sp3.x, sp3.y, sp3.z),
              Vector3D(sp4.x, sp4.y, sp4.z),
            ],
            colorValue: colorVal,
            normal: Vector3D(0, 1, 0),
          )..averageZ = avgZ);
        }
      }
    }
  }

  void _generateBoxPolygons(Vector3D min, Vector3D max, int colorHex,
      ScreenPoint? Function(Vector3D) project, List<Polygon3D> out) {
    final vertices = [
      Vector3D(min.x, min.y, min.z), // 0
      Vector3D(max.x, min.y, min.z), // 1
      Vector3D(max.x, max.y, min.z), // 2
      Vector3D(min.x, max.y, min.z), // 3
      Vector3D(min.x, min.y, max.z), // 4
      Vector3D(max.x, min.y, max.z), // 5
      Vector3D(max.x, max.y, max.z), // 6
      Vector3D(min.x, max.y, max.z), // 7
    ];

    final projected = vertices.map((v) => project(v)).toList();

    void addFace(int i1, int i2, int i3, int i4, Vector3D norm, int color) {
      final p1 = projected[i1];
      final p2 = projected[i2];
      final p3 = projected[i3];
      final p4 = projected[i4];

      if (p1 != null && p2 != null && p3 != null && p4 != null) {
        final avgZ = (p1.z + p2.z + p3.z + p4.z) / 4.0;
        out.add(Polygon3D(
          vertices: [
            Vector3D(p1.x, p1.y, p1.z),
            Vector3D(p2.x, p2.y, p2.z),
            Vector3D(p3.x, p3.y, p3.z),
            Vector3D(p4.x, p4.y, p4.z),
          ],
          colorValue: color,
          normal: norm,
        )..averageZ = avgZ);
      }
    }

    // Front, Back, Top, Bottom, Left, Right faces
    addFace(0, 1, 2, 3, Vector3D(0, 0, -1), colorHex);
    addFace(5, 4, 7, 6, Vector3D(0, 0, 1), colorHex);
    addFace(3, 2, 6, 7, Vector3D(0, 1, 0), (colorHex & 0x00FFFFFF) | 0xFF000000);
    addFace(4, 0, 3, 7, Vector3D(-1, 0, 0), colorHex);
    addFace(1, 5, 6, 2, Vector3D(1, 0, 0), colorHex);
  }

  void _generateItemPolygons(
      Item item, ScreenPoint? Function(Vector3D) project, List<Polygon3D> out) {
    final floatY = item.position.y + 0.5 + math.sin(item.animPhase) * 0.2;
    final pos = Vector3D(item.position.x, floatY, item.position.z);

    int color = 0xFF10B981; // Green for health
    if (item.type == ItemType.ammoCrate) color = 0xFFF59E0B; // Gold for ammo
    if (item.type == ItemType.airDropAK47) color = 0xFFEF4444; // Red for AK-47 air-drop

    final size = item.type == ItemType.airDropAK47 ? 1.2 : 0.6;
    final min = pos - Vector3D(size, size, size);
    final max = pos + Vector3D(size, size, size);

    _generateBoxPolygons(min, max, color, project, out);
  }

  void _generateZombiePolygons(
      Zombie zombie, ScreenPoint? Function(Vector3D) project, List<Polygon3D> out) {
    final pos = zombie.position;
    final yaw = zombie.yaw;
    final walkLeg = math.sin(zombie.animPhase) * 0.3;

    int bodyColor = 0xFF4B5563;
    if (zombie.type == ZombieType.fast) bodyColor = 0xFFDC2626;
    if (zombie.type == ZombieType.tank) bodyColor = 0xFF1E1B4B;

    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);

    Vector3D localToWorld(double lx, double ly, double lz) {
      final rx = lx * cosY + lz * sinY;
      final rz = -lx * sinY + lz * cosY;
      return Vector3D(pos.x + rx, pos.y + ly, pos.z + rz);
    }

    // Zombie Body Cubes (Torso, Head)
    _generateRotatedBox(localToWorld, Vector3D(-0.4, 0.7, -0.2), Vector3D(0.4, 1.5, 0.2), bodyColor, project, out);
    _generateRotatedBox(localToWorld, Vector3D(-0.25, 1.5, -0.25), Vector3D(0.25, 1.9, 0.25), 0xFF15803D, project, out);
    // Arms reaching out forward
    _generateRotatedBox(localToWorld, Vector3D(-0.55, 1.1, 0.2), Vector3D(-0.35, 1.3, 0.9), 0xFF15803D, project, out);
    _generateRotatedBox(localToWorld, Vector3D(0.35, 1.1, 0.2), Vector3D(0.55, 1.3, 0.9), 0xFF15803D, project, out);
    // Legs walking animation
    _generateRotatedBox(localToWorld, Vector3D(-0.3, 0.0, -0.15 + walkLeg), Vector3D(-0.05, 0.7, 0.15 + walkLeg), 0xFF1F2937, project, out);
    _generateRotatedBox(localToWorld, Vector3D(0.05, 0.0, -0.15 - walkLeg), Vector3D(0.3, 0.7, 0.15 - walkLeg), 0xFF1F2937, project, out);
  }

  void _generatePlayerPolygons(
      Player player, ScreenPoint? Function(Vector3D) project, List<Polygon3D> out) {
    final pos = player.position;
    final yaw = player.yaw;
    final walkLeg = math.sin(player.walkAnimPhase) * 0.35;

    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);

    Vector3D localToWorld(double lx, double ly, double lz) {
      final rx = lx * cosY + lz * sinY;
      final rz = -lx * sinY + lz * cosY;
      return Vector3D(pos.x + rx, pos.y + ly, pos.z + rz);
    }

    // Torso, Head, Legs
    _generateRotatedBox(localToWorld, Vector3D(-0.4, 0.7, -0.2), Vector3D(0.4, 1.5, 0.2), 0xFF1E40AF, project, out); // Blue jacket
    _generateRotatedBox(localToWorld, Vector3D(-0.25, 1.5, -0.25), Vector3D(0.25, 1.9, 0.25), 0xFFFCD34D, project, out); // Head
    _generateRotatedBox(localToWorld, Vector3D(-0.3, 0.0, -0.15 + walkLeg), Vector3D(-0.05, 0.7, 0.15 + walkLeg), 0xFF111827, project, out);
    _generateRotatedBox(localToWorld, Vector3D(0.05, 0.0, -0.15 - walkLeg), Vector3D(0.3, 0.7, 0.15 - walkLeg), 0xFF111827, project, out);

    // Active Weapon Model
    int gunColor = 0xFF6B7280;
    if (player.activeWeapon.type == WeaponType.sword) gunColor = 0xFFE5E7EB;
    if (player.activeWeapon.type == WeaponType.ak47) gunColor = 0xFFB45309;

    _generateRotatedBox(localToWorld, Vector3D(0.25, 1.1, 0.1), Vector3D(0.4, 1.3, 0.9), gunColor, project, out);
  }

  void _generateRotatedBox(
      Vector3D Function(double, double, double) localToWorld,
      Vector3D min,
      Vector3D max,
      int color,
      ScreenPoint? Function(Vector3D) project,
      List<Polygon3D> out) {
    final v0 = localToWorld(min.x, min.y, min.z);
    final v1 = localToWorld(max.x, min.y, min.z);
    final v2 = localToWorld(max.x, max.y, min.z);
    final v3 = localToWorld(min.x, max.y, min.z);
    final v4 = localToWorld(min.x, min.y, max.z);
    final v5 = localToWorld(max.x, min.y, max.z);
    final v6 = localToWorld(max.x, max.y, max.z);
    final v7 = localToWorld(min.x, max.y, max.z);

    final p = [v0, v1, v2, v3, v4, v5, v6, v7].map((v) => project(v)).toList();

    void addF(int i1, int i2, int i3, int i4, Vector3D norm) {
      if (p[i1] != null && p[i2] != null && p[i3] != null && p[i4] != null) {
        final avgZ = (p[i1]!.z + p[i2]!.z + p[i3]!.z + p[i4]!.z) / 4.0;
        out.add(Polygon3D(
          vertices: [
            Vector3D(p[i1]!.x, p[i1]!.y, p[i1]!.z),
            Vector3D(p[i2]!.x, p[i2]!.y, p[i2]!.z),
            Vector3D(p[i3]!.x, p[i3]!.y, p[i3]!.z),
            Vector3D(p[i4]!.x, p[i4]!.y, p[i4]!.z),
          ],
          colorValue: color,
          normal: norm,
        )..averageZ = avgZ);
      }
    }

    addF(0, 1, 2, 3, Vector3D(0, 0, -1));
    addF(5, 4, 7, 6, Vector3D(0, 0, 1));
    addF(3, 2, 6, 7, Vector3D(0, 1, 0));
    addF(4, 0, 3, 7, Vector3D(-1, 0, 0));
    addF(1, 5, 6, 2, Vector3D(1, 0, 0));
  }

  @override
  bool shouldRepaint(covariant Renderer3D oldDelegate) => true;
}

class ScreenPoint {
  final double x;
  final double y;
  final double z;

  ScreenPoint(this.x, this.y, this.z);
}
