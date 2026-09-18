import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/audio_manager.dart';
import 'game/forest_game.dart';
import 'ui/hud_overlay.dart';
import 'ui/on_screen_controls.dart';
import 'ui/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await AudioManager().init();

  runApp(const ForestAdventureApp());
}

class ForestAdventureApp extends StatefulWidget {
  const ForestAdventureApp({super.key});

  @override
  State<ForestAdventureApp> createState() => _ForestAdventureAppState();
}

class _ForestAdventureAppState extends State<ForestAdventureApp> {
  bool _isPlaying = false;
  late final ForestGame _game;

  @override
  void initState() {
    super.initState();
    _game = ForestGame();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
    });
    _game.startGame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF04101E),
        body: !_isPlaying
            ? StartMenuScreen(onStart: _startGame)
            : GameWidget<ForestGame>(
                game: _game,
                overlayBuilderMap: {
                  'HUD': (context, game) => Stack(
                        children: [
                          HudOverlay(game: game),
                          OnScreenControls(game: game),
                        ],
                      ),
                  'Pause': (context, game) => PauseOverlay(
                        onResume: () => game.resumeGame(),
                        onRestart: () {
                          game.overlays.remove('Pause');
                          game.startGame();
                        },
                      ),
                  'GameOver': (context, game) => GameOverOverlay(
                        onRestart: () {
                          game.overlays.remove('GameOver');
                          game.startGame();
                        },
                      ),
                  'LevelComplete': (context, game) => LevelCompleteOverlay(
                        crystalsCount: game.collectedCrystals,
                        totalCrystals: game.totalCrystals,
                        onRestart: () {
                          game.overlays.remove('LevelComplete');
                          game.startGame();
                        },
                      ),
                },
                initialActiveOverlays: const ['HUD'],
              ),
      ),
    );
  }
}
