import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/ui/game_screen.dart';
import 'package:enchanted_forest_adventure/ui/zombie_intro_screen.dart';
import 'package:enchanted_forest_adventure/ui/level_select_screen.dart';
import 'package:enchanted_forest_adventure/ui/settings_overlay.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _openSettings(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SettingsOverlay();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _openLevelSelect(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          onSelectLevel: (lvl) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GameScreen(initialLevel: lvl)),
            );
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

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

          // Settings Button (Top Right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 20.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openSettings(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: GameColors.uiPanelBg,
                        border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: GameColors.playerGlow,
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: GameColors.uiTextLight,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Title & Play Cards
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game Icon
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

                    const SizedBox(height: 36),

                    // Start Game Button
                    SizedBox(
                      width: 260,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.mossyGreenBright,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 8,
                          shadowColor: GameColors.mossyGreenBright,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const GameScreen(initialLevel: 1)),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text(
                          'START GAME',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Zombie Mode Button & Stats Badge
                    ListenableBuilder(
                      listenable: ZombieProgressController.instance,
                      builder: (context, _) {
                        final zCtrl = ZombieProgressController.instance;

                        return Column(
                          children: [
                            SizedBox(
                              width: 260,
                              height: 52,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF8B0000),
                                      blurRadius: 16,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F070B),
                                    foregroundColor: const Color(0xFFFF4D4D),
                                    side: const BorderSide(color: Color(0xFFFF3333), width: 1.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                    elevation: 6,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ZombieIntroScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.coronavirus_rounded, size: 24, color: Color(0xFFFF3333)),
                                  label: const Text(
                                    'ZOMBIE MODE',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xAA0F070B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0x66FF3333)),
                              ),
                              child: Text(
                                'Highest Wave: ${zCtrl.highestWaveCompleted}  |  Defeated: ${zCtrl.totalZombiesDefeated}  |  Weapons: ${zCtrl.unlockedWeapons.length}',
                                style: const TextStyle(
                                  color: Color(0xFFFF8080),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Level Select Button
                    SizedBox(
                      width: 260,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GameColors.uiTextLight,
                          backgroundColor: GameColors.uiPanelBg,
                          side: const BorderSide(color: GameColors.playerGlow, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () => _openLevelSelect(context),
                        icon: const Icon(Icons.grid_view_rounded, size: 24, color: GameColors.foliageGlow),
                        label: const Text(
                          'SELECT LEVEL',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

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
                            '• Left Joystick / WASD: Move\n• Bottom-Right Buttons / Space / J: Jump & Attack',
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
