import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/level_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/rendering/lobby_background_painter.dart';
import 'package:enchanted_forest_adventure/widgets/hero_showcase_widget.dart';
import 'package:enchanted_forest_adventure/ui/game_screen.dart';
import 'package:enchanted_forest_adventure/ui/zombie_intro_screen.dart';
import 'package:enchanted_forest_adventure/ui/level_select_screen.dart';
import 'package:enchanted_forest_adventure/ui/character_shop_screen.dart';
import 'package:enchanted_forest_adventure/ui/settings_overlay.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;
  double _parallaxOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (mounted) {
      setState(() {
        _time += dt;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _openSettings(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SettingsOverlay();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _openLevelSelect(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          onSelectLevel: (lvl) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => GameScreen(initialLevel: lvl)),
            );
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openShop(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CharacterShopScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final lvlController = LevelProgressController.instance;
    final zCtrl = ZombieProgressController.instance;
    final charCtrl = CharacterProgressController.instance;

    final currentLevel = lvlController.highestUnlockedLevel.clamp(1, 10);
    final isNewGame = currentLevel == 1 && lvlController.completedLevels.isEmpty;
    final double campaignProgress = (lvlController.completedLevels.length / 10.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF040817),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _parallaxOffset = (_parallaxOffset + details.delta.dx * 0.4).clamp(-60.0, 60.0);
          });
        },
        child: Stack(
          children: [
            // 1. Cinematic Parallax Background
            CustomPaint(
              size: screenSize,
              painter: LobbyBackgroundPainter(
                time: _time,
                parallaxOffsetX: _parallaxOffset,
              ),
            ),

            // 2. Top Bar HUD (Profile + Campaign Progress + Coins & Settings)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Player Profile & Progress Card
                      ListenableBuilder(
                        listenable: lvlController,
                        builder: (context, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xCC0F172A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Color(0x3338BDF8), blurRadius: 10, spreadRadius: 1),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GameColors.mossyGreenBright,
                                  ),
                                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'HERO ADVENTURER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'Level $currentLevel / 10',
                                          style: const TextStyle(
                                            color: Color(0xFF38BDF8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 60,
                                          height: 5,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: campaignProgress,
                                              backgroundColor: Colors.white12,
                                              valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Right Top Group: Coin Balance + Settings
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListenableBuilder(
                            listenable: charCtrl,
                            builder: (context, _) {
                              return GestureDetector(
                                onTap: () => _openShop(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC0F172A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: GameColors.coinGold, width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x33FFD166), blurRadius: 8),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${charCtrl.totalCoins}',
                                        style: const TextStyle(
                                          color: GameColors.coinGold,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openSettings(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xCC0F172A),
                                  border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: GameColors.playerGlow,
                                      blurRadius: 10,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.settings_rounded,
                                  color: GameColors.uiTextLight,
                                  size: 24,
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
            ),

            // 3. Hero Showcase & Title (Left/Center Side)
            Positioned(
              left: 30,
              top: 80,
              bottom: 20,
              width: screenSize.width * 0.42,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFF80FFDB), Color(0xFF38BDF8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      'ENCHANTED\nFOREST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        height: 1.1,
                        shadows: [
                          Shadow(color: GameColors.playerGlow, blurRadius: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2D FANTASY ADVENTURE',
                    style: TextStyle(
                      color: GameColors.mistBlue,
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Showcase
                  Expanded(
                    child: HeroShowcaseWidget(time: _time),
                  ),
                ],
              ),
            ),

            // 4. Main Menu Action Cards (Right Side)
            Positioned(
              right: 30,
              top: 80,
              bottom: 30,
              width: screenSize.width * 0.46,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Primary Action Card (CONTINUE / START ADVENTURE)
                  _buildPrimaryActionButton(
                    context: context,
                    isNewGame: isNewGame,
                    currentLevel: currentLevel,
                  ),

                  const SizedBox(height: 12),

                  // Zombie Mode Card
                  _buildZombieModeCard(context: context, zCtrl: zCtrl),

                  const SizedBox(height: 12),

                  // Bottom Row: SELECT LEVEL & SHOP Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildLevelSelectButton(context: context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildShopButton(context: context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required BuildContext context,
    required bool isNewGame,
    required int currentLevel,
  }) {
    final titleText = isNewGame ? 'START ADVENTURE' : 'CONTINUE';
    final subtitleText = isNewGame
        ? 'Begin Journey — Level 1'
        : 'Resume Level $currentLevel Adventure';

    return StatefulBuilder(
      builder: (context, setState) {
        double scale = 1.0;

        return Listener(
          onPointerDown: (_) => setState(() => scale = 0.95),
          onPointerUp: (_) => setState(() => scale = 1.0),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8810B981),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(initialLevel: currentLevel),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              titleText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              subtitleText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZombieModeCard({
    required BuildContext context,
    required ZombieProgressController zCtrl,
  }) {
    return ListenableBuilder(
      listenable: zCtrl,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xEE0F070B),
              border: Border.all(color: const Color(0xFFFF3333), width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FF3333),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ZombieIntroScreen()),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.coronavirus_rounded, color: Color(0xFFFF4D4D), size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ZOMBIE MODE',
                          style: TextStyle(
                            color: Color(0xFFFF4D4D),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Wave ${zCtrl.highestWaveCompleted}  •  ${zCtrl.totalZombiesDefeated} Defeated',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF4D4D), size: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelSelectButton({required BuildContext context}) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: GameColors.uiTextLight,
          backgroundColor: const Color(0xCC0F172A),
          side: const BorderSide(color: GameColors.playerGlow, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _openLevelSelect(context),
        icon: const Icon(Icons.grid_view_rounded, size: 20, color: GameColors.foliageGlow),
        label: const Text(
          'LEVELS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildShopButton({required BuildContext context}) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF854D0E), Color(0xFFCA8A04)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66EAB308),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _openShop(context),
          icon: const Icon(Icons.shopping_bag_rounded, size: 20, color: Colors.white),
          label: const Text(
            '🛒 SHOP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
