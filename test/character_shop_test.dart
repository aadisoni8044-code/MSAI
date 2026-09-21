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
    test('CharacterData contains exactly 10 characters', () {
      expect(CharacterData.allCharacters.length, equals(10));
    });

    test('Character 1 is default Boy character with 0 price', () {
      final char1 = CharacterData.allCharacters.first;
      expect(char1.id, equals('char_1'));
      expect(char1.price, equals(0));
      expect(char1.gender, equals('Boy'));
    });

    test('Character dataset contains both Boy and Girl characters', () {
      final boys = CharacterData.allCharacters.where((c) => c.gender == 'Boy');
      final girls = CharacterData.allCharacters.where((c) => c.gender == 'Girl');

      expect(boys.isNotEmpty, isTrue);
      expect(girls.isNotEmpty, isTrue);
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
      // Reset coins to 500
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
      // Set low coins
      await ctrl.resetProgress();
      // Try to buy Celestial Champion (2500 coins) with only 500 coins
      final expensiveChar = CharacterData.getById('char_10');
      final success = await ctrl.purchaseCharacter(expensiveChar);

      expect(success, isFalse);
      expect(ctrl.totalCoins, equals(500));
      expect(ctrl.isUnlocked('char_10'), isFalse);
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
      await tester.pumpWidget(
        const MaterialApp(
          home: CharacterShopScreen(),
        ),
      );

      expect(find.text('CHARACTER SHOP'), findsOneWidget);
      expect(find.text('500'), findsAtLeast(1)); // Total coins or card price
      expect(find.text('Forest Adventurer'), findsWidgets);
      expect(find.text('Verdant Warrior'), findsOneWidget);
    });

    testWidgets('MainMenuScreen renders SHOP button and navigates to CharacterShopScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainMenuScreen(),
        ),
      );

      expect(find.text('🛒 SHOP'), findsOneWidget);

      await tester.tap(find.text('🛒 SHOP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CharacterShopScreen), findsOneWidget);
    });
  });
}
