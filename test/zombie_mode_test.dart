import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/zombie_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_mode_data.dart';
import 'package:enchanted_forest_adventure/game/zombie_game_engine.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';
import 'package:enchanted_forest_adventure/ui/zombie_intro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ZombieEntity Tests', () {
    test('Normal Zombie has standard stats', () {
      final z = ZombieEntity(id: 'z1', zombieType: ZombieType.normal, x: 100, y: 500);
      expect(z.zombieType, equals(ZombieType.normal));
      expect(z.health, equals(2));
      expect(z.damage, equals(1));
    });

    test('Fast Zombie has higher speed and lower health', () {
      final z = ZombieEntity(id: 'z2', zombieType: ZombieType.fast, x: 100, y: 500);
      expect(z.zombieType, equals(ZombieType.fast));
      expect(z.speed, equals(3.2));
      expect(z.health, equals(1));
    });

    test('Large Zombie has high health and strong damage', () {
      final z = ZombieEntity(id: 'z3', zombieType: ZombieType.large, x: 100, y: 500);
      expect(z.zombieType, equals(ZombieType.large));
      expect(z.health, equals(5));
      expect(z.damage, equals(2));
      expect(z.width, equals(58));
      expect(z.height, equals(64));
    });
  });

  group('ZombieModeData WaveConfig Tests', () {
    test('Wave configs scale difficulty correctly', () {
      final w1 = ZombieModeData.getWaveConfig(1);
      expect(w1.normalCount, equals(6));
      expect(w1.largeCount, equals(0));

      final w4 = ZombieModeData.getWaveConfig(4);
      expect(w4.largeCount, equals(1));

      final w10 = ZombieModeData.getWaveConfig(10);
      expect(w10.totalZombies, greaterThan(30));
    });
  });

  group('ZombieGameEngine Logic Tests', () {
    late ZombieGameEngine engine;

    setUp(() {
      engine = ZombieGameEngine();
      engine.updateScreenSize(390, 844);
    });

    test('Engine starts at Wave 1 with correct zombie remaining count', () {
      expect(engine.currentWave, equals(1));
      expect(engine.zombiesRemainingInWave, equals(6));
    });

    test('Engine ticks spawn zombies outside screen', () {
      for (int i = 0; i < 100; i++) {
        engine.tick(0.016);
      }
      expect(engine.activeZombies, isNotEmpty);
    });

    test('Player attack damages active zombies', () {
      engine.activeZombies.add(ZombieEntity(
        id: 'z_test',
        zombieType: ZombieType.normal,
        x: engine.player.x + 10,
        y: engine.player.y,
      ));

      final initialHealth = engine.activeZombies.first.health;
      engine.attack();
      expect(engine.activeZombies.first.health, lessThan(initialHealth));
    });
  });

  group('Zombie Mode UI Widget Tests', () {
    testWidgets('MainMenuScreen renders ZOMBIE MODE button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );

      expect(find.text('ZOMBIE MODE'), findsOneWidget);
      expect(find.text('START GAME'), findsOneWidget);
    });

    testWidgets('Tapping ZOMBIE MODE button navigates to ZombieIntroScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );

      await tester.tap(find.text('ZOMBIE MODE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ZombieIntroScreen), findsOneWidget);
      expect(find.text('SKIP'), findsOneWidget);
    });
  });
}
