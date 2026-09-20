import 'dart:math' as math;
import '../models/vector3d.dart';
import '../models/player.dart';
import '../models/zombie.dart';
import 'map_world.dart';

class ZombieAI {
  final double detectionRadius;

  ZombieAI({this.detectionRadius = 35.0});

  void updateZombie(Zombie zombie, Player player, MapWorld world, double dt) {
    if (!zombie.isAlive) return;

    final distToPlayer = zombie.position.distanceToXZ(player.position);

    // AI State determination
    if (distToPlayer <= zombie.attackRange) {
      zombie.state = ZombieState.attacking;
      zombie.tryAttack(player);
    } else if (distToPlayer <= detectionRadius) {
      zombie.state = ZombieState.chasing;

      // Calculate direction to player
      final dx = player.position.x - zombie.position.x;
      final dz = player.position.z - zombie.position.z;

      final targetYaw = math.atan2(dx, dz);
      // Smoothly rotate towards player
      zombie.yaw = targetYaw;

      // Move towards player
      final moveX = math.sin(zombie.yaw) * zombie.speed * dt;
      final moveZ = math.cos(zombie.yaw) * zombie.speed * dt;

      final nextPos = Vector3D(
        zombie.position.x + moveX,
        zombie.position.y,
        zombie.position.z + moveZ,
      );

      // Check collision with map environment buildings/obstacles
      if (!world.checkObstacleCollision(nextPos, zombie.radius)) {
        zombie.position = nextPos;
      } else {
        // Simple slide around obstacle
        final nextPosX = Vector3D(zombie.position.x + moveX, zombie.position.y, zombie.position.z);
        final nextPosZ = Vector3D(zombie.position.x, zombie.position.y, zombie.position.z + moveZ);

        if (!world.checkObstacleCollision(nextPosX, zombie.radius)) {
          zombie.position = nextPosX;
        } else if (!world.checkObstacleCollision(nextPosZ, zombie.radius)) {
          zombie.position = nextPosZ;
        }
      }
    } else {
      zombie.state = ZombieState.idle;
    }

    zombie.update(dt, player);
  }
}
