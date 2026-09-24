import 'package:flutter_test/flutter_test.dart';
import 'package:ai_browser/app/app.dart';

void main() {
  testWidgets('AI Browser App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AiBrowserApp());
    await tester.pumpAndSettle();

    expect(find.text('AI BROWSER'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tabs'), findsOneWidget);
    expect(find.text('Bookmarks'), findsWidgets);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
  });
}
