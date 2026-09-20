import 'package:flutter/material.dart';

class ZombieModeCompletedOverlay extends StatelessWidget {
  final VoidCallback onReplay;
  final VoidCallback onQuit;

  const ZombieModeCompletedOverlay({
    super.key,
    required this.onReplay,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE0B0F19),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD166), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FFD166),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text(
                'ZOMBIE MODE COMPLETED!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '100 Zombies Defeated Across 10 Waves!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x33FFD166),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🏆 You survived the night horde and conquered all 10 zombie waves!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onQuit,
                        child: const Text(
                          'MAIN MENU',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onReplay,
                        child: const Text(
                          'PLAY AGAIN',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
