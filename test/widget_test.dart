import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:forestbound/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Forestbound App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ForestboundApp());

    // Verify splash screen displays Forestbound logo title
    expect(find.text('FORESTBOUND'), findsOneWidget);
    expect(find.text('A 2D Dark Fantasy Platformer'), findsOneWidget);
  });
}
