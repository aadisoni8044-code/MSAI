import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Automatically switch device to Landscape orientation at startup
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const EnchantedForestApp());
}

class EnchantedForestApp extends StatelessWidget {
  const EnchantedForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enchanted Forest Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameColors.skyBackground,
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
