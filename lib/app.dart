import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';

class ForestboundApp extends StatelessWidget {
  const ForestboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forestbound',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF80FFDB),
        scaffoldBackgroundColor: const Color(0xFF030D18),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF80FFDB),
          secondary: Color(0xFF64DFDF),
          surface: Color(0xFF081F2C),
          background: Color(0xFF030D18),
          error: Color(0xFFEF476F),
        ),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main_menu': (context) => const MainMenuScreen(),
        '/level_select': (context) => const LevelSelectScreen(),
        '/game': (context) => const GameScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
