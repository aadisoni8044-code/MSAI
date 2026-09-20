import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation for mobile gaming experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI overlays for full screen immersion
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ZombieSurvival3DApp());
}

class ZombieSurvival3DApp extends StatelessWidget {
  const ZombieSurvival3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Zombie Survival',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amberAccent,
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const StartMenuScreen(),
    );
  }
}

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E1B4B)],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.coronavirus, color: Colors.redAccent, size: 72),
                const SizedBox(height: 12),
                const Text(
                  '3D ZOMBIE SURVIVAL',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.black,
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(color: Colors.red, blurRadius: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'SURVIVE THE INFECTED WASTELAND',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 36),

                // Start Game Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text('START SURVIVAL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.black, fontSize: 18, letterSpacing: 1.2),
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
