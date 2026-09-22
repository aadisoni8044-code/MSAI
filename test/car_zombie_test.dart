import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/car_zombie_game_state.dart';
import 'package:enchanted_forest_adventure/game/car_zombie_game_engine.dart';
import 'package:enchanted_forest_adventure/ui/car_zombie_game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Car Zombie Chase Models Tests', () {
    test('CarZombieVehicleState initializes with default values', () {
      final car = CarZombieVehicleState();
      expect(car.currentHp, equals(100.0));
      expect(car.maxHp, equals(100.0));
      expect(car.isBoosting, isFalse);
    });

    test('CarZombieEnemy factory creates normal, fast, heavy, and large zombies', () {
      final normal = CarZombieEnemy.create(id: 'z1', type: CarZombieEnemyType.normal, startX: 0, startY: 0);
      final fast = CarZombieEnemy.create(id: 'z2', type: CarZombieEnemyType.fast, startX: 0, startY: 0);
      final heavy = CarZombieEnemy.create(id: 'z3', type: CarZombieEnemyType.heavy, startX: 0, startY: 0);
      final large = CarZombieEnemy.create(id: 'z4', type: CarZombieEnemyType.large, startX: 0, startY: 0);

      expect(normal.type, equals(CarZombieEnemyType.normal));
      expect(fast.speed, greaterThan(normal.speed));
      expect(heavy.maxHealth, greaterThan(normal.maxHealth));
      expect(large.maxHealth, greaterThan(heavy.maxHealth));
    });
  });

  group('CarZombieGameEngine Tests', () {
    late CarZombieGameEngine engine;

    setUp(() {
      engine = CarZombieGameEngine();
      engine.updateScreenSize(844, 390);
    });

    test('Engine drives car automatically and increments distance', () {
      final initialX = engine.car.x;
      engine.tick(0.1);

      expect(engine.car.x, greaterThan(initialX));
      expect(engine.distanceMeters, greaterThan(0.0));
    });

    test('Shooting spawns backwards bullet and consumes clip ammo', () {
      final initialClip = engine.currentClip;
      engine.shoot();

      expect(engine.currentClip, equals(initialClip - 1));
      expect(engine.bullets, isNotEmpty);
      expect(engine.bullets.first.vx, lessThan(0));
    });

    test('Boost increases speed and sets boost timer', () {
      engine.triggerBoost();
      expect(engine.car.isBoosting, isTrue);
      expect(engine.car.boostTimer, greaterThan(0));
    });

    test('Zombie latching on car damages vehicle HP', () {
      final zombie = CarZombieEnemy.create(id: 'z1', type: CarZombieEnemyType.normal, startX: engine.car.x - 10, startY: engine.car.y);
      zombie.isLatchedToCar = true;
      engine.zombies.add(zombie);

      final initialHp = engine.car.currentHp;
      engine.tick(1.0); // Ticks 1 second -> triggers attack damage

      expect(engine.car.currentHp, lessThan(initialHp));
    });

    test('Vehicle HP <= 0 triggers Game Over status', () {
      engine.car.currentHp = 1.0;
      final zombie = CarZombieEnemy.create(id: 'z1', type: CarZombieEnemyType.large, startX: engine.car.x - 10, startY: engine.car.y);
      zombie.isLatchedToCar = true;
      engine.zombies.add(zombie);

      engine.tick(1.0);

      expect(engine.status, equals(CarZombieGameStatus.gameOver));
    });
  });

  group('Car Zombie UI Widget Tests', () {
    testWidgets('CarZombieGameScreen renders canvas and controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CarZombieGameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CarZombieGameScreen), findsOneWidget);
      expect(find.text('FIRE'), findsOneWidget);
      expect(find.text('BOOST'), findsOneWidget);
      expect(find.text('RELOAD'), findsOneWidget);
    });
  });
}
