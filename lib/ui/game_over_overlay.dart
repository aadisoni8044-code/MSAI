import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class GameOverOverlay extends StatelessWidget {
  final bool hasCheckpoint;
  final VoidCallback onRespawn;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.hasCheckpoint,
    required this.onRespawn,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameColors.uiPanelBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: GameColors.shadowEnemyGlow, width: 2),
            boxShadow: const [
              BoxShadow(
                color: GameColors.shadowEnemyGlow,
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded, color: GameColors.shadowEnemyGlow, size: 54),
              const SizedBox(height: 12),
              const Text(
                'FALLEN IN THE FOREST',
                style: TextStyle(
                  color: GameColors.uiTextLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: GameColors.shadowEnemyGlow, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasCheckpoint
                    ? 'Respawn at your last glowing forest shrine or restart level.'
                    : 'The forest shadows have overwhelmed you. Try again!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              if (hasCheckpoint) ...[
                _ActionButton(
                  icon: Icons.restore_rounded,
                  label: 'RESPAWN AT SHRINE',
                  color: GameColors.shrineActive,
                  onPressed: onRespawn,
                ),
                const SizedBox(height: 12),
              ],
              _ActionButton(
                icon: Icons.refresh_rounded,
                label: 'RESTART LEVEL',
                color: GameColors.coinGold,
                onPressed: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
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
            side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
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
