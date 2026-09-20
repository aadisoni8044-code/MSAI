import 'package:flutter_test/flutter_test.dart';
import 'package:zombie_survival_3d/models/vector3d.dart';
import 'package:zombie_survival_3d/models/health.dart';
import 'package:zombie_survival_3d/models/weapon.dart';
import 'package:zombie_survival_3d/models/player.dart';
import 'package:zombie_survival_3d/models/zombie.dart';
import 'package:zombie_survival_3d/models/item.dart';
import 'package:zombie_survival_3d/systems/wave_manager.dart';
import 'package:zombie_survival_3d/systems/zombie_ai.dart';
import 'package:zombie_survival_3d/systems/map_world.dart';
import 'package:zombie_survival_3d/game/game_controller.dart';

void main() {
  group('3D Math Engine Tests', () {
    test('Vector3D operations', () {
      final v1 = Vector3D(1.0, 2.0, 3.0);
      final v2 = Vector3D(4.0, 5.0, 6.0);

      final sum = v1 + v2;
      expect(sum.x, equals(5.0));
      expect(sum.y, equals(7.0));
      expect(sum.z, equals(9.0));

      final dist = v1.distanceTo(v2);
      expect(dist, greaterThan(5.0));

      final rot = v1.rotateY(3.14159 / 2);
      expect(rot.z, closeTo(-1.0, 0.1));
    });
  });

  group('Health System Tests', () {
    test('Health damage and heal mechanics', () {
      final hp = Health(maxHealth: 100.0);
      expect(hp.current, equals(100.0));
      expect(hp.isAlive, isTrue);

      hp.takeDamage(30.0);
      expect(hp.current, equals(70.0));

      hp.heal(20.0);
      expect(hp.current, equals(90.0));

      hp.takeDamage(100.0);
      expect(hp.current, equals(0.0));
      expect(hp.isDead, isTrue);
    });
  });

  group('Weapon & Ammo Mechanics Tests', () {
    test('Sword basic attack defeats basic zombie in 1 hit', () {
      final sword = Weapon.sword();
      final zombie = Zombie(id: 'z1', position: Vector3D.zero(), type: ZombieType.normal);

      expect(sword.damage, equals(100.0));
      expect(zombie.health.current, equals(80.0));

      zombie.takeDamage(sword.damage);
      expect(zombie.health.isDead, isTrue);
    });

    test('Pistol reloading and ammo accounting', () {
      final pistol = Weapon.pistol();
      expect(pistol.ammoInClip, equals(12));
      expect(pistol.reserveAmmo, equals(48));

      // Fire clip
      for (int i = 0; i < 12; i++) {
        pistol.tryFire();
        pistol.cooldownTimer = 0.0;
      }
      expect(pistol.ammoInClip, equals(0));

      // Reload
      pistol.startReload();
      pistol.update(1.6); // Finish reload timer (1.5s)

      expect(pistol.ammoInClip, equals(12));
      expect(pistol.reserveAmmo, equals(36));
    });
  });

  group('Player & Inventory Tests', () {
    test('Player weapon switching and health pack usage', () {
      final player = Player();
      expect(player.activeWeapon.type, equals(WeaponType.sword));

      player.switchWeapon();
      expect(player.activeWeapon.type, equals(WeaponType.pistol));

      player.health.takeDamage(50.0);
      expect(player.health.current, equals(50.0));

      final used = player.useHealthPack();
      expect(used, isTrue);
      expect(player.health.current, equals(90.0));
      expect(player.healthKits, equals(1));
    });

    test('Player collecting AK-47 air-drop item unlocks firearm', () {
      final player = Player();
      expect(player.hasAK47, isFalse);

      final airDropItem = Item(
        id: 'air_drop',
        type: ItemType.airDropAK47,
        position: Vector3D.zero(),
      );

      player.pickupItem(airDropItem);
      expect(player.hasAK47, isTrue);
      expect(player.activeWeapon.type, equals(WeaponType.ak47));
      expect(player.activeWeapon.reserveAmmo, greaterThan(100));
    });
  });

  group('Wave Manager & 10 Kills AK-47 Air-Drop Event Tests', () {
    test('10 kills triggers AK-47 Air-Drop event', () {
      final player = Player();
      final world = MapWorld();
      final waveMgr = WaveManager();

      expect(waveMgr.airDropTriggered, isFalse);

      final dummyZombie = Zombie(id: 'test', position: Vector3D(10, 0, 10));

      // Simulate 10 kills
      for (int i = 0; i < 10; i++) {
        waveMgr.onZombieDefeated(dummyZombie, player, world);
      }

      expect(waveMgr.totalKills, equals(10));
      expect(waveMgr.airDropTriggered, isTrue);
      expect(waveMgr.airDropPosition, isNotNull);
      expect(world.items.any((item) => item.type == ItemType.airDropAK47), isTrue);
    });

    test('Wave progression scales zombie counts', () {
      final waveMgr = WaveManager();
      expect(waveMgr.waveNumber, equals(1));
      expect(waveMgr.totalZombiesForWave, equals(7));
    });
  });

  group('Zombie AI Tests', () {
    test('Zombie AI chases player when within detection radius', () {
      final ai = ZombieAI();
      final player = Player(initialPosition: Vector3D(0, 0, 10));
      final zombie = Zombie(id: 'z1', position: Vector3D(0, 0, 0));
      final world = MapWorld();

      expect(zombie.state, equals(ZombieState.idle));

      ai.updateZombie(zombie, player, world, 0.1);

      expect(zombie.state, equals(ZombieState.chasing));
      expect(zombie.position.z, greaterThan(0.0));
    });
  });

  group('Game Controller System Integration Test', () {
    test('Game Controller initializes and executes loop tick', () {
      final controller = GameController();
      expect(controller.isPaused, isFalse);
      expect(controller.isGameOver, isFalse);

      controller.update(0.016);
      expect(controller.player.health.isAlive, isTrue);
    });
  });
}
