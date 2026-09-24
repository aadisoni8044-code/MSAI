import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'settings_provider.dart';
import 'browser_provider.dart';
import 'bookmarks_provider.dart';
import 'history_provider.dart';
import 'downloads_provider.dart';
import 'ai_provider.dart';
import '../screens/main_navigation_screen.dart';

class AiBrowserApp extends StatelessWidget {
  const AiBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => DownloadsProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          ThemeMode mode = ThemeMode.system;
          if (settingsProvider.settings.themeMode == 'light') {
            mode = ThemeMode.light;
          } else if (settingsProvider.settings.themeMode == 'dark') {
            mode = ThemeMode.dark;
          }

          return MaterialApp(
            title: 'AI Browser',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
