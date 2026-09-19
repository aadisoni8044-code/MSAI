import 'package:enchanted_forest_adventure/models/game_entity.dart';

class LevelData {
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

  factory LevelData.createLevel1() {
    const double levelWidth = 3600.0;
    const double levelHeight = 800.0;
    const double groundY = 680.0;

    final List<GameEntity> platforms = [];
    final List<GameEntity> enemies = [];
    final List<GameEntity> collectibles = [];
    final List<GameEntity> hazards = [];
    final List<GameEntity> checkpoints = [];

    // Main Ground with gaps
    // Section 1: 0 -> 1000
    platforms.add(GameEntity(
      id: 'ground_1',
      type: EntityType.platform,
      x: 0,
      y: groundY,
      width: 1000,
      height: 120,
    ));

    // Gap 1000 - 1120 (Chasm)

    // Section 2: 1120 -> 2100
    platforms.add(GameEntity(
      id: 'ground_2',
      type: EntityType.platform,
      x: 1120,
      y: groundY,
      width: 980,
      height: 120,
    ));

    // Gap 2100 - 2220

    // Section 3: 2220 -> 3600
    platforms.add(GameEntity(
      id: 'ground_3',
      type: EntityType.platform,
      x: 2220,
      y: groundY,
      width: 1380,
      height: 120,
    ));

    // Raised Ancient Tree Root & Cliff Platforms
    platforms.addAll([
      GameEntity(id: 'plat_1', type: EntityType.platform, x: 300, y: 550, width: 160, height: 28),
      GameEntity(id: 'plat_2', type: EntityType.platform, x: 550, y: 460, width: 180, height: 28),
      GameEntity(id: 'plat_3', type: EntityType.platform, x: 800, y: 530, width: 140, height: 28),

      // Over Chasm 1
      GameEntity(id: 'plat_bridge_1', type: EntityType.platform, x: 1020, y: 560, width: 110, height: 24),

      // Mid Forest Platforms
      GameEntity(id: 'plat_4', type: EntityType.platform, x: 1300, y: 520, width: 180, height: 28),
      GameEntity(id: 'plat_5', type: EntityType.platform, x: 1550, y: 420, width: 200, height: 28),
      GameEntity(id: 'plat_6', type: EntityType.platform, x: 1820, y: 520, width: 160, height: 28),

      // Over Chasm 2
      GameEntity(id: 'plat_bridge_2', type: EntityType.platform, x: 2120, y: 540, width: 110, height: 24),

      // Endgame High Root Platforms
      GameEntity(id: 'plat_7', type: EntityType.platform, x: 2450, y: 520, width: 170, height: 28),
      GameEntity(id: 'plat_8', type: EntityType.platform, x: 2700, y: 430, width: 220, height: 28),
      GameEntity(id: 'plat_9', type: EntityType.platform, x: 3000, y: 520, width: 180, height: 28),
    ]);

    // Forest Enemies
    enemies.addAll([
      GameEntity(id: 'enemy_1', type: EntityType.enemySlime, x: 450, y: groundY - 32, width: 36, height: 32, patrolRange: 120, vx: 1.0, health: 1),
      GameEntity(id: 'enemy_2', type: EntityType.enemyShadow, x: 750, y: groundY - 44, width: 40, height: 44, patrolRange: 100, vx: 1.5, health: 2),
      GameEntity(id: 'enemy_3', type: EntityType.enemySlime, x: 1350, y: groundY - 32, width: 36, height: 32, patrolRange: 140, vx: 1.2, health: 1),
      GameEntity(id: 'enemy_4', type: EntityType.enemyShadow, x: 1600, y: 420 - 44, width: 40, height: 44, patrolRange: 70, vx: 1.4, health: 2),
      GameEntity(id: 'enemy_5', type: EntityType.enemySlime, x: 2500, y: groundY - 32, width: 36, height: 32, patrolRange: 150, vx: 1.3, health: 1),
      GameEntity(id: 'enemy_6', type: EntityType.enemyShadow, x: 2800, y: 430 - 44, width: 40, height: 44, patrolRange: 80, vx: 1.6, health: 2),
      GameEntity(id: 'enemy_7', type: EntityType.enemyShadow, x: 3100, y: groundY - 44, width: 40, height: 44, patrolRange: 120, vx: 1.8, health: 3),
    ]);

    // Spikes & Environmental Hazards
    hazards.addAll([
      GameEntity(id: 'spike_1', type: EntityType.hazardSpike, x: 620, y: groundY - 20, width: 60, height: 20),
      GameEntity(id: 'spike_2', type: EntityType.hazardSpike, x: 1700, y: groundY - 20, width: 80, height: 20),
      GameEntity(id: 'spike_3', type: EntityType.hazardSpike, x: 2650, y: groundY - 20, width: 80, height: 20),
    ]);

    // Coins & Health Pickups
    for (int i = 0; i < 5; i++) {
      collectibles.add(GameEntity(id: 'coin_start_$i', type: EntityType.coin, x: 320 + i * 30, y: 500, width: 22, height: 22));
    }
    for (int i = 0; i < 6; i++) {
      collectibles.add(GameEntity(id: 'coin_mid_$i', type: EntityType.coin, x: 1560 + i * 30, y: 370, width: 22, height: 22));
    }
    for (int i = 0; i < 8; i++) {
      collectibles.add(GameEntity(id: 'coin_end_$i', type: EntityType.coin, x: 2710 + i * 28, y: 380, width: 22, height: 22));
    }
    // Ground coins
    collectibles.add(GameEntity(id: 'coin_g1', type: EntityType.coin, x: 200, y: groundY - 40, width: 22, height: 22));
    collectibles.add(GameEntity(id: 'coin_g2', type: EntityType.coin, x: 1200, y: groundY - 40, width: 22, height: 22));
    collectibles.add(GameEntity(id: 'coin_g3', type: EntityType.coin, x: 2300, y: groundY - 40, width: 22, height: 22));

    // Health Potions
    collectibles.add(GameEntity(id: 'health_1', type: EntityType.healthPot, x: 850, y: 480, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'health_2', type: EntityType.healthPot, x: 1900, y: 470, width: 24, height: 28));

    // Checkpoints (Glowing Ancient Forest Shrines)
    checkpoints.addAll([
      GameEntity(id: 'checkpoint_1', type: EntityType.checkpoint, x: 1250, y: groundY - 60, width: 44, height: 60),
      GameEntity(id: 'checkpoint_2', type: EntityType.checkpoint, x: 2350, y: groundY - 60, width: 44, height: 60),
    ]);

    // End Goal Portal
    final goalPortal = GameEntity(
      id: 'goal_portal',
      type: EntityType.goalPortal,
      x: 3420,
      y: groundY - 90,
      width: 60,
      height: 90,
    );

    return LevelData(
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 100,
      playerStartY: groundY - 60,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: goalPortal,
    );
  }
}
