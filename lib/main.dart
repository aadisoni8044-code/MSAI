import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/browser_provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/downloads_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'views/main_browser_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirezipApp());
}

class FirezipApp extends StatelessWidget {
  const FirezipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => DownloadsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Firezip Browser',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const MainBrowserScreen(),
          );
        },
      ),
    );
  }
}
