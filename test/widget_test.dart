import 'package:flutter_test/flutter_test.dart';
import 'package:zipgram/main.dart';

void main() {
  testWidgets('Zipgram App smoke test renders splash and home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ZipgramApp());
    expect(find.byType(ZipgramApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
