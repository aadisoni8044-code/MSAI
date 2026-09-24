import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/level_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/custom_map_progress_controller.dart';
import 'package:enchanted_forest_adventure/ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Automatically switch device to Landscape orientation at startup
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize async controllers
  await LevelProgressController.instance.init();
  await ZombieProgressController.instance.init();
  await CharacterProgressController.instance.init();
  await CustomMapProgressController.instance.init();

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
      home: const SplashScreen(),
    );
  }
}
