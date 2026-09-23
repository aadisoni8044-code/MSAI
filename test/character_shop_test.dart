import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/ui/character_shop_screen.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CharacterProgressController.instance.init();
    await CharacterProgressController.instance.resetProgress();
  });

  group('CharacterData Dataset Tests', () {
    test('CharacterData contains exactly 50 unique characters', () {
      expect(CharacterData.allCharacters.length, equals(50));
      final ids = CharacterData.allCharacters.map((c) => c.id).toSet();
      expect(ids.length, equals(50));
    });

    test('Character 1 is default Forest Adventurer character with 0 price', () {
      final char1 = CharacterData.allCharacters.first;
      expect(char1.id, equals('char_1'));
      expect(char1.price, equals(0));
      expect(char1.name, equals('Forest Adventurer'));
    });
  });

  group('CharacterProgressController Logic Tests', () {
    test('Initial state unlocks char_1 and sets default selection', () {
      final ctrl = CharacterProgressController.instance;

      expect(ctrl.isUnlocked('char_1'), isTrue);
      expect(ctrl.selectedCharacterId, equals('char_1'));
      expect(ctrl.selectedCharacter.name, equals('Forest Adventurer'));
    });

    test('Purchasing character with sufficient coins deducts balance and unlocks character', () async {
      final ctrl = CharacterProgressController.instance;
      expect(ctrl.totalCoins, equals(500));

      final char2 = CharacterData.getById('char_2'); // Verdant Warrior (150 coins)
      final success = await ctrl.purchaseCharacter(char2);

      expect(success, isTrue);
      expect(ctrl.totalCoins, equals(350));
      expect(ctrl.isUnlocked('char_2'), isTrue);
      expect(ctrl.selectedCharacterId, equals('char_2'));
    });

    test('Purchasing character with insufficient coins fails without deducting balance', () async {
      final ctrl = CharacterProgressController.instance;
      await ctrl.resetProgress();
      // Try to buy expensive character (3000 coins) with only 500 coins
      final expensiveChar = CharacterData.getById('char_50');
      final success = await ctrl.purchaseCharacter(expensiveChar);

      expect(success, isFalse);
      expect(ctrl.totalCoins, equals(500));
      expect(ctrl.isUnlocked('char_50'), isFalse);
    });

    test('Selecting unlocked character updates active character selection', () async {
      final ctrl = CharacterProgressController.instance;
      final char2 = CharacterData.getById('char_2');
      await ctrl.purchaseCharacter(char2);

      // Switch back to char_1
      await ctrl.selectCharacter('char_1');
      expect(ctrl.selectedCharacterId, equals('char_1'));

      // Switch back to char_2
      await ctrl.selectCharacter('char_2');
      expect(ctrl.selectedCharacterId, equals('char_2'));
    });
  });

  group('CharacterShopScreen UI Widget Tests', () {
    testWidgets('CharacterShopScreen renders header, coin balance, and character grid', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CharacterShopScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('HEROES & LEGENDS (50)'), findsOneWidget);
      expect(find.text('500'), findsAtLeast(1)); // Total coins or card price
      expect(find.text('Forest Adventurer'), findsWidgets);
    });

    testWidgets('MainMenuScreen renders SHOP button and navigates to CharacterShopScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );

      expect(find.text('🛒 SHOP'), findsOneWidget);

      await tester.tap(find.text('🛒 SHOP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(CharacterShopScreen), findsOneWidget);
    });
  });
}
