import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/level_objects.dart';

class CollisionResult {
  final bool isGrounded;
  final bool hitWall;

  const CollisionResult({required this.isGrounded, required this.hitWall});
}

class CollisionSystem {
  static CollisionResult handlePlayerPlatforms(Player player, List<PlatformBlock> platforms, double dt) {
    bool isGrounded = false;
    bool hitWall = false;

    // Save previous position to check collision directions
    final double prevBottom = player.position.dy + player.size.height - (player.velocity.dy * dt);
    final Rect playerRect = player.bounds;

    for (final platform in platforms) {
      if (playerRect.overlaps(platform.bounds)) {
        // Checking if player was above the platform top surface before movement
        if (prevBottom <= platform.bounds.top + 10 && player.velocity.dy >= 0) {
          // Landing on platform top
          player.position = Offset(player.position.dx, platform.bounds.top - player.size.height);
          player.velocity = Offset(player.velocity.dx, 0);
          isGrounded = true;
        } else if (player.position.dy >= platform.bounds.bottom - 10 && player.velocity.dy < 0) {
          // Hitting platform bottom
          player.position = Offset(player.position.dx, platform.bounds.bottom);
          player.velocity = Offset(player.velocity.dx, 0);
        } else {
          // Side collision
          if (player.velocity.dx > 0) {
            player.position = Offset(platform.bounds.left - player.size.width, player.position.dy);
            hitWall = true;
          } else if (player.velocity.dx < 0) {
            player.position = Offset(platform.bounds.right, player.position.dy);
            hitWall = true;
          }
        }
      }
    }

    player.isGrounded = isGrounded;
    return CollisionResult(isGrounded: isGrounded, hitWall: hitWall);
  }

  static void handleCollectibles(Player player, List<Collectible> collectibles, VoidCallback onCollect) {
    final Rect playerRect = player.bounds;
    for (final item in collectibles) {
      if (!item.isCollected && playerRect.overlaps(item.bounds)) {
        item.isCollected = true;
        onCollect();
      }
    }
  }

  static void handleCheckpoints(Player player, List<Checkpoint> checkpoints, Function(Checkpoint) onActivate) {
    final Rect playerRect = player.bounds;
    for (final cp in checkpoints) {
      if (!cp.isActivated && playerRect.overlaps(cp.bounds)) {
        cp.isActivated = true;
        onActivate(cp);
      }
    }
  }

  static bool handleExitPortal(Player player, ExitPortal portal) {
    return player.bounds.overlaps(portal.bounds);
  }

  static void handleAttacks(Player player, List<Enemy> enemies, Function(Enemy) onEnemyHit) {
    if (!player.isAttacking) return;
    final Rect attackRect = player.attackBounds;

    for (final enemy in enemies) {
      if (enemy.isAlive && attackRect.overlaps(enemy.bounds)) {
        onEnemyHit(enemy);
      }
    }
  }

  static void handlePlayerEnemyCollisions(Player player, List<Enemy> enemies, Function(Enemy) onPlayerHurt) {
    if (player.isInvulnerable || player.state == PlayerState.dead) return;
    final Rect playerRect = player.bounds;

    for (final enemy in enemies) {
      if (enemy.isAlive && playerRect.overlaps(enemy.bounds)) {
        onPlayerHurt(enemy);
        break;
      }
    }
  }
}
