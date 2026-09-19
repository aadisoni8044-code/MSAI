import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/ui/game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.skyBackground,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GameColors.skyBackground,
                  GameColors.deepForestTeal,
                  GameColors.ancientBarkDark,
                ],
              ),
            ),
          ),

          // Title & Play Card
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game Icon / Avatar Crest
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: GameColors.uiPanelBg,
                        border: Border.all(color: GameColors.playerGlow, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: GameColors.playerGlow,
                            blurRadius: 25,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.forest_rounded, color: GameColors.foliageGlow, size: 64),
                    ),
                    const SizedBox(height: 24),

                    // Game Title
                    const Text(
                      'ENCHANTED\nFOREST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GameColors.uiTextLight,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        height: 1.1,
                        shadows: [
                          Shadow(color: GameColors.playerGlow, blurRadius: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A 2D Fantasy Adventure',
                      style: TextStyle(
                        color: GameColors.mistBlue,
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Play Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.mossyGreenBright,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                          shadowColor: GameColors.mossyGreenBright,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const GameScreen()),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text(
                          'START GAME',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Touch Controls Help Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: GameColors.uiPanelBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameColors.uiGlassBorder),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'CONTROLS',
                            style: TextStyle(
                              color: GameColors.uiTextGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Left Joystick: Move Left / Right\n• Bottom-Right Buttons: Jump & Attack',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
