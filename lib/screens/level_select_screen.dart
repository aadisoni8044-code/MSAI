import 'package:flutter/material.dart';

import '../services/game_service.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();
    final progress = gameService.progress;

    final levels = [
      {'id': 1, 'name': 'Whispering Woods', 'desc': 'Misty foliage and dancing vines'},
      {'id': 2, 'name': 'Forgotten Roots', 'desc': 'Coiled ancient roots in deep indigo'},
      {'id': 3, 'name': 'Ancient Hollow', 'desc': 'Home of the ancient Guardian'},
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF030D18),
              Color(0xFF0F3B3E),
              Color(0xFF082224),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF80FFDB)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SELECT LEVEL',
                      style: TextStyle(
                        color: Color(0xFF80FFDB),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Level Cards List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final lvl = levels[index];
                    final int lvlId = lvl['id'] as int;
                    final bool isUnlocked = progress.unlockedLevels.contains(lvlId);
                    final int stars = progress.levelStars[lvlId] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xCC081F2C) : const Color(0x66081F2C),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFF80FFDB) : Colors.white12,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (isUnlocked)
                            const BoxShadow(color: Color(0x2280FFDB), blurRadius: 12),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Level Number Badge
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked ? const Color(0xFF0F3B3E) : Colors.black26,
                              border: Border.all(
                                color: isUnlocked ? const Color(0xFF80FFDB) : Colors.white24,
                              ),
                            ),
                            child: Center(
                              child: isUnlocked
                                  ? Text(
                                      '$lvlId',
                                      style: const TextStyle(
                                        color: Color(0xFF80FFDB),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Icon(Icons.lock, color: Colors.white38),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Level Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAlignment.start,
                              children: [
                                Text(
                                  lvl['name'] as String,
                                  style: TextStyle(
                                    color: isUnlocked ? Colors.white : Colors.white38,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lvl['desc'] as String,
                                  style: TextStyle(
                                    color: isUnlocked ? Colors.white70 : Colors.white24,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Stars Rating
                                Row(
                                  children: List.generate(3, (starIdx) {
                                    return Icon(
                                      starIdx < stars ? Icons.star : Icons.star_border,
                                      color: starIdx < stars ? const Color(0xFFFFD166) : Colors.white24,
                                      size: 20,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                          // Play Button
                          if (isUnlocked)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF80FFDB),
                                foregroundColor: const Color(0xFF030D18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                gameService.loadLevel(lvlId);
                                Navigator.pushNamed(context, '/game');
                              },
                              child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
