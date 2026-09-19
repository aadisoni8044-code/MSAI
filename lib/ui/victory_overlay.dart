import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class VictoryOverlay extends StatelessWidget {
  final int coinsCollected;
  final VoidCallback onReplay;

  const VictoryOverlay({
    super.key,
    required this.coinsCollected,
    required this.onReplay,
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
            border: Border.all(color: GameColors.portalGlow, width: 2),
            boxShadow: const [
              BoxShadow(
                color: GameColors.portalGlow,
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: GameColors.portalGlow, size: 58),
              const SizedBox(height: 12),
              const Text(
                'FOREST CLEARED!',
                style: TextStyle(
                  color: GameColors.uiTextLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  shadows: [
                    Shadow(color: GameColors.portalGlow, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameColors.uiGlassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: GameColors.coinGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Coins: $coinsCollected',
                      style: const TextStyle(
                        color: GameColors.uiTextGold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.uiButtonBg,
                    foregroundColor: GameColors.playerGlow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: GameColors.playerGlow, width: 1.5),
                    ),
                    elevation: 4,
                  ),
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded, size: 22),
                  label: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
