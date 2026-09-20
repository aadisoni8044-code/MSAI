import 'dart:math' as math;
import 'vector3d.dart';
import 'health.dart';
import 'weapon.dart';
import 'item.dart';

class Player {
  Vector3D position;
  double yaw; // Rotation in radians around Y-axis (facing angle)
  double pitch; // Vertical look angle in radians

  final Health health;
  final List<Weapon> weapons;
  int activeWeaponIndex = 0;

  bool isSprinting = false;
  bool isAttacking = false;
  double attackAnimTimer = 0.0;
  double walkAnimPhase = 0.0;

  // Inventory stats
  int healthKits = 2;
  int killCount = 0;

  // Physical radius for collision
  final double radius = 0.8;
  final double height = 1.8;

  Player({
    Vector3D? initialPosition,
    this.yaw = 0.0,
    this.pitch = 0.0,
  })  : position = initialPosition ?? Vector3D(0.0, 0.0, 0.0),
        health = Health(maxHealth: 100.0),
        weapons = [
          Weapon.sword(),
          Weapon.pistol(),
        ];

  Weapon get activeWeapon => weapons[activeWeaponIndex];

  bool get hasAK47 => weapons.any((w) => w.type == WeaponType.ak47);

  void unlockAK47() {
    if (!hasAK47) {
      weapons.add(Weapon.ak47());
      activeWeaponIndex = weapons.length - 1; // Auto switch to newly unlocked AK-47
    }
  }

  void switchWeapon() {
    activeWeaponIndex = (activeWeaponIndex + 1) % weapons.length;
  }

  void update(double dt) {
    activeWeapon.update(dt);

    if (isAttacking) {
      attackAnimTimer -= dt;
      if (attackAnimTimer <= 0.0) {
        isAttacking = false;
      }
    }
  }

  void move(double moveX, double moveZ, double dt) {
    if (health.isDead) return;

    final moveLen = math.sqrt(moveX * moveX + moveZ * moveZ);
    if (moveLen < 0.01) return;

    final normX = moveX / moveLen;
    final normZ = moveZ / moveLen;

    final speed = isSprinting ? 9.5 : 5.5;

    // Movement relative to current yaw (camera facing direction)
    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);

    final dirX = normX * cosY + normZ * sinY;
    final dirZ = -normX * sinY + normZ * cosY;

    position.x += dirX * speed * dt;
    position.z += dirZ * speed * dt;

    walkAnimPhase += dt * (isSprinting ? 14.0 : 8.0);
  }

  void rotateLook(double deltaYaw, double deltaPitch) {
    yaw += deltaYaw;
    pitch = (pitch + deltaPitch).clamp(-math.pi / 4, math.pi / 4);
  }

  bool triggerAttack() {
    if (health.isDead) return false;
    if (activeWeapon.tryFire()) {
      isAttacking = true;
      attackAnimTimer = 0.25;
      return true;
    }
    return false;
  }

  bool triggerReload() {
    if (health.isDead) return false;
    return activeWeapon.startReload();
  }

  bool useHealthPack() {
    if (health.isDead || healthKits <= 0 || health.current >= health.maxHealth) {
      return false;
    }
    healthKits--;
    health.heal(40.0);
    return true;
  }

  void pickupItem(Item item) {
    switch (item.type) {
      case ItemType.healthPack:
        healthKits += item.quantity;
        break;
      case ItemType.ammoCrate:
        for (var w in weapons) {
          if (!w.isMelee) {
            w.addReserveAmmo(30 * item.quantity);
          }
        }
        break;
      case ItemType.airDropAK47:
        unlockAK47();
        for (var w in weapons) {
          if (w.type == WeaponType.ak47) {
            w.addReserveAmmo(60);
          }
        }
        break;
    }
  }
}
