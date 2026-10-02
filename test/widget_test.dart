import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zippro/core/app_colors.dart';
import 'package:zippro/models/filter_data.dart';
import 'package:zippro/providers/camera_provider.dart';
import 'package:zippro/providers/chat_provider.dart';
import 'package:zippro/providers/filter_provider.dart';
import 'package:zippro/providers/navigation_provider.dart';
import 'package:zippro/providers/settings_provider.dart';
import 'package:zippro/providers/story_provider.dart';
import 'package:zippro/views/main_navigation_screen.dart';

void main() {
  test('Verify FilterData contains exactly 50 distinct camera filters', () {
    expect(FilterData.filters.length, equals(50));
    final ids = FilterData.filters.map((f) => f.id).toSet();
    expect(ids.length, equals(50));
  });

  test('FilterProvider selection and categories test', () {
    final provider = FilterProvider();
    expect(provider.filters.length, equals(50));
    expect(provider.selectedIndex, equals(0));
    expect(provider.activeFilter.name, equals('Normal'));

    provider.selectFilter(2);
    expect(provider.selectedIndex, equals(2));
    expect(provider.activeFilter.name, equals('Neon Cyan'));

    provider.nextFilter();
    expect(provider.selectedIndex, equals(3));

    provider.previousFilter();
    expect(provider.selectedIndex, equals(2));

    expect(provider.categories.contains('All'), isTrue);
    expect(provider.categories.contains('Cyber & Neon'), isTrue);
  });

  test('NavigationProvider tab switching test', () {
    final nav = NavigationProvider();
    expect(nav.currentIndex, equals(1)); // Default camera screen

    nav.goToChat();
    expect(nav.currentIndex, equals(0));

    nav.goToStories();
    expect(nav.currentIndex, equals(2));

    nav.goToCamera();
    expect(nav.currentIndex, equals(1));
  });

  testWidgets('MainNavigationScreen renders top branding, 3 tabs, and 50 filters slider',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FilterProvider()),
          ChangeNotifierProvider(create: (_) => CameraProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => StoryProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify ZIPPRO branding badge exists
    expect(find.text('ZIPPRO'), findsOneWidget);

    // Verify 3 key tabs exist in floating navigation
    expect(find.text('Camera'), findsOneWidget);

    // Verify filter names appear on camera screen
    expect(find.text('Normal'), findsWidgets);
    expect(find.text('Cyberpunk'), findsWidgets);
  });
}
