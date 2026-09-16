import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forestbound/models/player.dart';
import 'package:forestbound/models/enemy.dart';
import 'package:forestbound/models/level_objects.dart';
import 'package:forestbound/services/game_service.dart';
import 'package:forestbound/game/level_data.dart';
import 'package:forestbound/game/collision_system.dart';
import 'package:forestbound/main.dart';

void main() {
  group('Player Mechanics & Physics Tests', () {
    test('Player initializes with 3 health and correct defaults', () {
      final player = Player(position: const Offset(100, 100));
      expect(player.currentHealth, equals(3));
      expect(player.maxHealth, equals(3));
      expect(player.state, equals(PlayerState.idle));
      expect(player.isGrounded, isFalse);
    });

    test('Player horizontal movement updates velocity and direction', () {
      final player = Player(position: const Offset(100, 100));
      player.isGrounded = true;

      player.moveRight();
      expect(player.velocity.dx, greaterThan(0));
      expect(player.isFacingRight, isTrue);

      player.moveLeft();
      expect(player.velocity.dx, lessThan(0));
      expect(player.isFacingRight, isFalse);

      player.stopHorizontal();
      expect(player.velocity.dx, equals(0));
    });

    test('Player jump works when grounded', () {
      final player = Player(position: const Offset(100, 100));
      player.isGrounded = true;

      final didJump = player.jump();
      expect(didJump, isTrue);
      expect(player.velocity.dy, lessThan(0));
      expect(player.isGrounded, isFalse);
      expect(player.state, equals(PlayerState.jumping));

      // Second jump while mid-air should fail
      final secondJump = player.jump();
      expect(secondJump, isFalse);
    });

    test('Player takes damage and loses health', () {
      final player = Player(position: const Offset(100, 100));
      final tookDamage = player.takeDamage(1, const Offset(-100, -100));

      expect(tookDamage, isTrue);
      expect(player.currentHealth, equals(2));
      expect(player.isInvulnerable, isTrue);

      // Subsequent damage during invulnerability should be ignored
      final tookDamageAgain = player.takeDamage(1, Offset.zero);
      expect(tookDamageAgain, isFalse);
      expect(player.currentHealth, equals(2));
    });

    test('Player respawn resets health and position', () {
      final player = Player(position: const Offset(100, 100));
      player.takeDamage(3, Offset.zero);
      expect(player.currentHealth, equals(0));

      player.respawnAtCheckpoint(const Offset(200, 200));
      expect(player.currentHealth, equals(3));
      expect(player.position, equals(const Offset(200, 200)));
      expect(player.state, equals(PlayerState.idle));
    });
  });

  group('Enemy AI & Collision Tests', () {
    test('Enemy patrols within bounds', () {
      final enemy = Enemy(
        id: 'e1',
        position: const Offset(100, 100),
        patrolDistance: 100,
        moveSpeed: 50,
      );

      // Move forward
      enemy.update(1.0);
      expect(enemy.position.dx, equals(150));
      expect(enemy.isFacingRight, isTrue);

      // Move past maxX
      enemy.update(1.5);
      expect(enemy.isFacingRight, isFalse);
    });

    test('Enemy takes damage and dies when health depleted', () {
      final enemy = Enemy(
        id: 'e1',
        position: const Offset(100, 100),
        patrolDistance: 100,
        maxHealth: 1,
      );

      final hit = enemy.takeDamage(1);
      expect(hit, isTrue);
      expect(enemy.isAlive, isFalse);
    });
  });

  group('Collision System Tests', () {
    test('Player lands on top of platform', () {
      final player = Player(position: const Offset(100, 80));
      player.velocity = const Offset(0, 100);

      final platform = PlatformBlock(bounds: const Rect.fromLTWH(80, 100, 100, 20));
      final result = CollisionSystem.handlePlayerPlatforms(player, [platform], 0.016);

      expect(result.isGrounded, isTrue);
      expect(player.position.dy, equals(platform.bounds.top - player.size.height));
    });

    test('Player collects items upon overlapping', () {
      final player = Player(position: const Offset(100, 100));
      final collectible = Collectible(id: 'c1', position: const Offset(100, 100));

      bool collected = false;
      CollisionSystem.handleCollectibles(player, [collectible], () {
        collected = true;
      });

      expect(collectible.isCollected, isTrue);
      expect(collected, isTrue);
    });
  });

  group('Level Design & Game Service State Tests', () {
    test('Level 1 data generates valid entities and bounds', () {
      final level = LevelData.level1();
      expect(level.levelNumber, equals(1));
      expect(level.platforms, isNotEmpty);
      expect(level.collectibles, isNotEmpty);
      expect(level.enemies, isNotEmpty);
      expect(level.checkpoints, isNotEmpty);
    });

    test('GameService initializes and changes states correctly', () {
      final service = GameService();
      service.initializeGame(const Size(800, 600));

      expect(service.state, equals(GameState.startMenu));

      service.startGame();
      expect(service.state, equals(GameState.playing));

      service.pauseGame();
      expect(service.state, equals(GameState.paused));

      service.resumeGame();
      expect(service.state, equals(GameState.playing));
    });
  });

  group('Flutter Widget Smoke Test', () {
    testWidgets('Renders Forestbound app and starts game', (WidgetTester tester) async {
      await tester.pumpWidget(const ForestboundApp());
      expect(find.text('FORESTBOUND'), findsOneWidget);
      expect(find.text('START GAME'), findsOneWidget);

      await tester.tap(find.text('START GAME'));
      await tester.pump();

      // Should now render the HUD components (e.g. PTS counter)
      expect(find.textContaining('PTS:'), findsOneWidget);
    });
  });
}
