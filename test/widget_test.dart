import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Nova Wealth App loads and displays total balance', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaWealthApp());
    expect(find.text('Net Worth Balance'), findsOneWidget);

    // Scroll down to reveal recent transactions on lower screen heights
    await tester.drag(find.text('Net Worth Balance'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Recent Transactions'), findsOneWidget);
  });
}
