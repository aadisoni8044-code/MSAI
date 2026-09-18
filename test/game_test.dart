import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_adventure/game/player.dart';
import 'package:forest_adventure/game/enemy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Player Mechanics', () {
    test('Player initializes with 3 health hearts', () {
      final player = PlayerCharacter(position: Vector2(100, 100));
      expect(player.health, equals(3));
      expect(player.isInvincible, isFalse);
    });

    test('Player takes damage and becomes invincible', () {
      final player = PlayerCharacter(position: Vector2(100, 100));
      player.takeDamage();
      expect(player.health, equals(2));
      expect(player.isInvincible, isTrue);

      // Subsequent damage during invincibility is ignored
      player.takeDamage();
      expect(player.health, equals(2));
    });

    test('Player respawn resets health', () {
      final player = PlayerCharacter(position: Vector2(100, 100));
      player.takeDamage();
      expect(player.health, equals(2));

      player.respawnAt(Vector2(50, 50));
      expect(player.health, equals(3));
      expect(player.position, equals(Vector2(50, 50)));
    });
  });

  group('Forest Enemy AI', () {
    test('Enemy moves within bounds and flips direction', () {
      final enemy = ForestEnemy(
        position: Vector2(100, 100),
        leftBound: 80,
        rightBound: 120,
      );

      expect(enemy.movingRight, isTrue);

      // Update moving right past bound
      enemy.update(1.0); // 60px move -> position.x becomes 120
      expect(enemy.position.x, equals(120));
      expect(enemy.movingRight, isFalse);
    });
  });
}
