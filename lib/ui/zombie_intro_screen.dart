import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/zombie_audio_controller.dart';
import 'package:enchanted_forest_adventure/ui/zombie_game_screen.dart';

class ZombieIntroScreen extends StatefulWidget {
  const ZombieIntroScreen({super.key});

  @override
  State<ZombieIntroScreen> createState() => _ZombieIntroScreenState();
}

class _ZombieIntroScreenState extends State<ZombieIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    ZombieAudioController.instance.startZombieModeAudio();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startGame();
      }
    });
  }

  void _startGame() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ZombieGameScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030610),
      body: GestureDetector(
        onTap: _startGame,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Dark Fog Background
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Center(
                    child: Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B0000).withValues(alpha: 0.15),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF8B0000),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Zombie Silhouettes & Fog Title
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: _titleAnimation.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.8 + _titleAnimation.value * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.coronavirus_rounded,
                            color: Color(0xFFFF3333),
                            size: 72,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'ZOMBIE MODE',
                            style: TextStyle(
                              color: Color(0xFFFF4D4D),
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(color: Color(0xFFFF0000), blurRadius: 20),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'THE HORDE IS HUNTING YOU...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Skip Hint
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white60, size: 20),
                    label: const Text(
                      'SKIP',
                      style: TextStyle(color: Colors.white60, letterSpacing: 1.5),
                    ),
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
