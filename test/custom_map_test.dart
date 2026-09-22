import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/custom_map_data.dart';
import 'package:enchanted_forest_adventure/core/custom_map_progress_controller.dart';
import 'package:enchanted_forest_adventure/ui/create_map_home_screen.dart';
import 'package:enchanted_forest_adventure/ui/map_editor_screen.dart';
import 'package:enchanted_forest_adventure/ui/custom_map_game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CustomMapData Model Tests', () {
    test('Default CustomMapData initializes with player start and finish portal', () {
      final map = CustomMapData(
        id: 'test_1',
        name: 'Test Level',
        theme: 'forest',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        entities: [
          CustomMapEntity(id: 'start', type: 'playerStart', x: 100, y: 300, width: 40, height: 60),
          CustomMapEntity(id: 'goal', type: 'goalPortal', x: 2000, y: 300, width: 60, height: 80),
          CustomMapEntity(id: 'g1', type: 'groundPlatform', x: 0, y: 400, width: 2500, height: 80),
        ],
      );
      expect(map.name, equals('Test Level'));
      expect(map.entities, isNotEmpty);
      expect(map.entities.any((e) => e.type == 'playerStart'), isTrue);
      expect(map.entities.any((e) => e.type == 'goalPortal'), isTrue);
      expect(map.entities.any((e) => e.type == 'groundPlatform'), isTrue);
    });

    test('CustomMapData toJson and fromJson preserve properties', () {
      final original = CustomMapData(
        id: 'map_json_1',
        name: 'My Custom Map',
        theme: 'crystal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        entities: [
          CustomMapEntity(id: 'c1', type: 'coin', x: 300, y: 400, width: 32, height: 32),
        ],
      );

      final jsonMap = original.toJson();
      final restored = CustomMapData.fromJson(jsonMap);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals('My Custom Map'));
      expect(restored.theme, equals('crystal'));
      expect(restored.entities.length, equals(original.entities.length));
      expect(restored.entities.any((e) => e.id == 'c1'), isTrue);
    });

    test('CustomMapData builtInTemplates provides 8 rich templates', () {
      final templates = CustomMapData.builtInTemplates;
      expect(templates.length, equals(8));

      final names = templates.map((t) => t.name).toList();
      expect(names, contains('Forest Starter'));
      expect(names, contains('Dark Forest'));
      expect(names, contains('Crystal Valley'));
      expect(names, contains('Lava Escape'));
      expect(names, contains('Ice Path'));
      expect(names, contains('Sky Ruins'));
      expect(names, contains('Shadow Temple'));
      expect(names, contains('Zombie Village'));
    });
  });

  group('CustomMapProgressController Tests', () {
    test('Controller initializes and allows adding, updating, and deleting custom maps', () async {
      final controller = CustomMapProgressController.instance;
      await controller.init();

      final newMap = controller.createNewBlankMap(name: 'Unit Test Map');
      await controller.saveMap(newMap);

      expect(controller.getMapById(newMap.id), isNotNull);

      // Update map
      final updatedMap = newMap.copyWith(name: 'Updated Unit Test Map');
      await controller.saveMap(updatedMap);
      expect(controller.getMapById(newMap.id)?.name, equals('Updated Unit Test Map'));

      // Duplicate template as new map
      final template = CustomMapData.builtInTemplates.first;
      final duplicate = await controller.duplicateTemplateAsNewMap(template);
      expect(duplicate, isNotNull);
      expect(duplicate.name, contains('Copy of'));

      // Delete map
      await controller.deleteMap(newMap.id);
      expect(controller.getMapById(newMap.id), isNull);
    });

    test('Controller records play stats and completions', () async {
      final controller = CustomMapProgressController.instance;
      await controller.init();

      final map = controller.createNewBlankMap(name: 'Stats Test Map');
      await controller.saveMap(map);

      await controller.recordCompletion(map.id, 25.5);
      final updated = controller.getMapById(map.id)!;
      expect(updated.timesCompleted, equals(1));
      expect(updated.bestTimeSeconds, equals(25.5));
    });
  });

  group('Create Map UI Widget Tests', () {
    testWidgets('CreateMapHomeScreen renders tabs and create button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateMapHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CREATE MAP STUDIO'), findsOneWidget);
      expect(find.text('MY MAPS'), findsOneWidget);
      expect(find.text('FEATURED TEMPLATES'), findsOneWidget);
      expect(find.text('+ CREATE NEW MAP'), findsOneWidget);
    });

    testWidgets('MapEditorScreen renders canvas header and bottom action toolbar', (WidgetTester tester) async {
      final controller = CustomMapProgressController.instance;
      final map = controller.createNewBlankMap(name: 'Test Editor');

      await tester.pumpWidget(
        MaterialApp(
          home: MapEditorScreen(mapData: map),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('PLAY TEST'), findsOneWidget);
      expect(find.byIcon(Icons.border_clear_rounded), findsOneWidget);
      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
    });

    testWidgets('CustomMapGameScreen converts CustomMapData and initializes game', (WidgetTester tester) async {
      final controller = CustomMapProgressController.instance;
      final map = controller.createNewBlankMap(name: 'Playable Map');

      await tester.pumpWidget(
        MaterialApp(
          home: CustomMapGameScreen(mapData: map),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomMapGameScreen), findsOneWidget);
    });
  });
}
