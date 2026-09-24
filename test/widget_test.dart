import 'package:flutter_test/flutter_test.dart';
import 'package:enchanted_forest_adventure/main.dart';

void main() {
  testWidgets('EnchantedForestApp renders splash screen and navigates to main menu', (WidgetTester tester) async {
    await tester.pumpWidget(const EnchantedForestApp());

    // Verify Splash Screen is present initially
    expect(find.text('ENCHANTED FOREST ADVENTURE'), findsOneWidget);

    // Fast-forward past 3-second splash timer and transition
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify Main Menu Screen is rendered
    expect(find.text('ENCHANTED\nFOREST'), findsOneWidget);
    expect(find.text('START ADVENTURE'), findsOneWidget);
  });
}
