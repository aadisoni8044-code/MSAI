import 'dart:async';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/ui/main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _timer = Timer(const Duration(seconds: 3), _navigateToMainMenu);
  }

  void _navigateToMainMenu() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainMenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.skyBackground,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    GameColors.mistBlue.withOpacity(0.18),
                    GameColors.skyBackground,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image
                  Image.asset(
                    'assets/images/a.png',
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GameColors.uiPanelBg,
                          border: Border.all(
                            color: GameColors.mistBlue.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.forest_rounded,
                          size: 80,
                          color: GameColors.mistBlue,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ENCHANTED FOREST ADVENTURE',
                    style: TextStyle(
                      color: GameColors.uiTextGold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '2D Mobile Fantasy Action Platformer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GameColors.mistBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
