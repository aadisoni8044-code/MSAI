import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/vector3d.dart';
import '../models/player.dart';
import '../models/zombie.dart';
import '../models/weapon.dart';
import '../models/bullet.dart';
import '../models/item.dart';
import '../systems/map_world.dart';
import '../systems/wave_manager.dart';
import '../systems/zombie_ai.dart';

class GameController extends ChangeNotifier {
  late Player player;
  late MapWorld world;
  late WaveManager waveManager;
  final ZombieAI zombieAI = ZombieAI();

  final List<Bullet> bullets = [];

  bool isPaused = false;
  bool isGameOver = false;

  // Settings
  double cameraSensitivity = 1.0;
  bool soundEffectsEnabled = true;
  bool musicEnabled = true;

  GameController() {
    initGame();
  }

  void initGame() {
    player = Player();
    world = MapWorld();
    waveManager = WaveManager();
    bullets.clear();
    isPaused = false;
    isGameOver = false;
    notifyListeners();
  }

  void restartGame() {
    initGame();
  }

  void togglePause() {
    isPaused = !isPaused;
    notifyListeners();
  }

  void update(double dt) {
    if (isPaused || isGameOver) return;

    // 1. Update Player
    player.update(dt);

    if (player.health.isDead) {
      isGameOver = true;
      notifyListeners();
      return;
    }

    // 2. Update Map World items
    world.update(dt);

    // 3. Update Bullets
    _updateBullets(dt);

    // 4. Update Wave Manager & Spawning
    waveManager.update(dt, player, world);

    // 5. Update Zombies & AI
    for (var zombie in waveManager.activeZombies) {
      zombieAI.updateZombie(zombie, player, world, dt);
    }

    // Clean up dead zombies to pool
    waveManager.recycleDeadZombies();

    // 6. Check Item Pickups
    _checkItemPickups();

    notifyListeners();
  }

  void _updateBullets(double dt) {
    for (int i = bullets.length - 1; i >= 0; i--) {
      final bullet = bullets[i];
      bullet.update(dt);

      if (!bullet.isAlive) {
        bullets.removeAt(i);
        continue;
      }

      // Check collision with obstacles
      if (world.checkObstacleCollision(bullet.position, 0.2)) {
        bullet.isAlive = false;
        bullets.removeAt(i);
        continue;
      }

      // Check collision with zombies
      for (var zombie in waveManager.activeZombies) {
        if (zombie.isAlive && bullet.checkHit(zombie.position, zombie.radius + 0.3)) {
          zombie.takeDamage(bullet.damage);
          bullet.isAlive = false;

          if (zombie.health.isDead) {
            waveManager.onZombieDefeated(zombie, player, world);
          }
          bullets.removeAt(i);
          break;
        }
      }
    }
  }

  void _checkItemPickups() {
    for (int i = world.items.length - 1; i >= 0; i--) {
      final item = world.items[i];
      if (item.canBePickedUpBy(player.position)) {
        item.isCollected = true;
        player.pickupItem(item);
        world.items.removeAt(i);
      }
    }
  }

  void handleJoystickMove(double joyX, double joyY, double dt) {
    if (isPaused || isGameOver) return;
    player.move(joyX, -joyY, dt);

    // Prevent walking into map obstacles
    if (world.checkObstacleCollision(player.position, player.radius)) {
      // Revert slight position step if stuck
      player.position.x -= math.sin(player.yaw) * 0.1;
      player.position.z -= math.cos(player.yaw) * 0.1;
    }
  }

  void handleCameraDrag(double deltaX, double deltaY) {
    if (isPaused || isGameOver) return;
    final yawSensitivity = 0.005 * cameraSensitivity;
    final pitchSensitivity = 0.005 * cameraSensitivity;

    player.rotateLook(deltaX * yawSensitivity, deltaY * pitchSensitivity);
  }

  void handleAttack() {
    if (isPaused || isGameOver) return;

    if (player.triggerAttack()) {
      final weapon = player.activeWeapon;

      if (weapon.isMelee) {
        _performMeleeAttack(weapon);
      } else {
        _fireFirearm(weapon);
      }
    }
  }

  void _performMeleeAttack(Weapon weapon) {
    // Sword slash - hit test zombies in front cone arc
    final forward = Vector3D(math.sin(player.yaw), 0, math.cos(player.yaw));

    for (var zombie in waveManager.activeZombies) {
      if (zombie.isAlive) {
        final dist = player.position.distanceToXZ(zombie.position);
        if (dist <= weapon.range) {
          final dirToZombie = (zombie.position - player.position).normalized();
          final dot = forward.dot(dirToZombie);

          // Within ~120 degrees arc in front
          if (dot > 0.3) {
            zombie.takeDamage(weapon.damage);
            if (zombie.health.isDead) {
              waveManager.onZombieDefeated(zombie, player, world);
            }
          }
        }
      }
    }
  }

  void _fireFirearm(Weapon weapon) {
    final muzzlePos = Vector3D(
      player.position.x + math.sin(player.yaw) * 0.8,
      player.position.y + 1.2,
      player.position.z + math.cos(player.yaw) * 0.8,
    );

    final dir = Vector3D(
      math.sin(player.yaw),
      math.tan(player.pitch),
      math.cos(player.yaw),
    ).normalized();

    bullets.add(Bullet(
      position: muzzlePos,
      direction: dir,
      damage: weapon.damage,
    ));
  }

  void handleSprint(bool sprinting) {
    player.isSprinting = sprinting;
  }

  void handleReload() {
    player.triggerReload();
  }

  void handleWeaponSwitch() {
    player.switchWeapon();
  }

  void handleUseHealthPack() {
    player.useHealthPack();
  }
}
