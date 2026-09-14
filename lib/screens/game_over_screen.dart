import 'package:flutter/material.dart';

import '../services/game_service.dart';

class GameOverScreen extends StatelessWidget {
  final GameService gameService;
  final VoidCallback onRetry;

  const GameOverScreen({
    super.key,
    required this.gameService,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xEE1F080C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEF476F), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x88EF476F), blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_very_dissatisfied, color: Color(0xFFEF476F), size: 56),
              const SizedBox(height: 12),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFEF476F),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The forest shadows consumed your energy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // RETRY CHECKPOINT
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF476F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'RESPAWN AT CHECKPOINT',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
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
                    foregroundColor: Colors.white70,
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
}
