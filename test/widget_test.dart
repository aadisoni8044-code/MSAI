import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippro/main.dart';

void main() {
  testWidgets('ZipPro loads responsive scaffold and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ZipProApp());
    await tester.pumpAndSettle();

    // Verify ZipPro title is present
    expect(find.text('ZipPro'), findsOneWidget);

    // Verify Bottom Navigation items exist
    expect(find.text('Camera'), findsWidgets);
    expect(find.text('Chat'), findsWidgets);
    expect(find.text('Stories'), findsWidgets);
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
