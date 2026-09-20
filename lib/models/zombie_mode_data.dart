import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';

class WaveConfig {
  final int waveNumber;
  final int normalCount;
  final int fastCount;
  final int largeCount;

  WaveConfig({
    required this.waveNumber,
    required this.normalCount,
    required this.fastCount,
    required this.largeCount,
  });

  int get totalZombies => normalCount + fastCount + largeCount;
}

class ZombieModeData {
  final double worldWidth;
  final double worldHeight;
  final double playerStartX;
  final double playerStartY;
  final List<GameEntity> platforms;
  final List<Rect> watchtowers;
  final List<GameEntity> collectibles;

  ZombieModeData({
    required this.worldWidth,
    required this.worldHeight,
    required this.playerStartX,
    required this.playerStartY,
    required this.platforms,
    required this.watchtowers,
    required this.collectibles,
  });

  static ZombieModeData createNightWorld() {
    const double levelWidth = 4500.0;
    const double levelHeight = 850.0;
    const double groundY = 700.0;

    final List<GameEntity> platforms = [
      // Main ground sections
      GameEntity(id: 'zg1', type: EntityType.platform, x: 0, y: groundY, width: 1200, height: 150),
      GameEntity(id: 'zg2', type: EntityType.platform, x: 1350, y: groundY, width: 1400, height: 150),
      GameEntity(id: 'zg3', type: EntityType.platform, x: 2900, y: groundY, width: 1600, height: 150),

      // Watchtower 1 Platforms (Left Base)
      GameEntity(id: 'wt1_p1', type: EntityType.platform, x: 500, y: 550, width: 180, height: 26),
      GameEntity(id: 'wt1_p2', type: EntityType.platform, x: 480, y: 410, width: 220, height: 26),
      GameEntity(id: 'wt1_top', type: EntityType.platform, x: 460, y: 270, width: 260, height: 28),

      // Abandoned Building / Scaffold Platforms
      GameEntity(id: 'b1_p1', type: EntityType.platform, x: 1100, y: 560, width: 160, height: 26),
      GameEntity(id: 'b1_p2', type: EntityType.platform, x: 1650, y: 520, width: 200, height: 26),
      GameEntity(id: 'b1_p3', type: EntityType.platform, x: 1950, y: 420, width: 220, height: 26),

      // Watchtower 2 Platforms (Center Outpost)
      GameEntity(id: 'wt2_p1', type: EntityType.platform, x: 2300, y: 540, width: 180, height: 26),
      GameEntity(id: 'wt2_p2', type: EntityType.platform, x: 2280, y: 390, width: 220, height: 26),
      GameEntity(id: 'wt2_top', type: EntityType.platform, x: 2260, y: 250, width: 260, height: 28),

      // High Scaffolding Platforms
      GameEntity(id: 'sc1', type: EntityType.platform, x: 3100, y: 550, width: 190, height: 26),
      GameEntity(id: 'sc2', type: EntityType.platform, x: 3400, y: 430, width: 210, height: 26),
      GameEntity(id: 'sc3_top', type: EntityType.platform, x: 3700, y: 300, width: 240, height: 28),
    ];

    final List<Rect> watchtowers = [
      const Rect.fromLTWH(460, 270, 260, 430),
      const Rect.fromLTWH(2260, 250, 260, 450),
      const Rect.fromLTWH(3700, 300, 240, 400),
    ];

    final List<GameEntity> collectibles = [];
    for (int i = 0; i < 15; i++) {
      collectibles.add(GameEntity(
        id: 'zcoin_$i',
        type: EntityType.coin,
        x: 400 + i * 250,
        y: 650,
        width: 22,
        height: 22,
      ));
    }
    collectibles.add(GameEntity(id: 'zhp1', type: EntityType.healthPot, x: 580, y: 230, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'zhp2', type: EntityType.healthPot, x: 2380, y: 210, width: 24, height: 28));
    collectibles.add(GameEntity(id: 'zhp3', type: EntityType.healthPot, x: 3800, y: 260, width: 24, height: 28));

    return ZombieModeData(
      worldWidth: levelWidth,
      worldHeight: levelHeight,
      playerStartX: 200,
      playerStartY: groundY - 60,
      platforms: platforms,
      watchtowers: watchtowers,
      collectibles: collectibles,
    );
  }

  static WaveConfig getWaveConfig(int waveNumber) {
    if (waveNumber == 1) {
      // WAVE 1: 10 Zombies (Weak, slow tutorial wave)
      return WaveConfig(waveNumber: 1, normalCount: 10, fastCount: 0, largeCount: 0);
    } else if (waveNumber == 2) {
      // WAVE 2: 20 Zombies (Slightly faster, weak)
      return WaveConfig(waveNumber: 2, normalCount: 18, fastCount: 2, largeCount: 0);
    } else if (waveNumber == 3) {
      // WAVE 3: 30 Zombies
      return WaveConfig(waveNumber: 3, normalCount: 24, fastCount: 6, largeCount: 0);
    } else if (waveNumber == 4) {
      // WAVE 4: 40 Zombies
      return WaveConfig(waveNumber: 4, normalCount: 30, fastCount: 8, largeCount: 2);
    } else if (waveNumber == 5) {
      // WAVE 5: 50 Zombies (Milestone wave, includes Large Zombies)
      return WaveConfig(waveNumber: 5, normalCount: 35, fastCount: 12, largeCount: 3);
    } else {
      // WAVE 6+: 60, 70, 80, 90, 100 Zombies
      final total = 50 + (waveNumber - 5) * 10;
      final largeCount = 3 + (waveNumber - 5);
      final fastCount = 12 + (waveNumber - 5) * 2;
      final normalCount = (total - largeCount - fastCount).clamp(10, 1000);
      return WaveConfig(
        waveNumber: waveNumber,
        normalCount: normalCount,
        fastCount: fastCount,
        largeCount: largeCount,
      );
    }
  }
}
