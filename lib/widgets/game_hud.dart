import 'package:flutter/material.dart';

import '../services/game_service.dart';

class GameHudWidget extends StatelessWidget {
  final GameService gameService;
  final VoidCallback onPausePressed;

  const GameHudWidget({
    super.key,
    required this.gameService,
    required this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    final player = gameService.player;
    final level = gameService.currentLevel;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // TOP-LEFT: Health & Energy Bars
            Column(
              crossAxisAlignment: CrossAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Health Bar
                _buildStatBar(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFEF476F),
                  value: player.health,
                  maxValue: player.maxHealth,
                  barColor: const Color(0xFFEF476F),
                  width: 140,
                ),
                const SizedBox(height: 6),
                // Energy Bar
                _buildStatBar(
                  icon: Icons.bolt,
                  iconColor: const Color(0xFF80FFDB),
                  value: player.energy.toInt(),
                  maxValue: player.maxEnergy.toInt(),
                  barColor: const Color(0xFF80FFDB),
                  width: 120,
                ),
              ],
            ),

            // TOP-CENTER: Level Title
            if (level != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xAA081F2C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4464DFDF)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 8),
                  ],
                ),
                child: Text(
                  level.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF80FFDB),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

            // TOP-RIGHT: Crystals, Coins & Pause Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crystals
                _buildCounterChip(
                  icon: Icons.diamond,
                  color: const Color(0xFF64DFDF),
                  count: player.crystals,
                ),
                const SizedBox(width: 8),

                // Coins
                _buildCounterChip(
                  icon: Icons.monetization_on,
                  color: const Color(0xFFFFD166),
                  count: player.coins,
                ),
                const SizedBox(width: 10),

                // Pause Button
                GestureDetector(
                  onTap: onPausePressed,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xCC0F3B3E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF80FFDB), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x44000000), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.pause, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar({
    required IconData icon,
    required Color iconColor,
    required int value,
    required int maxValue,
    required Color barColor,
    required double width,
  }) {
    double pct = (value / maxValue).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xCC081F2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Stack(
            children: [
              Container(
                width: width,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: width * pct,
                height: 10,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(color: barColor.withValues(alpha: 0.6), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterChip({
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC081F2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
