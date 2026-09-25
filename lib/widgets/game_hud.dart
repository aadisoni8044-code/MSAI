import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class GameHud extends StatelessWidget {
  final int currentHealth;
  final int maxHealth;
  final int coins;
  final VoidCallback onPause;

  const GameHud({
    super.key,
    required this.currentHealth,
    required this.maxHealth,
    required this.coins,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Health Bar (Top Left)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.uiPanelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.uiGlassBorder),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: GameColors.uiHealthRed, size: 20),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    maxHealth,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < currentHealth
                            ? GameColors.uiHealthRed
                            : Colors.white24,
                        boxShadow: index < currentHealth
                            ? const [
                                BoxShadow(
                                  color: GameColors.uiHealthRed,
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pause Button (Top Center)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPause,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GameColors.uiPanelBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: GameColors.uiGlassBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: GameColors.uiTextLight,
                  size: 22,
                ),
              ),
            ),
          ),

          // Coins Counter (Top Right)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.uiPanelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.uiGlassBorder),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: GameColors.uiTextGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
