import 'package:enchanted_forest_adventure/models/game_entity.dart';

enum LevelTheme {
  forest,
  fire,
  water,
  ice,
  desert,
  thunder,
  poison,
  sky,
  shadow,
  crystal,
}

class LevelData {
  final int levelNumber;
  final String levelName;
  final LevelTheme theme;
  final double worldWidth;
  final double worldHeight;
  final double playerStartX;
  final double playerStartY;
  final List<GameEntity> platforms;
  final List<GameEntity> enemies;
  final List<GameEntity> collectibles;
  final List<GameEntity> hazards;
  final List<GameEntity> checkpoints;
  final GameEntity goalPortal;

  LevelData({
    required this.levelNumber,
    required this.levelName,
    required this.theme,
    required this.worldWidth,
    required this.worldHeight,
    required this.playerStartX,
    required this.playerStartY,
    required this.platforms,
    required this.enemies,
    required this.collectibles,
    required this.hazards,
    required this.checkpoints,
    required this.goalPortal,
  });

  static LevelData createLevel(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return _createLevel1();
      case 2:
        return _createLevel2();
      case 3:
        return _createLevel3();
      case 4:
        return _createLevel4();
      case 5:
        return _createLevel5();
      case 6:
        return _createLevel6();
      case 7:
        return _createLevel7();
      case 8:
        return _createLevel8();
      case 9:
        return _createLevel9();
      case 10:
        return _createLevel10();
      default:
        return _createLevel1();
    }
  }

  // 🌲 LEVEL 1 — FOREST (EXPANDED TO 9600px)
  static LevelData _createLevel1() {
    const double levelWidth = 9600.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      // Ground Sections
      GameEntity(id: 'g1', type: EntityType.platform, x: 0, y: groundY, width: 1200, height: 120),
      GameEntity(id: 'g2', type: EntityType.platform, x: 1350, y: groundY, width: 1100, height: 120),
      GameEntity(id: 'g3', type: EntityType.platform, x: 2600, y: groundY, width: 1400, height: 120),
      GameEntity(id: 'g4', type: EntityType.platform, x: 4150, y: groundY, width: 1300, height: 120),
      GameEntity(id: 'g5', type: EntityType.platform, x: 5600, y: groundY, width: 1200, height: 120),
      GameEntity(id: 'g6', type: EntityType.platform, x: 6950, y: groundY, width: 1100, height: 120),
      GameEntity(id: 'g7', type: EntityType.platform, x: 8200, y: groundY, width: 1400, height: 120),

      // Raised Canopy Platforms
      GameEntity(id: 'p1', type: EntityType.platform, x: 300, y: 550, width: 160, height: 28),
      GameEntity(id: 'p2', type: EntityType.platform, x: 550, y: 460, width: 180, height: 28),
      GameEntity(id: 'p3', type: EntityType.platform, x: 800, y: 530, width: 140, height: 28),
      GameEntity(id: 'p_bridge1', type: EntityType.platform, x: 1220, y: 560, width: 120, height: 24),
      GameEntity(id: 'p4', type: EntityType.platform, x: 1500, y: 520, width: 180, height: 28),
      GameEntity(id: 'p5', type: EntityType.platform, x: 1780, y: 420, width: 200, height: 28),
      GameEntity(id: 'p6', type: EntityType.platform, x: 2080, y: 520, width: 160, height: 28),
      GameEntity(id: 'p_bridge2', type: EntityType.platform, x: 2480, y: 540, width: 110, height: 24),
      GameEntity(id: 'p7', type: EntityType.platform, x: 2800, y: 520, width: 170, height: 28),
      GameEntity(id: 'p8', type: EntityType.platform, x: 3100, y: 430, width: 220, height: 28),
      GameEntity(id: 'p9', type: EntityType.platform, x: 3450, y: 520, width: 180, height: 28),

      // Extension Section Platforms (3600 -> 9600)
      GameEntity(id: 'p10', type: EntityType.platform, x: 4020, y: 540, width: 120, height: 24),
      GameEntity(id: 'p11', type: EntityType.platform, x: 4350, y: 500, width: 180, height: 28),
      GameEntity(id: 'p12', type: EntityType.platform, x: 4650, y: 410, width: 200, height: 28),
      GameEntity(id: 'p13', type: EntityType.platform, x: 4980, y: 510, width: 160, height: 28),
      GameEntity(id: 'p14', type: EntityType.platform, x: 5480, y: 540, width: 110, height: 24),
      GameEntity(id: 'p15', type: EntityType.platform, x: 5800, y: 500, width: 180, height: 28),
      GameEntity(id: 'p16', type: EntityType.platform, x: 6100, y: 420, width: 220, height: 28),
      GameEntity(id: 'p17', type: EntityType.platform, x: 6450, y: 510, width: 180, height: 28),
      GameEntity(id: 'p18', type: EntityType.platform, x: 6830, y: 550, width: 110, height: 24),
      GameEntity(id: 'p19', type: EntityType.platform, x: 7150, y: 490, width: 180, height: 28),
      GameEntity(id: 'p20', type: EntityType.platform, x: 7450, y: 400, width: 200, height: 28),
      GameEntity(id: 'p21', type: EntityType.platform, x: 7800, y: 500, width: 180, height: 28),
      GameEntity(id: 'p22', type: EntityType.platform, x: 8080, y: 540, width: 110, height: 24),
      GameEntity(id: 'p23', type: EntityType.platform, x: 8400, y: 480, width: 220, height: 28),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'e1', type: EntityType.enemySlime, x: 450, y: groundY - 32, width: 36, height: 32, patrolRange: 120, vx: 1.0, health: 1),
      GameEntity(id: 'e2', type: EntityType.enemyShadow, x: 750, y: groundY - 44, width: 40, height: 44, patrolRange: 100, vx: 1.5, health: 2),
      GameEntity(id: 'e3', type: EntityType.enemySlime, x: 1550, y: groundY - 32, width: 36, height: 32, patrolRange: 140, vx: 1.2, health: 1),
      GameEntity(id: 'e4', type: EntityType.enemyShadow, x: 1780, y: 420 - 44, width: 40, height: 44, patrolRange: 70, vx: 1.4, health: 2),
      GameEntity(id: 'e5', type: EntityType.enemySlime, x: 2800, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.3, health: 1),
      GameEntity(id: 'e6', type: EntityType.enemyShadow, x: 3100, y: 430 - 44, width: 40, height: 44, patrolRange: 80, vx: 1.6, health: 2),
      GameEntity(id: 'e7', type: EntityType.enemySlime, x: 4400, y: groundY - 32, width: 36, height: 32, patrolRange: 140, vx: 1.2, health: 1),
      GameEntity(id: 'e8', type: EntityType.enemyShadow, x: 4650, y: 410 - 44, width: 40, height: 44, patrolRange: 80, vx: 1.5, health: 2),
      GameEntity(id: 'e9', type: EntityType.enemySlime, x: 5900, y: groundY - 32, width: 36, height: 32, patrolRange: 160, vx: 1.4, health: 1),
      GameEntity(id: 'e10', type: EntityType.enemyShadow, x: 6100, y: 420 - 44, width: 40, height: 44, patrolRange: 90, vx: 1.7, health: 2),
      GameEntity(id: 'e11', type: EntityType.enemySlime, x: 7200, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.3, health: 1),
      GameEntity(id: 'e12', type: EntityType.enemyShadow, x: 7450, y: 400 - 44, width: 40, height: 44, patrolRange: 80, vx: 1.6, health: 2),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'h1', type: EntityType.hazardSpike, x: 620, y: groundY - 20, width: 60, height: 20),
      GameEntity(id: 'h2', type: EntityType.hazardSpike, x: 1950, y: groundY - 20, width: 80, height: 20),
      GameEntity(id: 'h3', type: EntityType.hazardSpike, x: 3000, y: groundY - 20, width: 80, height: 20),
      GameEntity(id: 'h4', type: EntityType.hazardSpike, x: 4800, y: groundY - 20, width: 90, height: 20),
      GameEntity(id: 'h5', type: EntityType.hazardSpike, x: 6300, y: groundY - 20, width: 90, height: 20),
      GameEntity(id: 'h6', type: EntityType.hazardSpike, x: 7600, y: groundY - 20, width: 100, height: 20),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'c1_$i', type: EntityType.coin, x: 320 + i * 30, y: 500, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'c2_$i', type: EntityType.coin, x: 1790 + i * 30, y: 370, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'c3_$i', type: EntityType.coin, x: 4660 + i * 30, y: 360, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'c4_$i', type: EntityType.coin, x: 7460 + i * 30, y: 350, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'hp1', type: EntityType.healthPot, x: 850, y: 480, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'hp2', type: EntityType.healthPot, x: 4680, y: 360, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'hp3', type: EntityType.healthPot, x: 7480, y: 350, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'cp1', type: EntityType.checkpoint, x: 2700, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'cp2', type: EntityType.checkpoint, x: 5700, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'cp3', type: EntityType.checkpoint, x: 8300, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 1,
      levelName: 'Forest',
      theme: LevelTheme.forest,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 9420, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 🔥 LEVEL 2 — FIRE (EXPANDED TO 10000px)
  static LevelData _createLevel2() {
    const double levelWidth = 10000.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'fg1', type: EntityType.platform, x: 0, y: groundY, width: 800, height: 120),
      GameEntity(id: 'm1', type: EntityType.movingPlatform, x: 900, y: 550, width: 140, height: 28, patrolRange: 160, vx: 1.5),
      GameEntity(id: 'fg2', type: EntityType.platform, x: 1300, y: groundY, width: 700, height: 120),
      GameEntity(id: 'm2', type: EntityType.movingPlatform, x: 2100, y: 520, width: 130, height: 28, patrolRange: 0, moveRangeY: 120, vy: 1.4),
      GameEntity(id: 'fg3', type: EntityType.platform, x: 2400, y: groundY, width: 800, height: 120),
      GameEntity(id: 'm3', type: EntityType.movingPlatform, x: 3300, y: 540, width: 140, height: 28, patrolRange: 180, vx: 1.8),
      GameEntity(id: 'fg4', type: EntityType.platform, x: 3650, y: groundY, width: 800, height: 120),

      // Extension Section Platforms (3800 -> 10000)
      GameEntity(id: 'm4', type: EntityType.movingPlatform, x: 4550, y: 530, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'fg5', type: EntityType.platform, x: 4900, y: groundY, width: 800, height: 120),
      GameEntity(id: 'm5', type: EntityType.movingPlatform, x: 5800, y: 510, width: 140, height: 28, patrolRange: 0, moveRangeY: 130, vy: 1.6),
      GameEntity(id: 'fg6', type: EntityType.platform, x: 6150, y: groundY, width: 800, height: 120),
      GameEntity(id: 'm6', type: EntityType.movingPlatform, x: 7050, y: 540, width: 140, height: 28, patrolRange: 200, vx: 2.2),
      GameEntity(id: 'fg7', type: EntityType.platform, x: 7450, y: groundY, width: 800, height: 120),
      GameEntity(id: 'm7', type: EntityType.movingPlatform, x: 8350, y: 520, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'fg8', type: EntityType.platform, x: 8700, y: groundY, width: 1300, height: 120),

      // Raised obsidian platforms
      GameEntity(id: 'fp1', type: EntityType.platform, x: 350, y: 500, width: 160, height: 28),
      GameEntity(id: 'fp2', type: EntityType.platform, x: 1500, y: 480, width: 180, height: 28),
      GameEntity(id: 'fp3', type: EntityType.platform, x: 2600, y: 450, width: 200, height: 28),
      GameEntity(id: 'fp4', type: EntityType.platform, x: 5100, y: 480, width: 180, height: 28),
      GameEntity(id: 'fp5', type: EntityType.platform, x: 6350, y: 460, width: 200, height: 28),
      GameEntity(id: 'fp6', type: EntityType.platform, x: 7650, y: 470, width: 180, height: 28),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'lava1', type: EntityType.hazardLava, x: 800, y: 720, width: 500, height: 80),
      GameEntity(id: 'lava2', type: EntityType.hazardLava, x: 2000, y: 720, width: 400, height: 80),
      GameEntity(id: 'lava3', type: EntityType.hazardLava, x: 3200, y: 720, width: 450, height: 80),
      GameEntity(id: 'lava4', type: EntityType.hazardLava, x: 4450, y: 720, width: 450, height: 80),
      GameEntity(id: 'lava5', type: EntityType.hazardLava, x: 5700, y: 720, width: 450, height: 80),
      GameEntity(id: 'lava6', type: EntityType.hazardLava, x: 6950, y: 720, width: 500, height: 80),
      GameEntity(id: 'lava7', type: EntityType.hazardLava, x: 8250, y: 720, width: 450, height: 80),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'fe1', type: EntityType.enemyFire, x: 400, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 1.6, health: 2),
      GameEntity(id: 'fe2', type: EntityType.enemyFire, x: 1550, y: 480 - 40, width: 40, height: 40, patrolRange: 60, vx: 1.8, health: 2),
      GameEntity(id: 'fe3', type: EntityType.enemyFire, x: 2700, y: groundY - 40, width: 40, height: 40, patrolRange: 140, vx: 2.0, health: 2),
      GameEntity(id: 'fe4', type: EntityType.enemyFire, x: 5150, y: 480 - 40, width: 40, height: 40, patrolRange: 70, vx: 2.0, health: 2),
      GameEntity(id: 'fe5', type: EntityType.enemyFire, x: 6400, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.2, health: 2),
      GameEntity(id: 'fe6', type: EntityType.enemyFire, x: 7700, y: 470 - 40, width: 40, height: 40, patrolRange: 80, vx: 2.2, health: 2),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'fc_$i', type: EntityType.coin, x: 1520 + i * 30, y: 430, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'fc2_$i', type: EntityType.coin, x: 5120 + i * 30, y: 430, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'fhp1', type: EntityType.healthPot, x: 2600, y: 400, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'fhp2', type: EntityType.healthPot, x: 6350, y: 410, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'fcp1', type: EntityType.checkpoint, x: 2500, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'fcp2', type: EntityType.checkpoint, x: 6250, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 2,
      levelName: 'Fire',
      theme: LevelTheme.fire,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 9800, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 🌊 LEVEL 3 — WATER (EXPANDED TO 10000px)
  static LevelData _createLevel3() {
    const double levelWidth = 10000.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'wg1', type: EntityType.platform, x: 0, y: groundY, width: 900, height: 120),
      GameEntity(id: 'wp1', type: EntityType.platform, x: 1000, y: 560, width: 140, height: 26),
      GameEntity(id: 'wp2', type: EntityType.platform, x: 1220, y: 480, width: 150, height: 26),
      GameEntity(id: 'wp3', type: EntityType.platform, x: 1450, y: 550, width: 140, height: 26),
      GameEntity(id: 'wg2', type: EntityType.platform, x: 1680, y: groundY, width: 800, height: 120),
      GameEntity(id: 'wm1', type: EntityType.movingPlatform, x: 2550, y: 530, width: 130, height: 26, patrolRange: 160, vx: 1.6),
      GameEntity(id: 'wg3', type: EntityType.platform, x: 2900, y: groundY, width: 900, height: 120),

      // Extension Section Platforms (3800 -> 10000)
      GameEntity(id: 'wp4', type: EntityType.platform, x: 3900, y: 560, width: 140, height: 26),
      GameEntity(id: 'wp5', type: EntityType.platform, x: 4120, y: 480, width: 150, height: 26),
      GameEntity(id: 'wp6', type: EntityType.platform, x: 4350, y: 550, width: 140, height: 26),
      GameEntity(id: 'wg4', type: EntityType.platform, x: 4580, y: groundY, width: 800, height: 120),
      GameEntity(id: 'wm2', type: EntityType.movingPlatform, x: 5450, y: 530, width: 130, height: 26, patrolRange: 180, vx: 1.8),
      GameEntity(id: 'wg5', type: EntityType.platform, x: 5800, y: groundY, width: 900, height: 120),
      GameEntity(id: 'wp7', type: EntityType.platform, x: 6800, y: 550, width: 140, height: 26),
      GameEntity(id: 'wp8', type: EntityType.platform, x: 7020, y: 470, width: 160, height: 26),
      GameEntity(id: 'wp9', type: EntityType.platform, x: 7250, y: 550, width: 140, height: 26),
      GameEntity(id: 'wg6', type: EntityType.platform, x: 7480, y: groundY, width: 2520, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'wh1', type: EntityType.hazardSpike, x: 1900, y: groundY - 20, width: 90, height: 20),
      GameEntity(id: 'wh2', type: EntityType.hazardSpike, x: 4800, y: groundY - 20, width: 90, height: 20),
      GameEntity(id: 'wh3', type: EntityType.hazardSpike, x: 6000, y: groundY - 20, width: 100, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'we1', type: EntityType.enemySlime, x: 500, y: groundY - 32, width: 36, height: 32, patrolRange: 100, vx: 1.2),
      GameEntity(id: 'we2', type: EntityType.enemyShadow, x: 1950, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 1.5),
      GameEntity(id: 'we3', type: EntityType.enemySlime, x: 3100, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.4),
      GameEntity(id: 'we4', type: EntityType.enemyShadow, x: 4850, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 1.6),
      GameEntity(id: 'we5', type: EntityType.enemySlime, x: 6100, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.5),
      GameEntity(id: 'we6', type: EntityType.enemyShadow, x: 7700, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 1.7),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 5; i++) {
      collectibles.add(GameEntity(id: 'wc_$i', type: EntityType.coin, x: 1020 + i * 100, y: 420, width: 22, height: 22));
    }
    for (int i = 0; i < 5; i++) {
      collectibles.add(GameEntity(id: 'wc2_$i', type: EntityType.coin, x: 3920 + i * 100, y: 420, width: 22, height: 22));
    }

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'wcp1', type: EntityType.checkpoint, x: 1750, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'wcp2', type: EntityType.checkpoint, x: 5900, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 3,
      levelName: 'Water',
      theme: LevelTheme.water,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 9800, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ❄️ LEVEL 4 — ICE (EXPANDED TO 10500px)
  static LevelData _createLevel4() {
    const double levelWidth = 10500.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'ig1', type: EntityType.slipperyPlatform, x: 0, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'ip1', type: EntityType.slipperyPlatform, x: 1100, y: 540, width: 160, height: 28),
      GameEntity(id: 'ip2', type: EntityType.slipperyPlatform, x: 1350, y: 450, width: 170, height: 28),
      GameEntity(id: 'ig2', type: EntityType.slipperyPlatform, x: 1600, y: groundY, width: 900, height: 120),
      GameEntity(id: 'im1', type: EntityType.movingPlatform, x: 2600, y: 520, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'ig3', type: EntityType.slipperyPlatform, x: 3000, y: groundY, width: 1000, height: 120),

      // Extension Section Platforms (4000 -> 10500)
      GameEntity(id: 'ip3', type: EntityType.slipperyPlatform, x: 4100, y: 540, width: 160, height: 28),
      GameEntity(id: 'ip4', type: EntityType.slipperyPlatform, x: 4350, y: 450, width: 170, height: 28),
      GameEntity(id: 'ig4', type: EntityType.slipperyPlatform, x: 4600, y: groundY, width: 900, height: 120),
      GameEntity(id: 'im2', type: EntityType.movingPlatform, x: 5600, y: 520, width: 140, height: 28, patrolRange: 180, vx: 2.2),
      GameEntity(id: 'ig5', type: EntityType.slipperyPlatform, x: 6000, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'ip5', type: EntityType.slipperyPlatform, x: 7100, y: 530, width: 170, height: 28),
      GameEntity(id: 'ip6', type: EntityType.slipperyPlatform, x: 7350, y: 440, width: 180, height: 28),
      GameEntity(id: 'ig6', type: EntityType.slipperyPlatform, x: 7600, y: groundY, width: 2900, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'ih1', type: EntityType.hazardSpike, x: 1850, y: groundY - 20, width: 100, height: 20),
      GameEntity(id: 'ih2', type: EntityType.hazardSpike, x: 4850, y: groundY - 20, width: 100, height: 20),
      GameEntity(id: 'ih3', type: EntityType.hazardSpike, x: 6250, y: groundY - 20, width: 120, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'ie1', type: EntityType.enemyIce, x: 600, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 1.8),
      GameEntity(id: 'ie2', type: EntityType.enemyIce, x: 1900, y: groundY - 40, width: 40, height: 40, patrolRange: 130, vx: 2.0),
      GameEntity(id: 'ie3', type: EntityType.enemyIce, x: 3300, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.2),
      GameEntity(id: 'ie4', type: EntityType.enemyIce, x: 4900, y: groundY - 40, width: 40, height: 40, patrolRange: 130, vx: 2.1),
      GameEntity(id: 'ie5', type: EntityType.enemyIce, x: 6300, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.3),
      GameEntity(id: 'ie6', type: EntityType.enemyIce, x: 7900, y: groundY - 40, width: 40, height: 40, patrolRange: 160, vx: 2.4),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 7; i++) {
      collectibles.add(GameEntity(id: 'ic_$i', type: EntityType.coin, x: 1150 + i * 40, y: 390, width: 22, height: 22));
    }
    for (int i = 0; i < 7; i++) {
      collectibles.add(GameEntity(id: 'ic2_$i', type: EntityType.coin, x: 4150 + i * 40, y: 390, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'ihp1', type: EntityType.healthPot, x: 1380, y: 400, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'ihp2', type: EntityType.healthPot, x: 4380, y: 400, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'icp1', type: EntityType.checkpoint, x: 1700, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'icp2', type: EntityType.checkpoint, x: 6100, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 4,
      levelName: 'Ice',
      theme: LevelTheme.ice,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 10300, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 🏜️ LEVEL 5 — DESERT (EXPANDED TO 10500px)
  static LevelData _createLevel5() {
    const double levelWidth = 10500.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'dg1', type: EntityType.platform, x: 0, y: groundY, width: 950, height: 120),
      GameEntity(id: 'dp1', type: EntityType.platform, x: 1050, y: 520, width: 160, height: 28),
      GameEntity(id: 'dp2', type: EntityType.platform, x: 1300, y: 420, width: 180, height: 28),
      GameEntity(id: 'dg2', type: EntityType.platform, x: 1550, y: groundY, width: 900, height: 120),
      GameEntity(id: 'dm1', type: EntityType.movingPlatform, x: 2550, y: 500, width: 140, height: 28, patrolRange: 200, vx: 1.8),
      GameEntity(id: 'dg3', type: EntityType.platform, x: 2950, y: groundY, width: 1000, height: 120),

      // Extension Section Platforms (4000 -> 10500)
      GameEntity(id: 'dp3', type: EntityType.platform, x: 4050, y: 520, width: 160, height: 28),
      GameEntity(id: 'dp4', type: EntityType.platform, x: 4300, y: 420, width: 180, height: 28),
      GameEntity(id: 'dg4', type: EntityType.platform, x: 4550, y: groundY, width: 900, height: 120),
      GameEntity(id: 'dm2', type: EntityType.movingPlatform, x: 5550, y: 500, width: 140, height: 28, patrolRange: 200, vx: 2.0),
      GameEntity(id: 'dg5', type: EntityType.platform, x: 5950, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'dp5', type: EntityType.platform, x: 7050, y: 510, width: 170, height: 28),
      GameEntity(id: 'dp6', type: EntityType.platform, x: 7300, y: 410, width: 190, height: 28),
      GameEntity(id: 'dg6', type: EntityType.platform, x: 7550, y: groundY, width: 2950, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'dh1', type: EntityType.hazardSpike, x: 1800, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'dh2', type: EntityType.hazardSpike, x: 4800, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'dh3', type: EntityType.hazardSpike, x: 6200, y: groundY - 20, width: 130, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'de1', type: EntityType.enemySlime, x: 450, y: groundY - 32, width: 36, height: 32, patrolRange: 120, vx: 1.4),
      GameEntity(id: 'de2', type: EntityType.enemyShadow, x: 1350, y: 420 - 44, width: 40, height: 44, patrolRange: 70, vx: 1.6),
      GameEntity(id: 'de3', type: EntityType.enemyShadow, x: 2000, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 1.8),
      GameEntity(id: 'de4', type: EntityType.enemyShadow, x: 4350, y: 420 - 44, width: 40, height: 44, patrolRange: 70, vx: 1.7),
      GameEntity(id: 'de5', type: EntityType.enemyShadow, x: 5000, y: groundY - 44, width: 40, height: 44, patrolRange: 130, vx: 1.9),
      GameEntity(id: 'de6', type: EntityType.enemyShadow, x: 7800, y: groundY - 44, width: 40, height: 44, patrolRange: 150, vx: 2.1),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'dc_$i', type: EntityType.coin, x: 1320 + i * 30, y: 370, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'dc2_$i', type: EntityType.coin, x: 4320 + i * 30, y: 370, width: 22, height: 22));
    }

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'dcp1', type: EntityType.checkpoint, x: 1620, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'dcp2', type: EntityType.checkpoint, x: 6020, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 5,
      levelName: 'Desert',
      theme: LevelTheme.desert,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 10300, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ⚡ LEVEL 6 — THUNDER (EXPANDED TO 11000px)
  static LevelData _createLevel6() {
    const double levelWidth = 11000.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'tg1', type: EntityType.platform, x: 0, y: groundY, width: 900, height: 120),
      GameEntity(id: 'tm1', type: EntityType.movingPlatform, x: 1000, y: 520, width: 140, height: 28, patrolRange: 160, vx: 2.0),
      GameEntity(id: 'tg2', type: EntityType.platform, x: 1350, y: groundY, width: 900, height: 120),
      GameEntity(id: 'tm2', type: EntityType.movingPlatform, x: 2350, y: 480, width: 140, height: 28, patrolRange: 0, moveRangeY: 140, vy: 1.8),
      GameEntity(id: 'tg3', type: EntityType.platform, x: 2700, y: groundY, width: 1000, height: 120),

      // Extension Section Platforms (4200 -> 11000)
      GameEntity(id: 'tm3', type: EntityType.movingPlatform, x: 3800, y: 520, width: 140, height: 28, patrolRange: 180, vx: 2.2),
      GameEntity(id: 'tg4', type: EntityType.platform, x: 4150, y: groundY, width: 900, height: 120),
      GameEntity(id: 'tm4', type: EntityType.movingPlatform, x: 5150, y: 480, width: 140, height: 28, patrolRange: 0, moveRangeY: 140, vy: 2.0),
      GameEntity(id: 'tg5', type: EntityType.platform, x: 5500, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'tm5', type: EntityType.movingPlatform, x: 6600, y: 510, width: 140, height: 28, patrolRange: 200, vx: 2.3),
      GameEntity(id: 'tg6', type: EntityType.platform, x: 7000, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'tm6', type: EntityType.movingPlatform, x: 8100, y: 470, width: 140, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.2),
      GameEntity(id: 'tg7', type: EntityType.platform, x: 8450, y: groundY, width: 2550, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'th1', type: EntityType.hazardLightning, x: 1600, y: groundY - 24, width: 100, height: 24),
      GameEntity(id: 'th2', type: EntityType.hazardLightning, x: 3000, y: groundY - 24, width: 120, height: 24),
      GameEntity(id: 'th3', type: EntityType.hazardLightning, x: 4400, y: groundY - 24, width: 110, height: 24),
      GameEntity(id: 'th4', type: EntityType.hazardLightning, x: 5800, y: groundY - 24, width: 120, height: 24),
      GameEntity(id: 'th5', type: EntityType.hazardLightning, x: 7300, y: groundY - 24, width: 130, height: 24),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'te1', type: EntityType.enemyShadow, x: 500, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 2.0),
      GameEntity(id: 'te2', type: EntityType.enemyShadow, x: 1750, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.2),
      GameEntity(id: 'te3', type: EntityType.enemyShadow, x: 3200, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.4),
      GameEntity(id: 'te4', type: EntityType.enemyShadow, x: 4550, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.3),
      GameEntity(id: 'te5', type: EntityType.enemyShadow, x: 5950, y: groundY - 44, width: 40, height: 44, patrolRange: 150, vx: 2.5),
      GameEntity(id: 'te6', type: EntityType.enemyShadow, x: 7450, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.6),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'tc_$i', type: EntityType.coin, x: 1400 + i * 40, y: 450, width: 22, height: 22));
    }
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'tc2_$i', type: EntityType.coin, x: 4200 + i * 40, y: 450, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'thp1', type: EntityType.healthPot, x: 2800, y: 450, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'thp2', type: EntityType.healthPot, x: 5600, y: 450, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'tcp1', type: EntityType.checkpoint, x: 1450, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'tcp2', type: EntityType.checkpoint, x: 5600, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 6,
      levelName: 'Thunder',
      theme: LevelTheme.thunder,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 10800, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ☠️ LEVEL 7 — POISON (EXPANDED TO 11000px)
  static LevelData _createLevel7() {
    const double levelWidth = 11000.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'pg1', type: EntityType.platform, x: 0, y: groundY, width: 800, height: 120),
      GameEntity(id: 'pm1', type: EntityType.movingPlatform, x: 900, y: 530, width: 140, height: 28, patrolRange: 160, vx: 1.8),
      GameEntity(id: 'pg2', type: EntityType.platform, x: 1250, y: groundY, width: 700, height: 120),
      GameEntity(id: 'pp1', type: EntityType.platform, x: 2050, y: 480, width: 160, height: 28),
      GameEntity(id: 'pp2', type: EntityType.platform, x: 2300, y: 400, width: 180, height: 28),
      GameEntity(id: 'pg3', type: EntityType.platform, x: 2600, y: groundY, width: 1000, height: 120),

      // Extension Section Platforms (4200 -> 11000)
      GameEntity(id: 'pm2', type: EntityType.movingPlatform, x: 3700, y: 530, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'pg4', type: EntityType.platform, x: 4050, y: groundY, width: 700, height: 120),
      GameEntity(id: 'pp3', type: EntityType.platform, x: 4850, y: 480, width: 160, height: 28),
      GameEntity(id: 'pp4', type: EntityType.platform, x: 5100, y: 400, width: 180, height: 28),
      GameEntity(id: 'pg5', type: EntityType.platform, x: 5400, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'pm3', type: EntityType.movingPlatform, x: 6500, y: 520, width: 140, height: 28, patrolRange: 200, vx: 2.2),
      GameEntity(id: 'pg6', type: EntityType.platform, x: 6850, y: groundY, width: 700, height: 120),
      GameEntity(id: 'pp5', type: EntityType.platform, x: 7650, y: 470, width: 170, height: 28),
      GameEntity(id: 'pp6', type: EntityType.platform, x: 7900, y: 390, width: 190, height: 28),
      GameEntity(id: 'pg7', type: EntityType.platform, x: 8200, y: groundY, width: 2800, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'poison1', type: EntityType.hazardPoison, x: 800, y: 720, width: 450, height: 80),
      GameEntity(id: 'poison2', type: EntityType.hazardPoison, x: 1950, y: 720, width: 650, height: 80),
      GameEntity(id: 'poison3', type: EntityType.hazardPoison, x: 3600, y: 720, width: 450, height: 80),
      GameEntity(id: 'poison4', type: EntityType.hazardPoison, x: 4750, y: 720, width: 650, height: 80),
      GameEntity(id: 'poison5', type: EntityType.hazardPoison, x: 6400, y: 720, width: 450, height: 80),
      GameEntity(id: 'poison6', type: EntityType.hazardPoison, x: 7550, y: 720, width: 650, height: 80),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'pe1', type: EntityType.enemyToxic, x: 400, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 1.8, health: 2),
      GameEntity(id: 'pe2', type: EntityType.enemyToxic, x: 1400, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 2.0, health: 2),
      GameEntity(id: 'pe3', type: EntityType.enemyToxic, x: 2800, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.2, health: 3),
      GameEntity(id: 'pe4', type: EntityType.enemyToxic, x: 4200, y: groundY - 40, width: 40, height: 40, patrolRange: 130, vx: 2.1, health: 2),
      GameEntity(id: 'pe5', type: EntityType.enemyToxic, x: 5600, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.3, health: 3),
      GameEntity(id: 'pe6', type: EntityType.enemyToxic, x: 8400, y: groundY - 40, width: 40, height: 40, patrolRange: 160, vx: 2.4, health: 3),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 7; i++) {
      collectibles.add(GameEntity(id: 'pc_$i', type: EntityType.coin, x: 2320 + i * 25, y: 350, width: 22, height: 22));
    }
    for (int i = 0; i < 7; i++) {
      collectibles.add(GameEntity(id: 'pc2_$i', type: EntityType.coin, x: 5120 + i * 25, y: 350, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'php1', type: EntityType.healthPot, x: 2400, y: 320, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'php2', type: EntityType.healthPot, x: 5200, y: 320, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'pcp1', type: EntityType.checkpoint, x: 1350, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'pcp2', type: EntityType.checkpoint, x: 5500, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 7,
      levelName: 'Poison',
      theme: LevelTheme.poison,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 10800, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ☁️ LEVEL 8 — SKY (EXPANDED TO 11500px)
  static LevelData _createLevel8() {
    const double levelWidth = 11500.0;
    const double levelHeight = 800.0;
    const double startGroundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'sg1', type: EntityType.platform, x: 0, y: startGroundY, width: 700, height: 120),
      GameEntity(id: 'sp1', type: EntityType.platform, x: 800, y: 550, width: 140, height: 28),
      GameEntity(id: 'sp2', type: EntityType.platform, x: 1020, y: 460, width: 150, height: 28),
      GameEntity(id: 'sm1', type: EntityType.movingPlatform, x: 1250, y: 420, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'sp3', type: EntityType.platform, x: 1600, y: 450, width: 160, height: 28),
      GameEntity(id: 'sp4', type: EntityType.platform, x: 1850, y: 380, width: 180, height: 28),
      GameEntity(id: 'sm2', type: EntityType.movingPlatform, x: 2150, y: 420, width: 140, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.0),
      GameEntity(id: 'sp5', type: EntityType.platform, x: 2450, y: 450, width: 200, height: 28),
      GameEntity(id: 'sm3', type: EntityType.movingPlatform, x: 2800, y: 420, width: 140, height: 28, patrolRange: 200, vx: 2.2),
      GameEntity(id: 'sp6', type: EntityType.platform, x: 3200, y: 480, width: 180, height: 28),
      GameEntity(id: 'sg2', type: EntityType.platform, x: 3500, y: startGroundY, width: 900, height: 120),

      // Extension Section Platforms (4400 -> 11500)
      GameEntity(id: 'sp7', type: EntityType.platform, x: 4500, y: 550, width: 140, height: 28),
      GameEntity(id: 'sp8', type: EntityType.platform, x: 4720, y: 460, width: 150, height: 28),
      GameEntity(id: 'sm4', type: EntityType.movingPlatform, x: 4950, y: 420, width: 140, height: 28, patrolRange: 180, vx: 2.1),
      GameEntity(id: 'sp9', type: EntityType.platform, x: 5300, y: 450, width: 160, height: 28),
      GameEntity(id: 'sp10', type: EntityType.platform, x: 5550, y: 380, width: 180, height: 28),
      GameEntity(id: 'sm5', type: EntityType.movingPlatform, x: 5850, y: 420, width: 140, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.1),
      GameEntity(id: 'sp11', type: EntityType.platform, x: 6150, y: 450, width: 200, height: 28),
      GameEntity(id: 'sm6', type: EntityType.movingPlatform, x: 6500, y: 420, width: 140, height: 28, patrolRange: 200, vx: 2.3),
      GameEntity(id: 'sp12', type: EntityType.platform, x: 6900, y: 480, width: 180, height: 28),
      GameEntity(id: 'sg3', type: EntityType.platform, x: 7200, y: startGroundY, width: 900, height: 120),
      GameEntity(id: 'sp13', type: EntityType.platform, x: 8200, y: 540, width: 150, height: 28),
      GameEntity(id: 'sp14', type: EntityType.platform, x: 8450, y: 450, width: 180, height: 28),
      GameEntity(id: 'sm7', type: EntityType.movingPlatform, x: 8750, y: 410, width: 140, height: 28, patrolRange: 220, vx: 2.4),
      GameEntity(id: 'sp15', type: EntityType.platform, x: 9150, y: 470, width: 190, height: 28),
      GameEntity(id: 'sg4', type: EntityType.platform, x: 9500, y: startGroundY, width: 2000, height: 120),
    ];

    final List<GameEntity> hazards = [];

    final List<GameEntity> enemies = [
      GameEntity(id: 'se1', type: EntityType.enemyShadow, x: 1050, y: 460 - 44, width: 40, height: 44, patrolRange: 50, vx: 1.8),
      GameEntity(id: 'se2', type: EntityType.enemyShadow, x: 1880, y: 380 - 44, width: 40, height: 44, patrolRange: 60, vx: 2.0),
      GameEntity(id: 'se3', type: EntityType.enemyShadow, x: 2480, y: 450 - 44, width: 40, height: 44, patrolRange: 80, vx: 2.2),
      GameEntity(id: 'se4', type: EntityType.enemyShadow, x: 4750, y: 460 - 44, width: 40, height: 44, patrolRange: 50, vx: 1.9),
      GameEntity(id: 'se5', type: EntityType.enemyShadow, x: 5580, y: 380 - 44, width: 40, height: 44, patrolRange: 60, vx: 2.1),
      GameEntity(id: 'se6', type: EntityType.enemyShadow, x: 6180, y: 450 - 44, width: 40, height: 44, patrolRange: 80, vx: 2.3),
      GameEntity(id: 'se7', type: EntityType.enemyShadow, x: 8480, y: 450 - 44, width: 40, height: 44, patrolRange: 80, vx: 2.4),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'sc_$i', type: EntityType.coin, x: 1870 + i * 30, y: 330, width: 22, height: 22));
    }
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'sc2_$i', type: EntityType.coin, x: 5570 + i * 30, y: 330, width: 22, height: 22));
    }

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'scp1', type: EntityType.checkpoint, x: 1650, y: 450 - 60, width: 44, height: 60),
      GameEntity(id: 'scp2', type: EntityType.checkpoint, x: 5350, y: 450 - 60, width: 44, height: 60),
      GameEntity(id: 'scp3', type: EntityType.checkpoint, x: 9200, y: 470 - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 8,
      levelName: 'Sky',
      theme: LevelTheme.sky,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: startGroundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 11300, y: startGroundY - 90, width: 60, height: 90),
    );
  }

  // 🌑 LEVEL 9 — SHADOW (EXPANDED TO 11500px)
  static LevelData _createLevel9() {
    const double levelWidth = 11500.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'shg1', type: EntityType.platform, x: 0, y: groundY, width: 900, height: 120),
      GameEntity(id: 'shp1', type: EntityType.platform, x: 1000, y: 520, width: 150, height: 28),
      GameEntity(id: 'shp2', type: EntityType.platform, x: 1250, y: 420, width: 160, height: 28),
      GameEntity(id: 'shg2', type: EntityType.platform, x: 1500, y: groundY, width: 900, height: 120),
      GameEntity(id: 'shm1', type: EntityType.movingPlatform, x: 2500, y: 500, width: 140, height: 28, patrolRange: 180, vx: 2.2),
      GameEntity(id: 'shg3', type: EntityType.platform, x: 2850, y: groundY, width: 1000, height: 120),

      // Extension Section Platforms (4400 -> 11500)
      GameEntity(id: 'shp3', type: EntityType.platform, x: 3950, y: 520, width: 150, height: 28),
      GameEntity(id: 'shp4', type: EntityType.platform, x: 4200, y: 420, width: 160, height: 28),
      GameEntity(id: 'shg4', type: EntityType.platform, x: 4450, y: groundY, width: 900, height: 120),
      GameEntity(id: 'shm2', type: EntityType.movingPlatform, x: 5450, y: 500, width: 140, height: 28, patrolRange: 180, vx: 2.3),
      GameEntity(id: 'shg5', type: EntityType.platform, x: 5800, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'shp5', type: EntityType.platform, x: 6900, y: 510, width: 160, height: 28),
      GameEntity(id: 'shp6', type: EntityType.platform, x: 7150, y: 410, width: 180, height: 28),
      GameEntity(id: 'shg6', type: EntityType.platform, x: 7450, y: groundY, width: 900, height: 120),
      GameEntity(id: 'shm3', type: EntityType.movingPlatform, x: 8450, y: 490, width: 140, height: 28, patrolRange: 200, vx: 2.5),
      GameEntity(id: 'shg7', type: EntityType.platform, x: 8800, y: groundY, width: 2700, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'shh1', type: EntityType.hazardSpike, x: 1750, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'shh2', type: EntityType.hazardSpike, x: 3100, y: groundY - 20, width: 140, height: 20),
      GameEntity(id: 'shh3', type: EntityType.hazardSpike, x: 4700, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'shh4', type: EntityType.hazardSpike, x: 6050, y: groundY - 20, width: 140, height: 20),
      GameEntity(id: 'shh5', type: EntityType.hazardSpike, x: 7700, y: groundY - 20, width: 150, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'she1', type: EntityType.enemyShadow, x: 450, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.2, health: 3),
      GameEntity(id: 'she2', type: EntityType.enemyShadow, x: 1700, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.4, health: 3),
      GameEntity(id: 'she3', type: EntityType.enemyShadow, x: 3300, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.6, health: 3),
      GameEntity(id: 'she4', type: EntityType.enemyShadow, x: 4650, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.5, health: 3),
      GameEntity(id: 'she5', type: EntityType.enemyShadow, x: 6250, y: groundY - 44, width: 40, height: 44, patrolRange: 150, vx: 2.7, health: 3),
      GameEntity(id: 'she6', type: EntityType.enemyShadow, x: 9100, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.8, health: 3),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'shc_$i', type: EntityType.coin, x: 1260 + i * 25, y: 370, width: 22, height: 22));
    }
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'shc2_$i', type: EntityType.coin, x: 4210 + i * 25, y: 370, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'shhp1', type: EntityType.healthPot, x: 2950, y: groundY - 40, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'shhp2', type: EntityType.healthPot, x: 5900, y: groundY - 40, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'shcp1', type: EntityType.checkpoint, x: 1550, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'shcp2', type: EntityType.checkpoint, x: 5850, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 9,
      levelName: 'Shadow',
      theme: LevelTheme.shadow,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 11300, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 💎 LEVEL 10 — CRYSTAL (EXPANDED TO 11800px)
  static LevelData _createLevel10() {
    const double levelWidth = 11800.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'cg1', type: EntityType.platform, x: 0, y: groundY, width: 900, height: 120),
      GameEntity(id: 'cp1', type: EntityType.platform, x: 1000, y: 530, width: 160, height: 28),
      GameEntity(id: 'cp2', type: EntityType.platform, x: 1250, y: 440, width: 170, height: 28),
      GameEntity(id: 'cm1', type: EntityType.movingPlatform, x: 1500, y: 420, width: 150, height: 28, patrolRange: 180, vx: 2.2),
      GameEntity(id: 'cg2', type: EntityType.platform, x: 1850, y: groundY, width: 900, height: 120),
      GameEntity(id: 'cm2', type: EntityType.movingPlatform, x: 2850, y: 480, width: 150, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.2),
      GameEntity(id: 'cg3', type: EntityType.platform, x: 3200, y: groundY, width: 1000, height: 120),

      // Extension Section Platforms (4600 -> 11800)
      GameEntity(id: 'cp3', type: EntityType.platform, x: 4300, y: 530, width: 160, height: 28),
      GameEntity(id: 'cp4', type: EntityType.platform, x: 4550, y: 440, width: 170, height: 28),
      GameEntity(id: 'cm3', type: EntityType.movingPlatform, x: 4800, y: 420, width: 150, height: 28, patrolRange: 180, vx: 2.3),
      GameEntity(id: 'cg4', type: EntityType.platform, x: 5150, y: groundY, width: 900, height: 120),
      GameEntity(id: 'cm4', type: EntityType.movingPlatform, x: 6150, y: 480, width: 150, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.3),
      GameEntity(id: 'cg5', type: EntityType.platform, x: 6500, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'cp5', type: EntityType.platform, x: 7600, y: 520, width: 170, height: 28),
      GameEntity(id: 'cp6', type: EntityType.platform, x: 7850, y: 430, width: 180, height: 28),
      GameEntity(id: 'cm5', type: EntityType.movingPlatform, x: 8150, y: 410, width: 150, height: 28, patrolRange: 200, vx: 2.5),
      GameEntity(id: 'cg6', type: EntityType.platform, x: 8500, y: groundY, width: 3300, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'ch1', type: EntityType.hazardSpike, x: 2050, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'ch2', type: EntityType.hazardLightning, x: 3500, y: groundY - 24, width: 120, height: 24),
      GameEntity(id: 'ch3', type: EntityType.hazardSpike, x: 5350, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'ch4', type: EntityType.hazardLightning, x: 6800, y: groundY - 24, width: 130, height: 24),
      GameEntity(id: 'ch5', type: EntityType.hazardSpike, x: 8800, y: groundY - 20, width: 140, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'ce1', type: EntityType.enemyShadow, x: 450, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 2.2, health: 3),
      GameEntity(id: 'ce2', type: EntityType.enemyFire, x: 1950, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 2.4, health: 3),
      GameEntity(id: 'ce3', type: EntityType.enemyToxic, x: 3400, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.5, health: 3),
      GameEntity(id: 'ce4', type: EntityType.enemyIce, x: 3800, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.5, health: 3),
      GameEntity(id: 'ce5', type: EntityType.enemyFire, x: 5250, y: groundY - 40, width: 40, height: 40, patrolRange: 130, vx: 2.5, health: 3),
      GameEntity(id: 'ce6', type: EntityType.enemyToxic, x: 6700, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.6, health: 3),
      GameEntity(id: 'ce7', type: EntityType.enemyShadow, x: 8900, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.8, health: 3),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 10; i++) {
      collectibles.add(GameEntity(id: 'cc_$i', type: EntityType.coin, x: 1260 + i * 25, y: 390, width: 22, height: 22));
    }
    for (int i = 0; i < 10; i++) {
      collectibles.add(GameEntity(id: 'cc2_$i', type: EntityType.coin, x: 4560 + i * 25, y: 390, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'chp1', type: EntityType.healthPot, x: 1280, y: 350, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'chp2', type: EntityType.healthPot, x: 3300, y: groundY - 40, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'chp3', type: EntityType.healthPot, x: 6600, y: groundY - 40, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'ccp1', type: EntityType.checkpoint, x: 1900, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'ccp2', type: EntityType.checkpoint, x: 6550, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'ccp3', type: EntityType.checkpoint, x: 8600, y: groundY - 60, width: 44, height: 60),
    ];

    return LevelData(
      levelNumber: 10,
      levelName: 'Crystal',
      theme: LevelTheme.crystal,
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 11600, y: groundY - 90, width: 60, height: 90),
    );
  }
}
