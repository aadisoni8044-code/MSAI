import 'package:flutter_test/flutter_test.dart';
import 'package:enchanted_forest_adventure/main.dart';

void main() {
  testWidgets('EnchantedForestApp renders main menu properly', (WidgetTester tester) async {
    await tester.pumpWidget(const EnchantedForestApp());

    expect(find.text('ENCHANTED\nFOREST'), findsOneWidget);
    expect(find.text('START ADVENTURE'), findsOneWidget);
  });
}
