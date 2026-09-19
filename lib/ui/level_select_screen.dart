import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/level_progress_controller.dart';

class LevelSelectScreen extends StatefulWidget {
  final Function(int levelNumber) onSelectLevel;
  final VoidCallback onBack;

  const LevelSelectScreen({
    super.key,
    required this.onSelectLevel,
    required this.onBack,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final LevelProgressController _progressController = LevelProgressController.instance;

  @override
  void initState() {
    super.initState();
    _progressController.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    _progressController.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  static const List<Map<String, dynamic>> _levelMetaData = [
    {
      'num': 1,
      'formattedNum': '01',
      'name': 'Forest',
      'icon': Icons.park_rounded,
      'gradient': [Color(0xFF0F382C), Color(0xFF1B5E4A)],
      'accent': Color(0xFF72EFDD),
    },
    {
      'num': 2,
      'formattedNum': '02',
      'name': 'Fire',
      'icon': Icons.local_fire_department_rounded,
      'gradient': [Color(0xFF4A1009), Color(0xFF8B2516)],
      'accent': Color(0xFFFF6B6B),
    },
    {
      'num': 3,
      'formattedNum': '03',
      'name': 'Water',
      'icon': Icons.water_drop_rounded,
      'gradient': [Color(0xFF0D2847), Color(0xFF1B4978)],
      'accent': Color(0xFF4EA8DE),
    },
    {
      'num': 4,
      'formattedNum': '04',
      'name': 'Ice',
      'icon': Icons.ac_unit_rounded,
      'gradient': [Color(0xFF133240), Color(0xFF28586E)],
      'accent': Color(0xFF90E0EF),
    },
    {
      'num': 5,
      'formattedNum': '05',
      'name': 'Desert',
      'icon': Icons.wb_sunny_rounded,
      'gradient': [Color(0xFF4D2B0B), Color(0xFF824D1B)],
      'accent': Color(0xFFFFD166),
    },
    {
      'num': 6,
      'formattedNum': '06',
      'name': 'Thunder',
      'icon': Icons.flash_on_rounded,
      'gradient': [Color(0xFF281338), Color(0xFF4E266B)],
      'accent': Color(0xFFC77DFF),
    },
    {
      'num': 7,
      'formattedNum': '07',
      'name': 'Poison',
      'icon': Icons.coronavirus_rounded,
      'gradient': [Color(0xFF251030), Color(0xFF432052)],
      'accent': Color(0xFF00F5D4),
    },
    {
      'num': 8,
      'formattedNum': '08',
      'name': 'Sky',
      'icon': Icons.cloud_rounded,
      'gradient': [Color(0xFF123B59), Color(0xFF286A9C)],
      'accent': Color(0xFFBEE9E8),
    },
    {
      'num': 9,
      'formattedNum': '09',
      'name': 'Shadow',
      'icon': Icons.nights_stay_rounded,
      'gradient': [Color(0xFF0B0D19), Color(0xFF181C33)],
      'accent': Color(0xFF9B5DE5),
    },
    {
      'num': 10,
      'formattedNum': '10',
      'name': 'Crystal',
      'icon': Icons.diamond_rounded,
      'gradient': [Color(0xFF33113B), Color(0xFF6B267B)],
      'accent': Color(0xFFF72585),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameColors.skyBackground,
              GameColors.deepForestTeal,
              GameColors.ancientBarkDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GameColors.uiGlassBorder),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'SELECT LEVEL',
                      style: TextStyle(
                        color: GameColors.uiTextLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(color: GameColors.portalGlow, blurRadius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Level Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 5 : 2,
                    childAspectRatio: isLandscape ? 1.05 : 1.25,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final meta = _levelMetaData[index];
                    final int lvlNum = meta['num'] as int;
                    final bool isUnlocked = _progressController.isUnlocked(lvlNum);
                    final bool isCompleted = _progressController.isCompleted(lvlNum);

                    return _buildLevelCard(
                      meta: meta,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      onTap: () {
                        if (isUnlocked) {
                          widget.onSelectLevel(lvlNum);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Complete Level ${lvlNum - 1} to unlock Level $lvlNum!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        }
                      },
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

  Widget _buildLevelCard({
    required Map<String, dynamic> meta,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final List<Color> gradientColors = meta['gradient'] as List<Color>;
    final Color accentColor = meta['accent'] as Color;
    final IconData icon = meta['icon'] as IconData;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isUnlocked
                  ? gradientColors
                  : [
                      gradientColors[0].withValues(alpha: 0.3),
                      gradientColors[1].withValues(alpha: 0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked ? accentColor.withValues(alpha: 0.8) : Colors.white24,
              width: isUnlocked ? 1.8 : 1.0,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Number + Status Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meta['formattedNum'] as String,
                      style: TextStyle(
                        color: isUnlocked ? accentColor : Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2EC4B6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.black, size: 14),
                      )
                    else if (!isUnlocked)
                      const Icon(Icons.lock_rounded, color: Colors.white38, size: 18)
                    else
                      Icon(Icons.play_arrow_rounded, color: accentColor, size: 20),
                  ],
                ),

                // Center Icon / Visual
                Icon(
                  icon,
                  size: 34,
                  color: isUnlocked ? accentColor : Colors.white24,
                ),

                // Bottom Title
                Text(
                  meta['name'] as String,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
