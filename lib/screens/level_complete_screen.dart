import 'package:flutter/material.dart';

import '../services/game_service.dart';

class LevelCompleteScreen extends StatelessWidget {
  final GameService gameService;

  const LevelCompleteScreen({super.key, required this.gameService});

  @override
  Widget build(BuildContext context) {
    final player = gameService.player;
    final level = gameService.currentLevel;

    int stars = gameService.progress.levelStars[gameService.progress.currentLevelId] ?? 1;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xEE081F2C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF80FFDB), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0xAA80FFDB), blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFFFD166), size: 56),
              const SizedBox(height: 8),
              const Text(
                'LEVEL COMPLETE!',
                style: TextStyle(
                  color: Color(0xFF80FFDB),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              if (level != null) ...[
                const SizedBox(height: 4),
                Text(
                  level.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
              const SizedBox(height: 20),

              // Star Rating Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      idx < stars ? Icons.star : Icons.star_border,
                      color: idx < stars ? const Color(0xFFFFD166) : Colors.white24,
                      size: 38,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Stats summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(Icons.diamond, '${player.crystals}', const Color(0xFF64DFDF)),
                    _buildStatCol(Icons.monetization_on, '${player.coins}', const Color(0xFFFFD166)),
                    _buildStatCol(Icons.timer, '${gameService.levelTime.toInt()}s', Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // NEXT LEVEL / REPLAY
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80FFDB),
                    foregroundColor: const Color(0xFF030D18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    int nextLvl = gameService.progress.currentLevelId + 1;
                    if (nextLvl <= 3) {
                      gameService.loadLevel(nextLvl);
                    } else {
                      gameService.loadLevel(1);
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    gameService.progress.currentLevelId < 3 ? 'NEXT LEVEL' : 'REPLAY LEVEL 1',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // MAIN MENU
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/main_menu', (route) => false);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('MAIN MENU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
