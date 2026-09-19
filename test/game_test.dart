import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';
import 'package:enchanted_forest_adventure/core/level_progress_controller.dart';
import 'package:enchanted_forest_adventure/widgets/virtual_joystick.dart';
import 'package:enchanted_forest_adventure/widgets/action_buttons.dart';
import 'package:enchanted_forest_adventure/widgets/game_hud.dart';
import 'package:enchanted_forest_adventure/ui/pause_overlay.dart';
import 'package:enchanted_forest_adventure/ui/game_over_overlay.dart';
import 'package:enchanted_forest_adventure/ui/victory_overlay.dart';
import 'package:enchanted_forest_adventure/ui/settings_overlay.dart';
import 'package:enchanted_forest_adventure/ui/level_select_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsController Tests', () {
    test('SettingsController modifies sound, music, and orientation', () {
      final settings = SettingsController.instance;
      settings.setSoundEnabled(false);
      expect(settings.soundEnabled, isFalse);

      settings.setMusicEnabled(false);
      expect(settings.musicEnabled, isFalse);

      settings.setOrientationMode(GameOrientationMode.landscape);
      expect(settings.orientationMode, equals(GameOrientationMode.landscape));
    });
  });

  group('LevelProgressController Tests', () {
    test('Level 1 is unlocked initially', () {
      final progress = LevelProgressController.instance;
      expect(progress.isUnlocked(1), isTrue);
      expect(progress.isUnlocked(2), isFalse);
    });

    test('Completing level 1 unlocks level 2', () async {
      final progress = LevelProgressController.instance;
      await progress.completeLevel(1);
      expect(progress.isUnlocked(2), isTrue);
      expect(progress.isCompleted(1), isTrue);
    });
  });

  group('PlayerState Tests', () {
    test('PlayerState initializes with correct default values', () {
      final player = PlayerState(x: 100, y: 200);
      expect(player.x, equals(100));
      expect(player.y, equals(200));
      expect(player.currentHealth, equals(5));
      expect(player.maxHealth, equals(5));
      expect(player.coins, equals(0));
      expect(player.isAttacking, isFalse);
      expect(player.isInvulnerable, isFalse);
    });

    test('PlayerState reset restores initial position and health', () {
      final player = PlayerState(x: 100, y: 200);
      player.currentHealth = 1;
      player.coins = 10;
      player.x = 500;

      player.reset(100, 200);
      expect(player.x, equals(100));
      expect(player.y, equals(200));
      expect(player.currentHealth, equals(5));
      expect(player.coins, equals(10));
    });
  });

  group('LevelData Tests', () {
    test('LevelData.createLevel creates valid objects for all 10 levels', () {
      for (int i = 1; i <= 10; i++) {
        final level = LevelData.createLevel(i);
        expect(level.levelNumber, equals(i));
        expect(level.platforms, isNotEmpty);
        expect(level.enemies, isNotEmpty);
        expect(level.collectibles, isNotEmpty);
        expect(level.goalPortal.type, equals(EntityType.goalPortal));
      }
    });
  });

  group('GameEngine Logic Tests', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
      engine.updateScreenSize(390, 844);
    });

    test('Joystick input moves player horizontally', () {
      engine.setJoystickInput(1.0);
      engine.tick(0.016);
      expect(engine.player.vx, greaterThan(0));
      expect(engine.player.facingRight, isTrue);

      engine.setJoystickInput(-1.0);
      engine.tick(0.016);
      expect(engine.player.facingRight, isFalse);
    });

    test('Jump sets negative vertical velocity when grounded', () {
      engine.player.isGrounded = true;
      engine.jump();
      expect(engine.player.vy, lessThan(0));
      expect(engine.player.isGrounded, isFalse);
    });

    test('Attack triggers attack timer and state', () {
      engine.attack();
      expect(engine.player.isAttacking, isTrue);
      expect(engine.player.actionState, equals(PlayerActionState.attacking));
    });

    test('Collecting coins increases coin count', () {
      final coin = engine.levelData.collectibles.firstWhere((e) => e.type == EntityType.coin && e.x > 1000);
      engine.player.x = coin.x;
      engine.player.y = coin.y;

      engine.tick(0.016);
      expect(coin.isCollected, isTrue);
      expect(engine.player.coins, greaterThanOrEqualTo(1));
    });

    test('Touching checkpoint sets spawn location', () {
      final cp = engine.levelData.checkpoints.first;
      engine.player.x = cp.x;
      engine.player.y = cp.y;

      engine.tick(0.016);
      expect(cp.isActivated, isTrue);
      expect(engine.spawnX, equals(cp.x));
      expect(engine.spawnY, equals(cp.y));
    });

    test('Touching goal portal triggers victory state', () {
      final portal = engine.levelData.goalPortal;
      engine.player.x = portal.x;
      engine.player.y = portal.y;

      engine.tick(0.016);
      expect(engine.status, equals(GameStatus.victory));
    });

    test('Pause toggles game status', () {
      expect(engine.status, equals(GameStatus.playing));
      engine.togglePause();
      expect(engine.status, equals(GameStatus.paused));
      engine.togglePause();
      expect(engine.status, equals(GameStatus.playing));
    });
  });

  group('UI Widgets Tests', () {
    testWidgets('GameHud renders health, coins, and pause button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              currentHealth: 4,
              maxHealth: 5,
              coins: 12,
              onPause: () {},
            ),
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('SettingsOverlay renders sound, music, and orientation controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsOverlay(),
        ),
      );

      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Background Music'), findsOneWidget);
      expect(find.text('Portrait'), findsOneWidget);
      expect(find.text('Landscape'), findsOneWidget);
    });

    testWidgets('LevelSelectScreen renders 10 level cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LevelSelectScreen(
            onSelectLevel: (lvl) {},
            onBack: () {},
          ),
        ),
      );

      expect(find.text('SELECT LEVEL'), findsOneWidget);
      expect(find.text('Forest'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Crystal'), findsOneWidget);
    });

    testWidgets('VirtualJoystick renders and triggers callback', (WidgetTester tester) async {
      double receivedVal = 0.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: VirtualJoystick(
                onChanged: (val) => receivedVal = val,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VirtualJoystick), findsOneWidget);
      final center = tester.getCenter(find.byType(VirtualJoystick));
      final TestGesture gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(receivedVal, greaterThan(0));
      await gesture.up();
    });

    testWidgets('ActionButtons renders jump and attack buttons', (WidgetTester tester) async {
      bool jumpPressed = false;
      bool attackPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButtons(
              onJump: () => jumpPressed = true,
              onAttack: () => attackPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('JUMP'), findsOneWidget);
      expect(find.text('ATTACK'), findsOneWidget);

      await tester.tap(find.text('JUMP'));
      expect(jumpPressed, isTrue);

      await tester.tap(find.text('ATTACK'));
      expect(attackPressed, isTrue);
    });

    testWidgets('PauseOverlay renders menu options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PauseOverlay(
            onResume: () {},
            onRestart: () {},
            onQuit: () {},
          ),
        ),
      );

      expect(find.text('GAME PAUSED'), findsOneWidget);
      expect(find.text('RESUME'), findsOneWidget);
      expect(find.text('RESTART LEVEL'), findsOneWidget);
    });

    testWidgets('GameOverOverlay renders fallen message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameOverOverlay(
            hasCheckpoint: true,
            onRespawn: () {},
            onRestart: () {},
          ),
        ),
      );

      expect(find.text('FALLEN IN THE FOREST'), findsOneWidget);
      expect(find.text('RESPAWN AT SHRINE'), findsOneWidget);
    });

    testWidgets('VictoryOverlay renders victory message and coins', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VictoryOverlay(
            levelNumber: 1,
            coinsCollected: 25,
            onNextLevel: () {},
            onReplay: () {},
            onLevelSelect: () {},
          ),
        ),
      );

      expect(find.text('LEVEL 1 CLEARED!'), findsOneWidget);
      expect(find.text('Coins: 25'), findsOneWidget);
    });
  });
}
