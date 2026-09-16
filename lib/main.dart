import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'services/game_service.dart';
import 'game/game_painter.dart';
import 'widgets/game_hud.dart';
import 'widgets/mobile_controls.dart';
import 'widgets/overlay_dialog.dart';
import 'screens/start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ForestboundApp());
}

class ForestboundApp extends StatelessWidget {
  const ForestboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forestbound',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final GameService gameService = GameService();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    if (gameService.state == GameState.startMenu) {
      gameService.initializeGame(size);
    }
  }

  void _onTick(Duration elapsed) {
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Limit dt to prevent massive physics jumps when pausing/resuming
    final double clampedDt = dt.clamp(0.0, 0.033);
    final size = MediaQuery.of(context).size;

    gameService.update(clampedDt, size);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: gameService,
        builder: (context, child) {
          if (gameService.state == GameState.startMenu) {
            return StartScreen(
              onStart: () => gameService.startGame(),
            );
          }

          return Stack(
            children: [
              // Main Game Canvas
              Positioned.fill(
                child: CustomPaint(
                  painter: GamePainter(game: gameService),
                ),
              ),

              // HUD (Health, Score, Progress, Pause Button)
              Positioned.fill(
                child: GameHUD(
                  gameService: gameService,
                  onPause: () => gameService.pauseGame(),
                ),
              ),

              // Mobile Controls Overlay
              if (gameService.state == GameState.playing)
                MobileControls(gameService: gameService),

              // Pause Overlay Dialog
              if (gameService.state == GameState.paused)
                OverlayDialog(
                  title: "GAME PAUSED",
                  subtitle: "Take a breath in the tranquil dark forest.",
                  primaryButtonText: "RESUME",
                  onPrimaryPressed: () => gameService.resumeGame(),
                  secondaryButtonText: "RESTART LEVEL",
                  onSecondaryPressed: () => gameService.restartLevel(),
                  accentColor: const Color(0xFF2DD4BF),
                ),

              // Game Over Dialog
              if (gameService.state == GameState.gameOver)
                OverlayDialog(
                  title: "GAME OVER",
                  subtitle: "You succumbed to the dark forest shadows.",
                  primaryButtonText: "RESPAWN AT CHECKPOINT",
                  onPrimaryPressed: () => gameService.respawnPlayer(),
                  secondaryButtonText: "RESTART LEVEL",
                  onSecondaryPressed: () => gameService.restartLevel(),
                  accentColor: const Color(0xFFEF4444),
                ),

              // Level Complete Dialog
              if (gameService.state == GameState.levelComplete)
                OverlayDialog(
                  title: "LEVEL COMPLETE!",
                  subtitle: "You escaped Whispering Woods with ${gameService.score} points!",
                  primaryButtonText: "PLAY AGAIN",
                  onPrimaryPressed: () => gameService.restartLevel(),
                  accentColor: const Color(0xFF10B981),
                ),
            ],
          );
        },
      ),
    );
  }
}
