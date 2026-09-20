import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group('ZombieGameEngine Strict Wave & Spawn Invariant Tests', () {
    late ZombieGameEngine engine;

    setUp(() {
      engine = ZombieGameEngine();
      engine.updateScreenSize(390, 844);
    });

    test('Engine starts Wave 1 with totalZombiesForWave=10 and zombiesSpawned=0', () {
      expect(engine.currentWave, equals(1));
      expect(engine.totalZombiesForWave, equals(10));
      expect(engine.zombiesSpawned, equals(0));
      expect(engine.zombiesRemainingInWave, equals(10));
    });

    test('Engine spawns zombies up to totalZombiesForWave and NEVER exceeds it', () {
      engine.startPreparationCountdown();
      for (int i = 0; i < 210; i++) {
        engine.tick(0.05);
      }
      expect(engine.gameState, equals(ZombieGameState.playing));

      // Tick many frames to allow full spawning
      for (int i = 0; i < 500; i++) {
        engine.tick(0.05);
      }

      expect(engine.zombiesSpawned, lessThanOrEqualTo(engine.totalZombiesForWave));
      expect(engine.zombiesSpawned, equals(10));
    });

    test('Wave 10 clear transitions to ZombieGameState.completed', () {
      engine.gameState = ZombieGameState.playing;
      engine.currentWave = 10;
      engine.totalZombiesForWave = 100;
      engine.zombiesSpawned = 100;
      engine.zombiesDefeatedInWave = 100;
      engine.activeZombies.clear();

      engine.tick(0.05);

      expect(engine.gameState, equals(ZombieGameState.completed));
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
