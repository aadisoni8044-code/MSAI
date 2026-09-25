import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class VictoryOverlay extends StatelessWidget {
  final int levelNumber;
  final int coinsCollected;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onLevelSelect;

  const VictoryOverlay({
    super.key,
    this.levelNumber = 1,
    required this.coinsCollected,
    required this.onNextLevel,
    required this.onReplay,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNext = levelNumber < 200;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 310,
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
              Text(
                'LEVEL $levelNumber CLEARED!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GameColors.uiTextLight,
                  fontSize: 20,
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
              const SizedBox(height: 20),

              if (hasNext) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.mossyGreenBright,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: onNextLevel,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                    label: const Text(
                      'NEXT LEVEL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GameColors.playerGlow,
                    side: const BorderSide(color: GameColors.playerGlow, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: const Text(
                    'REPLAY LEVEL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                  onPressed: onLevelSelect,
                  icon: const Icon(Icons.grid_view_rounded, size: 20),
                  label: const Text(
                    'SELECT LEVEL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
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
