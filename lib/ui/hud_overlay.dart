import 'package:flutter/material.dart';
import '../game/forest_game.dart';

class HudOverlay extends StatelessWidget {
  final ForestGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final progress = (game.player.position.x / game.worldBounds.x).clamp(0.0, 1.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 3 Heart Health Indicators
                Row(
                  children: List.generate(3, (index) {
                    final isFilled = index < game.player.health;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(
                        isFilled ? Icons.favorite : Icons.favorite_border,
                        color: isFilled ? const Color(0xFFEF4444) : Colors.white38,
                        size: 28,
                      ),
                    );
                  }),
                ),

                // Crystal / Coin Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: Color(0xFF00E5FF), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${game.collectedCrystals}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pause Button
                IconButton(
                  onPressed: () {
                    game.pauseGame();
                  },
                  icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Level Progress Indicator Bar
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
