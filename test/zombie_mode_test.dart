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

  group('ZombieEntity Health Tests', () {
    test('Normal and Fast Zombies have 1 health and die in a single hit', () {
      final normalZ = ZombieEntity(id: 'zn', zombieType: ZombieType.normal, x: 100, y: 500);
      expect(normalZ.health, equals(1));
      normalZ.takeDamage(1);
      expect(normalZ.health, equals(0));
      expect(normalZ.state, equals(ZombieState.dying));

      final fastZ = ZombieEntity(id: 'zf', zombieType: ZombieType.fast, x: 100, y: 500);
      expect(fastZ.health, equals(1));
      fastZ.takeDamage(1);
      expect(fastZ.health, equals(0));
      expect(fastZ.state, equals(ZombieState.dying));
    });

    test('Large Zombies have 5 health', () {
      final largeZ = ZombieEntity(id: 'zl', zombieType: ZombieType.large, x: 100, y: 500);
      expect(largeZ.health, equals(5));
    });
  });

  group('ZombieMode Exact Wave Config Tests', () {
    test('Wave 1 to Wave 10 have exact required counts', () {
      expect(ZombieModeData.getWaveConfig(1).totalZombies, equals(10));
      expect(ZombieModeData.getWaveConfig(2).totalZombies, equals(20));
      expect(ZombieModeData.getWaveConfig(3).totalZombies, equals(30));
      expect(ZombieModeData.getWaveConfig(4).totalZombies, equals(40));
      expect(ZombieModeData.getWaveConfig(5).totalZombies, equals(50));
      expect(ZombieModeData.getWaveConfig(6).totalZombies, equals(60));
      expect(ZombieModeData.getWaveConfig(7).totalZombies, equals(70));
      expect(ZombieModeData.getWaveConfig(8).totalZombies, equals(80));
      expect(ZombieModeData.getWaveConfig(9).totalZombies, equals(90));
      expect(ZombieModeData.getWaveConfig(10).totalZombies, equals(100));
    });
  });

  group('ZombieGameEngine Skydrop Weapon Drop Tests', () {
    late ZombieGameEngine engine;

    setUp(() {
      engine = ZombieGameEngine();
      engine.updateScreenSize(390, 844);
    });

    test('10 Zombie Milestone triggers AK-47 skydrop supply box', () {
      engine.gameState = ZombieGameState.playing;
      engine.totalZombiesKilledThisRun = 10;

      engine.tick(0.05);

      expect(engine.activeWeaponDrop, isNotNull);
      expect(engine.activeWeaponDrop!.weaponId, equals('ak47'));
      expect(ZombieProgressController.instance.has10MilestoneDropped, isTrue);
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
