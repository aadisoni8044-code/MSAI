import 'dart:convert';

class CustomMapEntity {
  final String id;
  final String type; // e.g., 'platform', 'movingPlatform', 'slipperyPlatform', 'enemySlime', 'enemyShadow', 'enemyFire', 'enemyIce', 'enemyToxic', 'hazardSpike', 'hazardLava', 'hazardPoison', 'hazardLightning', 'coin', 'healthPot', 'checkpoint', 'decorTree', 'decorRock', 'decorBush', 'decorFlower', 'decorCrystal', 'decorRuin', 'decorLamp', 'decorSign'
  double x;
  double y;
  double width;
  double height;
  double patrolRange;
  double moveRangeY;
  double vx;
  double vy;
  int health;

  CustomMapEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.patrolRange = 100,
    this.moveRangeY = 0,
    this.vx = 1.2,
    this.vy = 0,
    this.health = 1,
  });

  CustomMapEntity copyWith({
    String? id,
    String? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? patrolRange,
    double? moveRangeY,
    double? vx,
    double? vy,
    int? health,
  }) {
    return CustomMapEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      patrolRange: patrolRange ?? this.patrolRange,
      moveRangeY: moveRangeY ?? this.moveRangeY,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      health: health ?? this.health,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'patrolRange': patrolRange,
        'moveRangeY': moveRangeY,
        'vx': vx,
        'vy': vy,
        'health': health,
      };

  factory CustomMapEntity.fromJson(Map<String, dynamic> json) => CustomMapEntity(
        id: json['id'] as String,
        type: json['type'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        patrolRange: (json['patrolRange'] as num?)?.toDouble() ?? 100,
        moveRangeY: (json['moveRangeY'] as num?)?.toDouble() ?? 0,
        vx: (json['vx'] as num?)?.toDouble() ?? 1.2,
        vy: (json['vy'] as num?)?.toDouble() ?? 0,
        health: json['health'] as int? ?? 1,
      );
}

class CustomMapData {
  final String id;
  String name;
  String theme; // 'forest', 'fire', 'water', 'ice', 'desert', 'thunder', 'poison', 'sky', 'shadow', 'crystal'
  double worldWidth;
  double worldHeight;
  double playerStartX;
  double playerStartY;
  double finishX;
  double finishY;
  bool isTemplate;
  DateTime createdDate;
  DateTime updatedDate;

  // Saved Stats
  double? bestTimeSeconds;
  int highestCoinsCollected;
  int totalAttempts;
  bool isCompleted;

  List<CustomMapEntity> entities;

  CustomMapData({
    required this.id,
    required this.name,
    this.theme = 'forest',
    this.worldWidth = 4800.0,
    this.worldHeight = 800.0,
    this.playerStartX = 100.0,
    this.playerStartY = 620.0,
    this.finishX = 4500.0,
    this.finishY = 590.0,
    this.isTemplate = false,
    DateTime? createdDate,
    DateTime? updatedDate,
    this.bestTimeSeconds,
    this.highestCoinsCollected = 0,
    this.totalAttempts = 0,
    this.isCompleted = false,
    required this.entities,
  })  : createdDate = createdDate ?? DateTime.now(),
        updatedDate = updatedDate ?? DateTime.now();

  CustomMapData copyAsNewMap({required String newId, required String newName}) {
    return CustomMapData(
      id: newId,
      name: newName,
      theme: theme,
      worldWidth: worldWidth,
      worldHeight: worldHeight,
      playerStartX: playerStartX,
      playerStartY: playerStartY,
      finishX: finishX,
      finishY: finishY,
      isTemplate: false,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      entities: entities.map((e) => e.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'theme': theme,
        'worldWidth': worldWidth,
        'worldHeight': worldHeight,
        'playerStartX': playerStartX,
        'playerStartY': playerStartY,
        'finishX': finishX,
        'finishY': finishY,
        'isTemplate': isTemplate,
        'createdDate': createdDate.toIso8601String(),
        'updatedDate': updatedDate.toIso8601String(),
        'bestTimeSeconds': bestTimeSeconds,
        'highestCoinsCollected': highestCoinsCollected,
        'totalAttempts': totalAttempts,
        'isCompleted': isCompleted,
        'entities': entities.map((e) => e.toJson()).toList(),
      };

  factory CustomMapData.fromJson(Map<String, dynamic> json) => CustomMapData(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'My Custom Map',
        theme: json['theme'] as String? ?? 'forest',
        worldWidth: (json['worldWidth'] as num?)?.toDouble() ?? 4800.0,
        worldHeight: (json['worldHeight'] as num?)?.toDouble() ?? 800.0,
        playerStartX: (json['playerStartX'] as num?)?.toDouble() ?? 100.0,
        playerStartY: (json['playerStartY'] as num?)?.toDouble() ?? 620.0,
        finishX: (json['finishX'] as num?)?.toDouble() ?? 4500.0,
        finishY: (json['finishY'] as num?)?.toDouble() ?? 590.0,
        isTemplate: json['isTemplate'] as bool? ?? false,
        createdDate: json['createdDate'] != null
            ? DateTime.tryParse(json['createdDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedDate: json['updatedDate'] != null
            ? DateTime.tryParse(json['updatedDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        bestTimeSeconds: (json['bestTimeSeconds'] as num?)?.toDouble(),
        highestCoinsCollected: json['highestCoinsCollected'] as int? ?? 0,
        totalAttempts: json['totalAttempts'] as int? ?? 0,
        isCompleted: json['isCompleted'] as bool? ?? false,
        entities: (json['entities'] as List<dynamic>?)
                ?.map((e) => CustomMapEntity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  static String serializeList(List<CustomMapData> maps) {
    return jsonEncode(maps.map((m) => m.toJson()).toList());
  }

  static List<CustomMapData> deserializeList(String jsonStr) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => CustomMapData.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // 8 FEATURED TEMPLATE MAPS
  static List<CustomMapData> get builtInTemplates => [
        _createForestStarterTemplate(),
        _createDarkForestTemplate(),
        _createCrystalValleyTemplate(),
        _createLavaEscapeTemplate(),
        _createIcePathTemplate(),
        _createSkyRuinsTemplate(),
        _createShadowTempleTemplate(),
        _createZombieVillageTemplate(),
      ];

  static CustomMapData _createForestStarterTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_forest_starter',
      name: 'Forest Starter',
      theme: 'forest',
      worldWidth: 4800,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 4500,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'g1', type: 'platform', x: 0, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'g2', type: 'platform', x: 1350, y: groundY, width: 1400, height: 120),
        CustomMapEntity(id: 'g3', type: 'platform', x: 2900, y: groundY, width: 1900, height: 120),
        CustomMapEntity(id: 'p1', type: 'platform', x: 300, y: 550, width: 180, height: 28),
        CustomMapEntity(id: 'p2', type: 'platform', x: 550, y: 460, width: 200, height: 28),
        CustomMapEntity(id: 'p3', type: 'movingPlatform', x: 1220, y: 560, width: 130, height: 24, patrolRange: 120),
        CustomMapEntity(id: 'p4', type: 'platform', x: 1600, y: 520, width: 200, height: 28),
        CustomMapEntity(id: 'e1', type: 'enemySlime', x: 450, y: groundY - 32, width: 36, height: 32, patrolRange: 120),
        CustomMapEntity(id: 'e2', type: 'enemyShadow', x: 1750, y: groundY - 44, width: 40, height: 44, patrolRange: 100),
        CustomMapEntity(id: 'c1', type: 'coin', x: 320, y: 500, width: 22, height: 22),
        CustomMapEntity(id: 'c2', type: 'coin', x: 360, y: 500, width: 22, height: 22),
        CustomMapEntity(id: 'c3', type: 'coin', x: 400, y: 500, width: 22, height: 22),
        CustomMapEntity(id: 'h1', type: 'hazardSpike', x: 700, y: groundY - 20, width: 80, height: 20),
        CustomMapEntity(id: 'hp1', type: 'healthPot', x: 1800, y: 470, width: 24, height: 28),
        CustomMapEntity(id: 'd1', type: 'decorTree', x: 200, y: groundY - 120, width: 80, height: 120),
        CustomMapEntity(id: 'd2', type: 'decorRock', x: 600, y: groundY - 30, width: 50, height: 30),
      ],
    );
  }

  static CustomMapData _createDarkForestTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_dark_forest',
      name: 'Dark Forest',
      theme: 'poison',
      worldWidth: 5200,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 4900,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'g1', type: 'platform', x: 0, y: groundY, width: 1000, height: 120),
        CustomMapEntity(id: 'g2', type: 'platform', x: 1200, y: groundY, width: 1000, height: 120),
        CustomMapEntity(id: 'g3', type: 'platform', x: 2400, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'g4', type: 'platform', x: 3800, y: groundY, width: 1400, height: 120),
        CustomMapEntity(id: 'poison1', type: 'hazardPoison', x: 1000, y: 720, width: 200, height: 80),
        CustomMapEntity(id: 'poison2', type: 'hazardPoison', x: 2200, y: 720, width: 200, height: 80),
        CustomMapEntity(id: 'e1', type: 'enemyToxic', x: 500, y: groundY - 40, width: 40, height: 40, patrolRange: 140, health: 2),
        CustomMapEntity(id: 'e2', type: 'enemyToxic', x: 1500, y: groundY - 40, width: 40, height: 40, patrolRange: 150, health: 2),
        CustomMapEntity(id: 'c1', type: 'coin', x: 1300, y: 550, width: 22, height: 22),
        CustomMapEntity(id: 'c2', type: 'coin', x: 1350, y: 550, width: 22, height: 22),
        CustomMapEntity(id: 'cp1', type: 'checkpoint', x: 2500, y: groundY - 60, width: 44, height: 60),
      ],
    );
  }

  static CustomMapData _createCrystalValleyTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_crystal_valley',
      name: 'Crystal Valley',
      theme: 'crystal',
      worldWidth: 5400,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 5100,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'g1', type: 'platform', x: 0, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'p1', type: 'platform', x: 1300, y: 540, width: 180, height: 28),
        CustomMapEntity(id: 'p2', type: 'platform', x: 1550, y: 440, width: 180, height: 28),
        CustomMapEntity(id: 'g2', type: 'platform', x: 1800, y: groundY, width: 1500, height: 120),
        CustomMapEntity(id: 'g3', type: 'platform', x: 3500, y: groundY, width: 1900, height: 120),
        CustomMapEntity(id: 'c1', type: 'coin', x: 1320, y: 490, width: 22, height: 22),
        CustomMapEntity(id: 'c2', type: 'coin', x: 1570, y: 390, width: 22, height: 22),
        CustomMapEntity(id: 'd1', type: 'decorCrystal', x: 400, y: groundY - 40, width: 30, height: 40),
        CustomMapEntity(id: 'd2', type: 'decorCrystal', x: 2000, y: groundY - 40, width: 30, height: 40),
      ],
    );
  }

  static CustomMapData _createLavaEscapeTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_lava_escape',
      name: 'Lava Escape',
      theme: 'fire',
      worldWidth: 5600,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 5300,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'g1', type: 'platform', x: 0, y: groundY, width: 800, height: 120),
        CustomMapEntity(id: 'lava1', type: 'hazardLava', x: 800, y: 720, width: 600, height: 80),
        CustomMapEntity(id: 'm1', type: 'movingPlatform', x: 900, y: 550, width: 140, height: 28, patrolRange: 160, vx: 1.8),
        CustomMapEntity(id: 'm2', type: 'movingPlatform', x: 1200, y: 480, width: 140, height: 28, patrolRange: 160, vx: 2.0),
        CustomMapEntity(id: 'g2', type: 'platform', x: 1400, y: groundY, width: 1000, height: 120),
        CustomMapEntity(id: 'g3', type: 'platform', x: 2600, y: groundY, width: 3000, height: 120),
        CustomMapEntity(id: 'e1', type: 'enemyFire', x: 1600, y: groundY - 40, width: 40, height: 40, patrolRange: 140, health: 2),
      ],
    );
  }

  static CustomMapData _createIcePathTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_ice_path',
      name: 'Ice Path',
      theme: 'ice',
      worldWidth: 5000,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 4700,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'ig1', type: 'slipperyPlatform', x: 0, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'ig2', type: 'slipperyPlatform', x: 1400, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'ig3', type: 'slipperyPlatform', x: 2800, y: groundY, width: 2200, height: 120),
        CustomMapEntity(id: 'e1', type: 'enemyIce', x: 600, y: groundY - 40, width: 40, height: 40, patrolRange: 140),
        CustomMapEntity(id: 'e2', type: 'enemyIce', x: 1800, y: groundY - 40, width: 40, height: 40, patrolRange: 140),
      ],
    );
  }

  static CustomMapData _createSkyRuinsTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_sky_ruins',
      name: 'Sky Ruins',
      theme: 'sky',
      worldWidth: 5200,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 4900,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'sg1', type: 'platform', x: 0, y: groundY, width: 800, height: 120),
        CustomMapEntity(id: 'sp1', type: 'platform', x: 900, y: 550, width: 160, height: 28),
        CustomMapEntity(id: 'sp2', type: 'platform', x: 1150, y: 460, width: 180, height: 28),
        CustomMapEntity(id: 'sp3', type: 'movingPlatform', x: 1420, y: 420, width: 140, height: 28, patrolRange: 180, vx: 2.2),
        CustomMapEntity(id: 'sg2', type: 'platform', x: 1800, y: groundY, width: 3400, height: 120),
        CustomMapEntity(id: 'd1', type: 'decorRuin', x: 2000, y: groundY - 80, width: 60, height: 80),
      ],
    );
  }

  static CustomMapData _createShadowTempleTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_shadow_temple',
      name: 'Shadow Temple',
      theme: 'shadow',
      worldWidth: 5400,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 5100,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'g1', type: 'platform', x: 0, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'g2', type: 'platform', x: 1400, y: groundY, width: 1400, height: 120),
        CustomMapEntity(id: 'g3', type: 'platform', x: 3000, y: groundY, width: 2400, height: 120),
        CustomMapEntity(id: 'e1', type: 'enemyShadow', x: 500, y: groundY - 44, width: 40, height: 44, patrolRange: 140, health: 3),
        CustomMapEntity(id: 'e2', type: 'enemyShadow', x: 1700, y: groundY - 44, width: 40, height: 44, patrolRange: 140, health: 3),
        CustomMapEntity(id: 'h1', type: 'hazardSpike', x: 1200, y: groundY - 20, width: 100, height: 20),
      ],
    );
  }

  static CustomMapData _createZombieVillageTemplate() {
    const double groundY = 680.0;
    return CustomMapData(
      id: 'tpl_zombie_village',
      name: 'Zombie Village',
      theme: 'thunder',
      worldWidth: 5500,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 5200,
      finishY: groundY - 90,
      isTemplate: true,
      entities: [
        CustomMapEntity(id: 'g1', type: 'platform', x: 0, y: groundY, width: 1200, height: 120),
        CustomMapEntity(id: 'g2', type: 'platform', x: 1350, y: groundY, width: 1400, height: 120),
        CustomMapEntity(id: 'g3', type: 'platform', x: 2900, y: groundY, width: 2600, height: 120),
        CustomMapEntity(id: 'e1', type: 'enemyShadow', x: 600, y: groundY - 44, width: 40, height: 44, patrolRange: 120, health: 2),
        CustomMapEntity(id: 'e2', type: 'enemyToxic', x: 1500, y: groundY - 40, width: 40, height: 40, patrolRange: 140, health: 2),
        CustomMapEntity(id: 'h1', type: 'hazardLightning', x: 1200, y: groundY - 24, width: 100, height: 24),
        CustomMapEntity(id: 'd1', type: 'decorRuin', x: 400, y: groundY - 70, width: 60, height: 70),
        CustomMapEntity(id: 'd2', type: 'decorSign', x: 1000, y: groundY - 36, width: 30, height: 36),
      ],
    );
  }
}
