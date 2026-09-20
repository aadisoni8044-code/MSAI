import 'dart:math' as math;
import '../models/vector3d.dart';
import '../models/zombie.dart';
import '../models/item.dart';
import '../models/player.dart';
import 'map_world.dart';

class WaveManager {
  int waveNumber = 1;
  int totalKills = 0;
  int zombiesKilledInWave = 0;
  int zombiesSpawnedInWave = 0;

  bool airDropTriggered = false;
  Vector3D? airDropPosition;
  String? airDropNotificationMessage;
  double notificationTimer = 0.0;

  double spawnTimer = 0.0;
  final double spawnInterval = 1.8;
  final int maxActiveZombies = 12; // Mobile optimization cap

  // Zombie pool for re-use
  final List<Zombie> activeZombies = [];
  final List<Zombie> zombiePool = [];

  int get totalZombiesForWave => 4 + waveNumber * 3;
  int get remainingInWave => totalZombiesForWave - zombiesKilledInWave;

  void update(double dt, Player player, MapWorld world) {
    if (notificationTimer > 0.0) {
      notificationTimer -= dt;
      if (notificationTimer <= 0.0) {
        airDropNotificationMessage = null;
      }
    }

    // Spawn queue check
    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0.0;
      if (zombiesSpawnedInWave < totalZombiesForWave && activeZombies.where((z) => z.isAlive).length < maxActiveZombies) {
        _spawnZombie(world, player);
      }
    }

    // Check if wave complete
    if (zombiesKilledInWave >= totalZombiesForWave) {
      _startNextWave(player);
    }
  }

  void _spawnZombie(MapWorld world, Player player) {
    final spawnPos = world.getRandomSpawnPoint(player.position);
    zombiesSpawnedInWave++;

    // Determine type based on wave
    final rand = math.Random().nextDouble();
    ZombieType type = ZombieType.normal;
    if (waveNumber >= 2 && rand < 0.25) {
      type = ZombieType.fast;
    } else if (waveNumber >= 3 && rand > 0.8) {
      type = ZombieType.tank;
    }

    final id = 'zombie_${waveNumber}_$zombiesSpawnedInWave';

    if (zombiePool.isNotEmpty) {
      final pooledZombie = zombiePool.removeLast();
      pooledZombie.reuse(newId: id, newPosition: spawnPos, newType: type);
      activeZombies.add(pooledZombie);
    } else {
      activeZombies.add(Zombie(
        id: id,
        position: spawnPos,
        type: type,
      ));
    }
  }

  void onZombieDefeated(Zombie zombie, Player player, MapWorld world) {
    totalKills++;
    zombiesKilledInWave++;
    player.killCount++;

    // 10 KILLS AIR-DROP EVENT TRIGGER
    if (totalKills >= 10 && !airDropTriggered) {
      _triggerAirDrop(player, world);
    }

    // Item drop probability (health pack or ammo crate)
    final rand = math.Random().nextDouble();
    if (rand < 0.35) {
      final itemType = rand < 0.18 ? ItemType.healthPack : ItemType.ammoCrate;
      world.items.add(Item(
        id: 'drop_${DateTime.now().millisecondsSinceEpoch}',
        type: itemType,
        position: Vector3D.copy(zombie.position),
        quantity: itemType == ItemType.healthPack ? 1 : 2,
      ));
    }
  }

  void _triggerAirDrop(Player player, MapWorld world) {
    airDropTriggered = true;

    // Drop AK-47 crate near player (e.g. 10-15 units away)
    final randAngle = math.Random().nextDouble() * math.pi * 2;
    final dropDist = 12.0;
    airDropPosition = Vector3D(
      player.position.x + math.cos(randAngle) * dropDist,
      0.0,
      player.position.z + math.sin(randAngle) * dropDist,
    );

    world.items.add(Item(
      id: 'air_drop_ak47',
      type: ItemType.airDropAK47,
      position: Vector3D.copy(airDropPosition!),
      quantity: 1,
      pickupRadius: 2.5,
    ));

    airDropNotificationMessage = 'AIR-DROP INBOUND! AK-47 SUPPLIES DROPPED NEARBY!';
    notificationTimer = 5.0;
  }

  void _startNextWave(Player player) {
    waveNumber++;
    zombiesKilledInWave = 0;
    zombiesSpawnedInWave = 0;

    // Wave reward
    player.health.heal(25.0);

    airDropNotificationMessage = 'WAVE $waveNumber STARTED! ZOMBIES APPROACHING!';
    notificationTimer = 3.5;
  }

  void recycleDeadZombies() {
    activeZombies.removeWhere((z) {
      if (z.state == ZombieState.dead) {
        zombiePool.add(z);
        return true;
      }
      return false;
    });
  }
}
