import 'package:flutter/material.dart';

import '../services/game_service.dart';

class PauseScreen extends StatelessWidget {
  final GameService gameService;
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const PauseScreen({
    super.key,
    required this.gameService,
    required this.onResume,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black70,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xEE081F2C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF80FFDB), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x88000000), blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME PAUSED',
                style: TextStyle(
                  color: Color(0xFF80FFDB),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 28),

              // RESUME
              _buildPauseButton(
                label: 'RESUME',
                icon: Icons.play_arrow,
                color: const Color(0xFF80FFDB),
                onPressed: onResume,
              ),
              const SizedBox(height: 12),

              // RESTART
              _buildPauseButton(
                label: 'RESTART LEVEL',
                icon: Icons.refresh,
                color: const Color(0xFFFFD166),
                onPressed: onRestart,
              ),
              const SizedBox(height: 12),

              // SETTINGS
              _buildPauseButton(
                label: 'SETTINGS',
                icon: Icons.settings,
                color: const Color(0xFF64DFDF),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const SizedBox(height: 12),

              // MAIN MENU
              _buildPauseButton(
                label: 'MAIN MENU',
                icon: Icons.home,
                color: const Color(0xFFEF476F),
                onPressed: () {
                  gameService.isPaused = false;
                  Navigator.pushNamedAndRemoveUntil(context, '/main_menu', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 1.5),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
