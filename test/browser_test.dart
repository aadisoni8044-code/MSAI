import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firezip/models/tab_model.dart';
import 'package:firezip/models/bookmark_model.dart';
import 'package:firezip/models/history_item_model.dart';
import 'package:firezip/models/download_model.dart';
import 'package:firezip/providers/browser_provider.dart';
import 'package:firezip/providers/bookmarks_provider.dart';
import 'package:firezip/providers/downloads_provider.dart';
import 'package:firezip/providers/settings_provider.dart';
import 'package:firezip/theme/responsive_layout.dart';
import 'package:firezip/theme/app_theme.dart';
import 'package:firezip/views/main_browser_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('URL & Query Parsing Unit Tests', () {
    test('Parses valid HTTPS URL directly', () {
      final url = BrowserProvider.parseInputToUrl(
        'https://flutter.dev',
        SearchEngine.google,
      );
      expect(url, 'https://flutter.dev');
    });

    test('Prepends https:// to host names without scheme', () {
      final url = BrowserProvider.parseInputToUrl(
        'github.com',
        SearchEngine.google,
      );
      expect(url, 'https://github.com');
    });

    test('Formats search queries using selected search engine', () {
      final googleQuery = BrowserProvider.parseInputToUrl(
        'flutter responsive layout',
        SearchEngine.google,
      );
      expect(
        googleQuery,
        'https://www.google.com/search?q=flutter%20responsive%20layout',
      );

      final ddgQuery = BrowserProvider.parseInputToUrl(
        'firezip browser',
        SearchEngine.duckDuckGo,
      );
      expect(
        ddgQuery,
        'https://duckduckgo.com/?q=firezip%20browser',
      );
    });

    test('Handles internal Firezip home URI', () {
      final homeUrl = BrowserProvider.parseInputToUrl(
        'firezip://home',
        SearchEngine.google,
      );
      expect(homeUrl, 'firezip://home');
    });
  });

  group('Tab Management Unit Tests', () {
    test('Initializes with default home tab', () async {
      final browser = BrowserProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(browser.tabs.length, greaterThanOrEqualTo(1));
      expect(browser.currentTab.url, 'firezip://home');
    });

    test('Opens new tabs and switches active tab index', () async {
      final browser = BrowserProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      final initialCount = browser.tabs.length;

      browser.openNewTab(url: 'https://flutter.dev', title: 'Flutter');
      expect(browser.tabs.length, initialCount + 1);
      expect(browser.currentTab.url, 'https://flutter.dev');
    });

    test('Closes tabs safely', () async {
      final browser = BrowserProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      browser.openNewTab(url: 'https://github.com', title: 'GitHub');
      final count = browser.tabs.length;

      browser.closeTab(browser.activeTabIndex);
      expect(browser.tabs.length, count - 1);
    });

    test('Navigates tab and updates history stack', () async {
      final browser = BrowserProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      final settings = SettingsProvider();

      browser.navigateCurrentTab('https://wikipedia.org', settings.searchEngine);
      expect(browser.currentTab.url, 'https://wikipedia.org');
      expect(browser.currentTab.canGoBack, true);

      browser.goBack();
      expect(browser.currentTab.url, 'firezip://home');
      expect(browser.currentTab.canGoForward, true);

      browser.goForward();
      expect(browser.currentTab.url, 'https://wikipedia.org');
    });
  });

  group('Bookmarks & Downloads Provider Tests', () {
    test('Bookmarks Provider add and remove operations', () async {
      final bookmarks = BookmarksProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      await bookmarks.addBookmark('Google', 'https://www.google.com');

      expect(bookmarks.isBookmarked('https://www.google.com'), true);

      await bookmarks.removeBookmark('https://www.google.com');
      expect(bookmarks.isBookmarked('https://www.google.com'), false);
    });

    test('Downloads Provider start and cancel operations', () async {
      final downloads = DownloadsProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      downloads.startDownload('test.pdf', 'https://example.com/test.pdf', '2.5 MB');

      expect(downloads.downloads.length, greaterThanOrEqualTo(1));
      expect(downloads.downloads.first.fileName, 'test.pdf');
      expect(downloads.downloads.first.state, DownloadState.downloading);

      downloads.cancelDownload(downloads.downloads.first.id);
      expect(downloads.downloads.first.state, DownloadState.canceled);
    });
  });

  group('Settings Provider Tests', () {
    test('Updates theme mode and search engine settings', () async {
      final settings = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      await settings.setThemeMode(ThemeMode.light);
      expect(settings.themeMode, ThemeMode.light);

      await settings.setSearchEngine(SearchEngine.brave);
      expect(settings.searchEngine, SearchEngine.brave);
    });
  });

  group('Widget & Responsive UI Tests', () {
    testWidgets('Renders MainBrowserScreen on Mobile Viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => BrowserProvider()),
            ChangeNotifierProvider(create: (_) => BookmarksProvider()),
            ChangeNotifierProvider(create: (_) => DownloadsProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const MainBrowserScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('FIREZIP'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(1));

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Renders MainBrowserScreen on Desktop Viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => BrowserProvider()),
            ChangeNotifierProvider(create: (_) => BookmarksProvider()),
            ChangeNotifierProvider(create: (_) => DownloadsProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const MainBrowserScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Firezip'), findsAtLeastNWidgets(1));
      expect(find.text('FIREZIP'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}
