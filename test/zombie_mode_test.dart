import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/zombie_entity.dart';
import 'package:enchanted_forest_adventure/models/zombie_mode_data.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/game/zombie_game_engine.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';
import 'package:enchanted_forest_adventure/ui/zombie_intro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ZombieProgressController.instance.init();
    await ZombieProgressController.instance.resetProgress();
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

  group('ZombieModeData WaveConfig Progression Tests', () {
    test('Wave 1 has exactly 10 weak zombies', () {
      final w1 = ZombieModeData.getWaveConfig(1);
      expect(w1.totalZombies, equals(10));
      expect(w1.largeCount, equals(0));
    });

    test('Wave 2 has exactly 20 zombies', () {
      final w2 = ZombieModeData.getWaveConfig(2);
      expect(w2.totalZombies, equals(20));
      expect(w2.largeCount, equals(0));
    });

    test('Wave 3 has 30 zombies', () {
      final w3 = ZombieModeData.getWaveConfig(3);
      expect(w3.totalZombies, equals(30));
    });

    test('Wave 4 has 40 zombies and introduces Large Zombies', () {
      final w4 = ZombieModeData.getWaveConfig(4);
      expect(w4.totalZombies, equals(40));
      expect(w4.largeCount, equals(2));
    });

    test('Wave 5 has 50 zombies', () {
      final w5 = ZombieModeData.getWaveConfig(5);
      expect(w5.totalZombies, equals(50));
    });
  });

  group('ZombieProgressController & Weapon Selection Tests', () {
    test('Initial progress starts at wave 0 and basic weapon', () {
      final controller = ZombieProgressController.instance;
      expect(controller.highestWaveCompleted, equals(0));
      expect(controller.totalZombiesDefeated, equals(0));
      expect(controller.unlockedWeapons, contains('basic'));
      expect(controller.selectedWeapon, equals('basic'));
    });

    test('Completing wave 2 unlocks AK-47', () async {
      final controller = ZombieProgressController.instance;
      await controller.completeWave(2);
      expect(controller.unlockedWeapons, contains('ak47'));
    });

    test('Defeating 50 zombies triggers milestone flag and AK-47 unlock', () async {
      final controller = ZombieProgressController.instance;
      await controller.addZombiesDefeated(50);
      expect(controller.totalZombiesDefeated, equals(50));
      expect(controller.unlockedWeapons, contains('ak47'));
    });
  });

  group('ZombieGameEngine Logic & Countdown Tests', () {
    late ZombieGameEngine engine;

    setUp(() {
      engine = ZombieGameEngine();
      engine.updateScreenSize(390, 844);
    });

    test('Engine starts in weaponSelect state', () {
      expect(engine.gameState, equals(ZombieGameState.weaponSelect));
      expect(engine.currentWave, equals(1));
      expect(engine.zombiesRemainingInWave, equals(10));
    });

    test('Starting preparation countdown sets 10s timer and allows movement', () {
      engine.startPreparationCountdown();
      expect(engine.gameState, equals(ZombieGameState.preparingWave));
      expect(engine.countdownTimer, equals(10.0));

      // Tick 100 x 0.05 = 5 seconds
      for (int i = 0; i < 100; i++) {
        engine.tick(0.05);
      }
      expect(engine.countdownTimer, closeTo(5.0, 0.2));
      expect(engine.gameState, equals(ZombieGameState.preparingWave));
    });

    test('Countdown finishing transitions to playing state', () {
      engine.startPreparationCountdown();
      // Tick 210 x 0.05 = 10.5 seconds
      for (int i = 0; i < 210; i++) {
        engine.tick(0.05);
      }
      expect(engine.gameState, equals(ZombieGameState.playing));
    });
  });

  group('Zombie Mode UI Widget Tests', () {
    testWidgets('MainMenuScreen renders ZOMBIE MODE button with stats badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );

      expect(find.text('ZOMBIE MODE'), findsOneWidget);
      expect(find.textContaining('Highest Wave:'), findsOneWidget);
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
