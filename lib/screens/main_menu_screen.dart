import 'package:flutter/material.dart';

import '../services/game_service.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();
    final hasSave = gameService.progress.unlockedLevels.isNotEmpty;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF030D18),
              Color(0xFF0F3B3E),
              Color(0xFF165B5C),
              Color(0xFF082224),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Logo Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0x66081F2C),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0x4480FFDB)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x44000000), blurRadius: 16),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'FORESTBOUND',
                          style: TextStyle(
                            color: Color(0xFF80FFDB),
                            fontSize: 38,
                            fontWeight: FontWeight.black,
                            letterSpacing: 4.5,
                            shadows: [
                              Shadow(color: Color(0x8880FFDB), blurRadius: 20),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Whispers of the Ancient Realm',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 13,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Action Buttons Card
                  Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xAA081F2C),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0x3364DFDF)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 24),
                      ],
                    ),
                    child: Column(
                      children: [
                        // PLAY BUTTON
                        _buildMenuButton(
                          context: context,
                          label: 'PLAY GAME',
                          icon: Icons.play_arrow,
                          color: const Color(0xFF80FFDB),
                          onPressed: () {
                            gameService.loadLevel(1);
                            Navigator.pushNamed(context, '/game');
                          },
                        ),
                        const SizedBox(height: 14),

                        // CONTINUE BUTTON
                        _buildMenuButton(
                          context: context,
                          label: 'CONTINUE',
                          icon: Icons.fast_forward,
                          color: hasSave ? const Color(0xFF64DFDF) : Colors.grey,
                          onPressed: hasSave
                              ? () {
                                  gameService.loadLevel(gameService.progress.currentLevelId);
                                  Navigator.pushNamed(context, '/game');
                                }
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // LEVELS BUTTON
                        _buildMenuButton(
                          context: context,
                          label: 'LEVEL SELECT',
                          icon: Icons.grid_view,
                          color: const Color(0xFFFFD166),
                          onPressed: () {
                            Navigator.pushNamed(context, '/level_select');
                          },
                        ),
                        const SizedBox(height: 14),

                        // SETTINGS BUTTON
                        _buildMenuButton(
                          context: context,
                          label: 'SETTINGS',
                          icon: Icons.settings,
                          color: const Color(0xFFEF476F),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          foregroundColor: color,
          disabledBackgroundColor: Colors.white10,
          disabledForegroundColor: Colors.white30,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: onPressed != null ? color : Colors.transparent, width: 1.5),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
