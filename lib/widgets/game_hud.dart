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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Health Bar Top-Left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.uiPanelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: GameColors.uiHealthRed, size: 20),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(maxHealth, (index) {
                    final bool isFull = index < currentHealth;
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFull ? GameColors.uiHealthRed : GameColors.uiHealthBg,
                        border: Border.all(
                          color: isFull ? GameColors.uiHealthRed : Colors.white24,
                          width: 1.5,
                        ),
                        boxShadow: isFull
                            ? [
                                const BoxShadow(
                                  color: GameColors.uiHealthRed,
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Pause Button Center-Top
          GestureDetector(
            onTap: onPause,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameColors.uiPanelBg,
                border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.pause_rounded, color: GameColors.uiTextLight, size: 22),
            ),
          ),

          // Coin Counter Top-Right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.uiPanelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameColors.coinGold,
                  ),
                  child: const Icon(Icons.monetization_on, color: GameColors.ancientBarkDark, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: GameColors.uiTextGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(color: GameColors.coinGold, blurRadius: 6),
                    ],
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
