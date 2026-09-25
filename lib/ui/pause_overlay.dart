import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          width: 290,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.uiPanelBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: GameColors.uiGlassBorder, width: 2),
            boxShadow: const [
              BoxShadow(
                color: GameColors.mistBlue,
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME PAUSED',
                style: TextStyle(
                  color: GameColors.uiTextLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: GameColors.playerGlow, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _MenuButton(
                icon: Icons.play_arrow_rounded,
                label: 'RESUME',
                color: GameColors.playerGlow,
                onPressed: onResume,
              ),
              const SizedBox(height: 12),
              _MenuButton(
                icon: Icons.refresh_rounded,
                label: 'RESTART LEVEL',
                color: GameColors.coinGold,
                onPressed: onRestart,
              ),
              const SizedBox(height: 12),
              _MenuButton(
                icon: Icons.home_rounded,
                label: 'MAIN MENU',
                color: GameColors.uiTextLight,
                onPressed: onQuit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameColors.uiButtonBg,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GameColors.uiGlassBorder, width: 1.5),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: color,
          ),
        ),
      ),
    );
  }
}
