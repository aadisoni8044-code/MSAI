import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/level_objects.dart';

class LevelData {
  final int levelNumber;
  final String title;
  final double worldWidth;
  final double worldHeight;
  final Offset playerSpawn;
  final List<PlatformBlock> platforms;
  final List<Collectible> collectibles;
  final List<Enemy> enemies;
  final List<Checkpoint> checkpoints;
  final ExitPortal exitPortal;

  LevelData({
    required this.levelNumber,
    required this.title,
    required this.worldWidth,
    required this.worldHeight,
    required this.playerSpawn,
    required this.platforms,
    required this.collectibles,
    required this.enemies,
    required this.checkpoints,
    required this.exitPortal,
  });

  factory LevelData.level1() {
    const double levelWidth = 3200.0;
    const double levelHeight = 600.0;
    const double groundY = 500.0;

    // Ground platforms with strategic gaps
    final List<PlatformBlock> platforms = [
      // Section 1: Starting Ground (x: 0 to 700)
      const PlatformBlock(
        bounds: Rect.fromLTWH(0, groundY, 700, 100),
        type: PlatformType.grassGround,
      ),
      // Elevated Step 1
      const PlatformBlock(
        bounds: Rect.fromLTWH(250, 410, 140, 24),
        type: PlatformType.woodenBridge,
      ),
      const PlatformBlock(
        bounds: Rect.fromLTWH(440, 330, 150, 24),
        type: PlatformType.floatingStone,
      ),

      // Gap 1 (x: 700 to 820)

      // Section 2: Middle Forest Area (x: 820 to 1600)
      const PlatformBlock(
        bounds: Rect.fromLTWH(820, groundY, 780, 100),
        type: PlatformType.grassGround,
      ),
      // Elevated platforms & Hidden Area access
      const PlatformBlock(
        bounds: Rect.fromLTWH(950, 390, 140, 24),
        type: PlatformType.woodenBridge,
      ),
      const PlatformBlock(
        bounds: Rect.fromLTWH(1140, 310, 160, 24),
        type: PlatformType.floatingStone,
      ),
      // Hidden High Platform
      const PlatformBlock(
        bounds: Rect.fromLTWH(1320, 220, 180, 24),
        type: PlatformType.floatingStone,
      ),

      // Gap 2 (x: 1600 to 1750)

      // Section 3: Checkpoint & Dangerous Cavern Area (x: 1750 to 2500)
      const PlatformBlock(
        bounds: Rect.fromLTWH(1750, groundY, 750, 100),
        type: PlatformType.grassGround,
      ),
      const PlatformBlock(
        bounds: Rect.fromLTWH(1900, 400, 130, 24),
        type: PlatformType.woodenBridge,
      ),
      const PlatformBlock(
        bounds: Rect.fromLTWH(2100, 320, 140, 24),
        type: PlatformType.floatingStone,
      ),
      const PlatformBlock(
        bounds: Rect.fromLTWH(2300, 400, 130, 24),
        type: PlatformType.woodenBridge,
      ),

      // Gap 3 (x: 2500 to 2620)

      // Section 4: Final Stretch to Portal (x: 2620 to 3200)
      const PlatformBlock(
        bounds: Rect.fromLTWH(2620, groundY, 580, 100),
        type: PlatformType.grassGround,
      ),
      const PlatformBlock(
        bounds: Rect.fromLTWH(2750, 390, 150, 24),
        type: PlatformType.floatingStone,
      ),
    ];

    // Collectibles (Glowing Crystals and Coins)
    final List<Collectible> collectibles = [
      Collectible(id: 'c1', position: const Offset(300, 365)),
      Collectible(id: 'c2', position: const Offset(490, 285)),
      Collectible(id: 'c3', position: const Offset(900, 455)),
      Collectible(id: 'c4', position: const Offset(1000, 345)),
      Collectible(id: 'c5', position: const Offset(1200, 265)),
      // Hidden collectible area rewards
      Collectible(id: 'c6', position: const Offset(1360, 175)),
      Collectible(id: 'c7', position: const Offset(1430, 175)),
      Collectible(id: 'c8', position: const Offset(1850, 455)),
      Collectible(id: 'c9', position: const Offset(2150, 275)),
      Collectible(id: 'c10', position: const Offset(2800, 345)),
      Collectible(id: 'c11', position: const Offset(3000, 455)),
    ];

    // Enemies
    final List<Enemy> enemies = [
      Enemy(id: 'e1', position: const Offset(450, groundY - 32), patrolDistance: 180, type: EnemyType.slime),
      Enemy(id: 'e2', position: const Offset(1020, groundY - 32), patrolDistance: 220, type: EnemyType.goblin),
      Enemy(id: 'e3', position: const Offset(1200, 270), patrolDistance: 120, type: EnemyType.flyingBat),
      Enemy(id: 'e4', position: const Offset(1950, groundY - 32), patrolDistance: 200, type: EnemyType.slime),
      Enemy(id: 'e5', position: const Offset(2250, groundY - 32), patrolDistance: 180, type: EnemyType.goblin),
      Enemy(id: 'e6', position: const Offset(2720, groundY - 32), patrolDistance: 200, type: EnemyType.slime),
    ];

    // Checkpoints
    final List<Checkpoint> checkpoints = [
      Checkpoint(id: 'cp1', position: const Offset(1780, groundY - 50)),
    ];

    // Exit Portal
    final ExitPortal exitPortal = ExitPortal(
      position: const Offset(3050, groundY - 70),
    );

    return LevelData(
      levelNumber: 1,
      title: "Whispering Woods",
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerSpawn: const Offset(80, groundY - 48),
      platforms: platforms,
      collectibles: collectibles,
      enemies: enemies,
      checkpoints: checkpoints,
      exitPortal: exitPortal,
    );
  }
}
