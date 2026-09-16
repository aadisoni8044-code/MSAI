import 'package:flutter/material.dart';
import '../services/game_service.dart';

class GameHUD extends StatelessWidget {
  final GameService gameService;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.gameService,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final player = gameService.player;
    final int collectedCount = gameService.levelData.collectibles.where((c) => c.isCollected).length;
    final int totalCount = gameService.totalCrystals;
    final double progress = (player.position.dx / gameService.levelData.worldWidth).clamp(0.0, 1.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hearts Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x990F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(player.maxHealth, (index) {
                      final bool isFull = index < player.currentHealth;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Icon(
                          isFull ? Icons.favorite : Icons.favorite_border,
                          color: isFull ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                          size: 24,
                        ),
                      );
                    }),
                  ),
                ),

                // Crystal / Score Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x990F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF14B8A6), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.diamond,
                        color: Color(0xFF2DD4BF),
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$collectedCount / $totalCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [Shadow(color: Color(0xFF0F766E), blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "PTS: ${gameService.score}",
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pause Button
                IconButton(
                  onPressed: onPause,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x990F172A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Level Progress Indicator
            Container(
              height: 6,
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0x660F172A),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
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
