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

  // 🌲 LEVEL 1 — FOREST
  static LevelData _createLevel1() {
    const double levelWidth = 3600.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'g1', type: EntityType.platform, x: 0, y: groundY, width: 1000, height: 120),
      GameEntity(id: 'g2', type: EntityType.platform, x: 1120, y: groundY, width: 980, height: 120),
      GameEntity(id: 'g3', type: EntityType.platform, x: 2220, y: groundY, width: 1380, height: 120),
      GameEntity(id: 'p1', type: EntityType.platform, x: 300, y: 550, width: 160, height: 28),
      GameEntity(id: 'p2', type: EntityType.platform, x: 550, y: 460, width: 180, height: 28),
      GameEntity(id: 'p3', type: EntityType.platform, x: 800, y: 530, width: 140, height: 28),
      GameEntity(id: 'p_bridge1', type: EntityType.platform, x: 1020, y: 560, width: 110, height: 24),
      GameEntity(id: 'p4', type: EntityType.platform, x: 1300, y: 520, width: 180, height: 28),
      GameEntity(id: 'p5', type: EntityType.platform, x: 1550, y: 420, width: 200, height: 28),
      GameEntity(id: 'p6', type: EntityType.platform, x: 1820, y: 520, width: 160, height: 28),
      GameEntity(id: 'p_bridge2', type: EntityType.platform, x: 2120, y: 540, width: 110, height: 24),
      GameEntity(id: 'p7', type: EntityType.platform, x: 2450, y: 520, width: 170, height: 28),
      GameEntity(id: 'p8', type: EntityType.platform, x: 2700, y: 430, width: 220, height: 28),
      GameEntity(id: 'p9', type: EntityType.platform, x: 3000, y: 520, width: 180, height: 28),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'e1', type: EntityType.enemySlime, x: 450, y: groundY - 32, width: 36, height: 32, patrolRange: 120, vx: 1.0, health: 1),
      GameEntity(id: 'e2', type: EntityType.enemyShadow, x: 750, y: groundY - 44, width: 40, height: 44, patrolRange: 100, vx: 1.5, health: 2),
      GameEntity(id: 'e3', type: EntityType.enemySlime, x: 1350, y: groundY - 32, width: 36, height: 32, patrolRange: 140, vx: 1.2, health: 1),
      GameEntity(id: 'e4', type: EntityType.enemyShadow, x: 1600, y: 420 - 44, width: 40, height: 44, patrolRange: 70, vx: 1.4, health: 2),
      GameEntity(id: 'e5', type: EntityType.enemySlime, x: 2500, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.3, health: 1),
      GameEntity(id: 'e6', type: EntityType.enemyShadow, x: 2800, y: 430 - 44, width: 40, height: 44, patrolRange: 80, vx: 1.6, health: 2),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'h1', type: EntityType.hazardSpike, x: 620, y: groundY - 20, width: 60, height: 20),
      GameEntity(id: 'h2', type: EntityType.hazardSpike, x: 1700, y: groundY - 20, width: 80, height: 20),
      GameEntity(id: 'h3', type: EntityType.hazardSpike, x: 2650, y: groundY - 20, width: 80, height: 20),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 5; i++) {
      collectibles.add(GameEntity(id: 'c1_$i', type: EntityType.coin, x: 320 + i * 30, y: 500, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'c2_$i', type: EntityType.coin, x: 1560 + i * 30, y: 370, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'hp1', type: EntityType.healthPot, x: 850, y: 480, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'cp1', type: EntityType.checkpoint, x: 1250, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'cp2', type: EntityType.checkpoint, x: 2350, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 3420, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 🔥 LEVEL 2 — FIRE
  static LevelData _createLevel2() {
    const double levelWidth = 3800.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'fg1', type: EntityType.platform, x: 0, y: groundY, width: 700, height: 120),
      // Lava chasm with moving platforms
      GameEntity(id: 'm1', type: EntityType.movingPlatform, x: 800, y: 550, width: 140, height: 28, patrolRange: 160, vx: 1.5),
      GameEntity(id: 'fg2', type: EntityType.platform, x: 1200, y: groundY, width: 600, height: 120),
      GameEntity(id: 'm2', type: EntityType.movingPlatform, x: 1900, y: 520, width: 130, height: 28, patrolRange: 0, moveRangeY: 120, vy: 1.4),
      GameEntity(id: 'fg3', type: EntityType.platform, x: 2200, y: groundY, width: 700, height: 120),
      GameEntity(id: 'm3', type: EntityType.movingPlatform, x: 3000, y: 540, width: 140, height: 28, patrolRange: 180, vx: 1.8),
      GameEntity(id: 'fg4', type: EntityType.platform, x: 3350, y: groundY, width: 450, height: 120),

      // Raised obsidian platforms
      GameEntity(id: 'fp1', type: EntityType.platform, x: 350, y: 500, width: 160, height: 28),
      GameEntity(id: 'fp2', type: EntityType.platform, x: 1400, y: 480, width: 180, height: 28),
      GameEntity(id: 'fp3', type: EntityType.platform, x: 2400, y: 450, width: 200, height: 28),
    ];

    final List<GameEntity> hazards = [
      // Large Lava pools in chasms
      GameEntity(id: 'lava1', type: EntityType.hazardLava, x: 700, y: 720, width: 500, height: 80),
      GameEntity(id: 'lava2', type: EntityType.hazardLava, x: 1800, y: 720, width: 400, height: 80),
      GameEntity(id: 'lava3', type: EntityType.hazardLava, x: 2900, y: 720, width: 450, height: 80),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'fe1', type: EntityType.enemyFire, x: 400, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 1.6, health: 2),
      GameEntity(id: 'fe2', type: EntityType.enemyFire, x: 1450, y: 480 - 40, width: 40, height: 40, patrolRange: 60, vx: 1.8, health: 2),
      GameEntity(id: 'fe3', type: EntityType.enemyFire, x: 2500, y: groundY - 40, width: 40, height: 40, patrolRange: 140, vx: 2.0, health: 2),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'fc_$i', type: EntityType.coin, x: 1420 + i * 30, y: 430, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'fhp1', type: EntityType.healthPot, x: 2500, y: 400, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'fcp1', type: EntityType.checkpoint, x: 1300, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'fcp2', type: EntityType.checkpoint, x: 2300, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 3600, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 🌊 LEVEL 3 — WATER
  static LevelData _createLevel3() {
    const double levelWidth = 3800.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'wg1', type: EntityType.platform, x: 0, y: groundY, width: 800, height: 120),
      GameEntity(id: 'wp1', type: EntityType.platform, x: 900, y: 560, width: 140, height: 26),
      GameEntity(id: 'wp2', type: EntityType.platform, x: 1120, y: 480, width: 150, height: 26),
      GameEntity(id: 'wp3', type: EntityType.platform, x: 1350, y: 550, width: 140, height: 26),
      GameEntity(id: 'wg2', type: EntityType.platform, x: 1580, y: groundY, width: 700, height: 120),
      GameEntity(id: 'wm1', type: EntityType.movingPlatform, x: 2350, y: 530, width: 130, height: 26, patrolRange: 160, vx: 1.6),
      GameEntity(id: 'wg3', type: EntityType.platform, x: 2700, y: groundY, width: 1100, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'wh1', type: EntityType.hazardSpike, x: 1800, y: groundY - 20, width: 90, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'we1', type: EntityType.enemySlime, x: 500, y: groundY - 32, width: 36, height: 32, patrolRange: 100, vx: 1.2),
      GameEntity(id: 'we2', type: EntityType.enemyShadow, x: 1850, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 1.5),
      GameEntity(id: 'we3', type: EntityType.enemySlime, x: 2900, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.4),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 5; i++) {
      collectibles.add(GameEntity(id: 'wc_$i', type: EntityType.coin, x: 920 + i * 100, y: 420, width: 22, height: 22));
    }

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'wcp1', type: EntityType.checkpoint, x: 1650, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 3600, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ❄️ LEVEL 4 — ICE
  static LevelData _createLevel4() {
    const double levelWidth = 4000.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'ig1', type: EntityType.slipperyPlatform, x: 0, y: groundY, width: 900, height: 120),
      GameEntity(id: 'ip1', type: EntityType.slipperyPlatform, x: 1000, y: 540, width: 160, height: 28),
      GameEntity(id: 'ip2', type: EntityType.slipperyPlatform, x: 1250, y: 450, width: 170, height: 28),
      GameEntity(id: 'ig2', type: EntityType.slipperyPlatform, x: 1500, y: groundY, width: 800, height: 120),
      GameEntity(id: 'im1', type: EntityType.movingPlatform, x: 2400, y: 520, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'ig3', type: EntityType.slipperyPlatform, x: 2800, y: groundY, width: 1200, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'ih1', type: EntityType.hazardSpike, x: 1750, y: groundY - 20, width: 100, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'ie1', type: EntityType.enemyIce, x: 600, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 1.8),
      GameEntity(id: 'ie2', type: EntityType.enemyIce, x: 1800, y: groundY - 40, width: 40, height: 40, patrolRange: 130, vx: 2.0),
      GameEntity(id: 'ie3', type: EntityType.enemyIce, x: 3100, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.2),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 7; i++) {
      collectibles.add(GameEntity(id: 'ic_$i', type: EntityType.coin, x: 1050 + i * 40, y: 390, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'ihp', type: EntityType.healthPot, x: 1280, y: 400, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'icp1', type: EntityType.checkpoint, x: 1600, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'icp2', type: EntityType.checkpoint, x: 2900, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 3800, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 🏜️ LEVEL 5 — DESERT
  static LevelData _createLevel5() {
    const double levelWidth = 4000.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'dg1', type: EntityType.platform, x: 0, y: groundY, width: 850, height: 120),
      GameEntity(id: 'dp1', type: EntityType.platform, x: 950, y: 520, width: 160, height: 28),
      GameEntity(id: 'dp2', type: EntityType.platform, x: 1200, y: 420, width: 180, height: 28),
      GameEntity(id: 'dg2', type: EntityType.platform, x: 1450, y: groundY, width: 800, height: 120),
      GameEntity(id: 'dm1', type: EntityType.movingPlatform, x: 2350, y: 500, width: 140, height: 28, patrolRange: 200, vx: 1.8),
      GameEntity(id: 'dg3', type: EntityType.platform, x: 2750, y: groundY, width: 1250, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'dh1', type: EntityType.hazardSpike, x: 1700, y: groundY - 20, width: 120, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'de1', type: EntityType.enemySlime, x: 450, y: groundY - 32, width: 36, height: 32, patrolRange: 120, vx: 1.4),
      GameEntity(id: 'de2', type: EntityType.enemyShadow, x: 1250, y: 420 - 44, width: 40, height: 44, patrolRange: 70, vx: 1.6),
      GameEntity(id: 'de3', type: EntityType.enemyShadow, x: 1900, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 1.8),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'dc_$i', type: EntityType.coin, x: 1220 + i * 30, y: 370, width: 22, height: 22));
    }

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'dcp1', type: EntityType.checkpoint, x: 1520, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 3800, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ⚡ LEVEL 6 — THUNDER
  static LevelData _createLevel6() {
    const double levelWidth = 4200.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'tg1', type: EntityType.platform, x: 0, y: groundY, width: 800, height: 120),
      GameEntity(id: 'tm1', type: EntityType.movingPlatform, x: 900, y: 520, width: 140, height: 28, patrolRange: 160, vx: 2.0),
      GameEntity(id: 'tg2', type: EntityType.platform, x: 1250, y: groundY, width: 800, height: 120),
      GameEntity(id: 'tm2', type: EntityType.movingPlatform, x: 2150, y: 480, width: 140, height: 28, patrolRange: 0, moveRangeY: 140, vy: 1.8),
      GameEntity(id: 'tg3', type: EntityType.platform, x: 2500, y: groundY, width: 1700, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'th1', type: EntityType.hazardLightning, x: 1500, y: groundY - 24, width: 100, height: 24),
      GameEntity(id: 'th2', type: EntityType.hazardLightning, x: 2800, y: groundY - 24, width: 120, height: 24),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'te1', type: EntityType.enemyShadow, x: 500, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 2.0),
      GameEntity(id: 'te2', type: EntityType.enemyShadow, x: 1650, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.2),
      GameEntity(id: 'te3', type: EntityType.enemyShadow, x: 3100, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.4),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'tc_$i', type: EntityType.coin, x: 1300 + i * 40, y: 450, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'thp', type: EntityType.healthPot, x: 2600, y: 450, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'tcp1', type: EntityType.checkpoint, x: 1350, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'tcp2', type: EntityType.checkpoint, x: 2600, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 4000, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ☠️ LEVEL 7 — POISON
  static LevelData _createLevel7() {
    const double levelWidth = 4200.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'pg1', type: EntityType.platform, x: 0, y: groundY, width: 700, height: 120),
      GameEntity(id: 'pm1', type: EntityType.movingPlatform, x: 800, y: 530, width: 140, height: 28, patrolRange: 160, vx: 1.8),
      GameEntity(id: 'pg2', type: EntityType.platform, x: 1150, y: groundY, width: 600, height: 120),
      GameEntity(id: 'pp1', type: EntityType.platform, x: 1850, y: 480, width: 160, height: 28),
      GameEntity(id: 'pp2', type: EntityType.platform, x: 2100, y: 400, width: 180, height: 28),
      GameEntity(id: 'pg3', type: EntityType.platform, x: 2400, y: groundY, width: 1800, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'poison1', type: EntityType.hazardPoison, x: 700, y: 720, width: 450, height: 80),
      GameEntity(id: 'poison2', type: EntityType.hazardPoison, x: 1750, y: 720, width: 650, height: 80),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'pe1', type: EntityType.enemyToxic, x: 400, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 1.8, health: 2),
      GameEntity(id: 'pe2', type: EntityType.enemyToxic, x: 1300, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 2.0, health: 2),
      GameEntity(id: 'pe3', type: EntityType.enemyToxic, x: 2600, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.2, health: 3),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 7; i++) {
      collectibles.add(GameEntity(id: 'pc_$i', type: EntityType.coin, x: 2120 + i * 25, y: 350, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'php', type: EntityType.healthPot, x: 2200, y: 320, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'pcp1', type: EntityType.checkpoint, x: 1250, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 4000, y: groundY - 90, width: 60, height: 90),
    );
  }

  // ☁️ LEVEL 8 — SKY
  static LevelData _createLevel8() {
    const double levelWidth = 4400.0;
    const double levelHeight = 800.0;
    const double startGroundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'sg1', type: EntityType.platform, x: 0, y: startGroundY, width: 600, height: 120),
      GameEntity(id: 'sp1', type: EntityType.platform, x: 700, y: 550, width: 140, height: 28),
      GameEntity(id: 'sp2', type: EntityType.platform, x: 920, y: 460, width: 150, height: 28),
      GameEntity(id: 'sm1', type: EntityType.movingPlatform, x: 1150, y: 420, width: 140, height: 28, patrolRange: 180, vx: 2.0),
      GameEntity(id: 'sp3', type: EntityType.platform, x: 1500, y: 450, width: 160, height: 28),
      GameEntity(id: 'sp4', type: EntityType.platform, x: 1750, y: 380, width: 180, height: 28),
      GameEntity(id: 'sm2', type: EntityType.movingPlatform, x: 2050, y: 420, width: 140, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.0),
      GameEntity(id: 'sp5', type: EntityType.platform, x: 2350, y: 450, width: 200, height: 28),
      GameEntity(id: 'sm3', type: EntityType.movingPlatform, x: 2700, y: 420, width: 140, height: 28, patrolRange: 200, vx: 2.2),
      GameEntity(id: 'sp6', type: EntityType.platform, x: 3100, y: 480, width: 180, height: 28),
      GameEntity(id: 'sg2', type: EntityType.platform, x: 3400, y: startGroundY, width: 1000, height: 120),
    ];

    final List<GameEntity> hazards = [];

    final List<GameEntity> enemies = [
      GameEntity(id: 'se1', type: EntityType.enemyShadow, x: 950, y: 460 - 44, width: 40, height: 44, patrolRange: 50, vx: 1.8),
      GameEntity(id: 'se2', type: EntityType.enemyShadow, x: 1780, y: 380 - 44, width: 40, height: 44, patrolRange: 60, vx: 2.0),
      GameEntity(id: 'se3', type: EntityType.enemyShadow, x: 2380, y: 450 - 44, width: 40, height: 44, patrolRange: 80, vx: 2.2),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'sc_$i', type: EntityType.coin, x: 1770 + i * 30, y: 330, width: 22, height: 22));
    }

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'scp1', type: EntityType.checkpoint, x: 1550, y: 450 - 60, width: 44, height: 60),
      GameEntity(id: 'scp2', type: EntityType.checkpoint, x: 2400, y: 450 - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 4200, y: startGroundY - 90, width: 60, height: 90),
    );
  }

  // 🌑 LEVEL 9 — SHADOW
  static LevelData _createLevel9() {
    const double levelWidth = 4400.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'shg1', type: EntityType.platform, x: 0, y: groundY, width: 800, height: 120),
      GameEntity(id: 'shp1', type: EntityType.platform, x: 900, y: 520, width: 150, height: 28),
      GameEntity(id: 'shp2', type: EntityType.platform, x: 1150, y: 420, width: 160, height: 28),
      GameEntity(id: 'shg2', type: EntityType.platform, x: 1400, y: groundY, width: 800, height: 120),
      GameEntity(id: 'shm1', type: EntityType.movingPlatform, x: 2300, y: 500, width: 140, height: 28, patrolRange: 180, vx: 2.2),
      GameEntity(id: 'shg3', type: EntityType.platform, x: 2650, y: groundY, width: 1750, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'shh1', type: EntityType.hazardSpike, x: 1600, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'shh2', type: EntityType.hazardSpike, x: 2900, y: groundY - 20, width: 140, height: 20),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'she1', type: EntityType.enemyShadow, x: 450, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.2, health: 3),
      GameEntity(id: 'she2', type: EntityType.enemyShadow, x: 1550, y: groundY - 44, width: 40, height: 44, patrolRange: 140, vx: 2.4, health: 3),
      GameEntity(id: 'she3', type: EntityType.enemyShadow, x: 3100, y: groundY - 44, width: 40, height: 44, patrolRange: 160, vx: 2.6, health: 3),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'shc_$i', type: EntityType.coin, x: 1160 + i * 25, y: 370, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'shhp', type: EntityType.healthPot, x: 2750, y: groundY - 40, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'shcp1', type: EntityType.checkpoint, x: 1450, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 4200, y: groundY - 90, width: 60, height: 90),
    );
  }

  // 💎 LEVEL 10 — CRYSTAL
  static LevelData _createLevel10() {
    const double levelWidth = 4600.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [
      GameEntity(id: 'cg1', type: EntityType.platform, x: 0, y: groundY, width: 800, height: 120),
      GameEntity(id: 'cp1', type: EntityType.platform, x: 900, y: 530, width: 160, height: 28),
      GameEntity(id: 'cp2', type: EntityType.platform, x: 1150, y: 440, width: 170, height: 28),
      GameEntity(id: 'cm1', type: EntityType.movingPlatform, x: 1400, y: 420, width: 150, height: 28, patrolRange: 180, vx: 2.2),
      GameEntity(id: 'cg2', type: EntityType.platform, x: 1750, y: groundY, width: 800, height: 120),
      GameEntity(id: 'cm2', type: EntityType.movingPlatform, x: 2650, y: 480, width: 150, height: 28, patrolRange: 0, moveRangeY: 150, vy: 2.2),
      GameEntity(id: 'cg3', type: EntityType.platform, x: 3000, y: groundY, width: 1600, height: 120),
    ];

    final List<GameEntity> hazards = [
      GameEntity(id: 'ch1', type: EntityType.hazardSpike, x: 1950, y: groundY - 20, width: 120, height: 20),
      GameEntity(id: 'ch2', type: EntityType.hazardLightning, x: 3300, y: groundY - 24, width: 120, height: 24),
    ];

    final List<GameEntity> enemies = [
      GameEntity(id: 'ce1', type: EntityType.enemyShadow, x: 450, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 2.2, health: 3),
      GameEntity(id: 'ce2', type: EntityType.enemyFire, x: 1850, y: groundY - 40, width: 40, height: 40, patrolRange: 120, vx: 2.4, health: 3),
      GameEntity(id: 'ce3', type: EntityType.enemyToxic, x: 3200, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.5, health: 3),
      GameEntity(id: 'ce4', type: EntityType.enemyIce, x: 3600, y: groundY - 40, width: 40, height: 40, patrolRange: 150, vx: 2.5, health: 3),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 10; i++) {
      collectibles.add(GameEntity(id: 'cc_$i', type: EntityType.coin, x: 1160 + i * 25, y: 390, width: 22, height: 22));
    }
    collectibles.add(GameEntity(id: 'chp1', type: EntityType.healthPot, x: 1180, y: 350, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'chp2', type: EntityType.healthPot, x: 3100, y: groundY - 40, width: 24, height: 28));

    final List<GameEntity> checkpoints = [
      GameEntity(id: 'ccp1', type: EntityType.checkpoint, x: 1800, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'ccp2', type: EntityType.checkpoint, x: 3050, y: groundY - 60, width: 44, height: 60),
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
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: 4400, y: groundY - 90, width: 60, height: 90),
    );
  }
}
