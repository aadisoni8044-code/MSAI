import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  final VoidCallback onStart;

  const StartScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF030712),
            Color(0xFF0F2C3E),
            Color(0xFF064E3B),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Title Glow Badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F766E).withOpacity(0.3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF2DD4BF),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.forest_rounded,
                  color: Color(0xFF5EEAD4),
                  size: 72,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "FORESTBOUND",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(color: Color(0xFF0D9488), blurRadius: 16),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "2D Side-Scrolling Fantasy Adventure",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF99F6E4),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 40),

              // Control Instructions Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x990F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: const Column(
                  children: [
                    Text(
                      "CONTROLS",
                      style: TextStyle(
                        color: Color(0xFF5EEAD4),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ControlHint(icon: Icons.swap_horiz_rounded, text: "Move"),
                        _ControlHint(icon: Icons.arrow_upward_rounded, text: "Jump"),
                        _ControlHint(icon: Icons.colorize_rounded, text: "Attack"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Start Game Button
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: 220,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6610B981),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          "START GAME",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
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

class _ControlHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ControlHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
        ),
      ],
    );
  }
}
