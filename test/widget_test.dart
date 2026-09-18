import 'package:flutter_test/flutter_test.dart';
import 'package:forest_adventure/main.dart';

void main() {
  testWidgets('Start screen loads and displays play button', (WidgetTester tester) async {
    await tester.pumpWidget(const ForestAdventureApp());

    expect(find.text('FOREST ADVENTURE'), findsOneWidget);
    expect(find.text('PLAY GAME'), findsOneWidget);
  });
}
