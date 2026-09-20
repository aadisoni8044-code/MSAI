import 'dart:math' as math;
import '../models/vector3d.dart';
import '../models/item.dart';

class Obstacle {
  final String id;
  final String type; // 'building', 'house', 'vehicle', 'tree'
  final Vector3D min; // Bounding box min
  final Vector3D max; // Bounding box max
  final int colorHex;

  Obstacle({
    required this.id,
    required this.type,
    required this.min,
    required this.max,
    required this.colorHex,
  });

  bool containsXZ(Vector3D point, double padding) {
    return point.x >= min.x - padding &&
        point.x <= max.x + padding &&
        point.z >= min.z - padding &&
        point.z <= max.z + padding;
  }
}

class MapWorld {
  final double mapWidth = 200.0;
  final double mapLength = 200.0;

  final List<Obstacle> obstacles = [];
  final List<Vector3D> spawnPoints = [];
  final List<Item> items = [];

  MapWorld() {
    _generateMap();
  }

  void _generateMap() {
    // 1. Map Outer Boundaries
    obstacles.add(Obstacle(
      id: 'wall_north',
      type: 'building',
      min: Vector3D(-100, 0, -100),
      max: Vector3D(100, 15, -96),
      colorHex: 0xFF2A2D34,
    ));
    obstacles.add(Obstacle(
      id: 'wall_south',
      type: 'building',
      min: Vector3D(-100, 0, 96),
      max: Vector3D(100, 15, 100),
      colorHex: 0xFF2A2D34,
    ));
    obstacles.add(Obstacle(
      id: 'wall_west',
      type: 'building',
      min: Vector3D(-100, 0, -100),
      max: Vector3D(-96, 15, 100),
      colorHex: 0xFF2A2D34,
    ));
    obstacles.add(Obstacle(
      id: 'wall_east',
      type: 'building',
      min: Vector3D(96, 0, -100),
      max: Vector3D(100, 15, 100),
      colorHex: 0xFF2A2D34,
    ));

    // 2. Abandoned Skyscrapers / Tall Office Buildings
    obstacles.add(Obstacle(
      id: 'bldg_1',
      type: 'building',
      min: Vector3D(-60, 0, -70),
      max: Vector3D(-35, 25, -45),
      colorHex: 0xFF3D405B,
    ));
    obstacles.add(Obstacle(
      id: 'bldg_2',
      type: 'building',
      min: Vector3D(35, 0, -75),
      max: Vector3D(65, 30, -45),
      colorHex: 0xFF2B2D42,
    ));
    obstacles.add(Obstacle(
      id: 'bldg_3',
      type: 'building',
      min: Vector3D(-70, 0, 30),
      max: Vector3D(-40, 22, 60),
      colorHex: 0xFF4A4E69,
    ));
    obstacles.add(Obstacle(
      id: 'bldg_4',
      type: 'building',
      min: Vector3D(40, 0, 35),
      max: Vector3D(70, 28, 65),
      colorHex: 0xFF353535,
    ));

    // 3. Small Houses
    obstacles.add(Obstacle(
      id: 'house_1',
      type: 'house',
      min: Vector3D(-25, 0, -65),
      max: Vector3D(-10, 6, -50),
      colorHex: 0xFF8D0801,
    ));
    obstacles.add(Obstacle(
      id: 'house_2',
      type: 'house',
      min: Vector3D(10, 0, -65),
      max: Vector3D(25, 6, -50),
      colorHex: 0xFF9E2A2B,
    ));
    obstacles.add(Obstacle(
      id: 'house_3',
      type: 'house',
      min: Vector3D(-25, 0, 50),
      max: Vector3D(-10, 6, 65),
      colorHex: 0xFF6B705C,
    ));
    obstacles.add(Obstacle(
      id: 'house_4',
      type: 'house',
      min: Vector3D(10, 0, 50),
      max: Vector3D(25, 6, 65),
      colorHex: 0xFFB5838D,
    ));

    // 4. Broken Vehicles
    obstacles.add(Obstacle(
      id: 'vehicle_1',
      type: 'vehicle',
      min: Vector3D(-12, 0, -15),
      max: Vector3D(-6, 2.5, -9),
      colorHex: 0xFF582F0E,
    ));
    obstacles.add(Obstacle(
      id: 'vehicle_2',
      type: 'vehicle',
      min: Vector3D(8, 0, 12),
      max: Vector3D(14, 2.8, 18),
      colorHex: 0xFF3A5A40,
    ));
    obstacles.add(Obstacle(
      id: 'vehicle_3',
      type: 'vehicle',
      min: Vector3D(-18, 0, 10),
      max: Vector3D(-12, 2.2, 16),
      colorHex: 0xFF2A3439,
    ));

    // 5. Trees low poly
    final treeLocations = [
      Vector3D(-80, 0, -10),
      Vector3D(-85, 0, 10),
      Vector3D(80, 0, -15),
      Vector3D(85, 0, 15),
      Vector3D(-45, 0, -15),
      Vector3D(45, 0, -15),
      Vector3D(-45, 0, 15),
      Vector3D(45, 0, 15),
      Vector3D(0, 0, -85),
      Vector3D(0, 0, 85),
    ];

    for (int i = 0; i < treeLocations.length; i++) {
      final loc = treeLocations[i];
      obstacles.add(Obstacle(
        id: 'tree_$i',
        type: 'tree',
        min: Vector3D(loc.x - 1.2, 0, loc.z - 1.2),
        max: Vector3D(loc.x + 1.2, 8, loc.z + 1.2),
        colorHex: 0xFF2D6A4F,
      ));
    }

    // 6. Zombie Spawn Nodes around outer map zones
    spawnPoints.addAll([
      Vector3D(-80, 0, -80),
      Vector3D(80, 0, -80),
      Vector3D(-80, 0, 80),
      Vector3D(80, 0, 80),
      Vector3D(-90, 0, 0),
      Vector3D(90, 0, 0),
      Vector3D(0, 0, -90),
      Vector3D(0, 0, 90),
    ]);

    // Initial item drops
    items.add(Item(
      id: 'init_health_1',
      type: ItemType.healthPack,
      position: Vector3D(-15, 0, -5),
      quantity: 1,
    ));
    items.add(Item(
      id: 'init_ammo_1',
      type: ItemType.ammoCrate,
      position: Vector3D(15, 0, 5),
      quantity: 2,
    ));
  }

  bool checkObstacleCollision(Vector3D pos, double padding) {
    for (var obstacle in obstacles) {
      if (obstacle.containsXZ(pos, padding)) {
        return true;
      }
    }
    return false;
  }

  Vector3D getRandomSpawnPoint(Vector3D playerPos) {
    // Pick spawn point at least 20 units away from player
    final rand = math.Random();
    final sortedByDistance = List<Vector3D>.from(spawnPoints);
    sortedByDistance.sort((a, b) => b.distanceToXZ(playerPos).compareTo(a.distanceToXZ(playerPos)));

    final candidateIndex = rand.nextInt(math.min(4, sortedByDistance.length));
    final basePos = sortedByDistance[candidateIndex];

    // Add small random offset
    return Vector3D(
      basePos.x + (rand.nextDouble() - 0.5) * 6.0,
      0.0,
      basePos.z + (rand.nextDouble() - 0.5) * 6.0,
    );
  }

  void update(double dt) {
    for (var item in items) {
      item.update(dt);
    }
  }
}
