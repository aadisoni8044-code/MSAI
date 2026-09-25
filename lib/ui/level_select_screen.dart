import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/level_progress_controller.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';

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

  static const List<Map<String, dynamic>> _themeTemplates = [
    {
      'theme': LevelTheme.forest,
      'name': 'Forest',
      'icon': Icons.park_rounded,
      'gradient': [Color(0xFF0F382C), Color(0xFF1B5E4A)],
      'accent': Color(0xFF72EFDD),
    },
    {
      'theme': LevelTheme.fire,
      'name': 'Fire',
      'icon': Icons.local_fire_department_rounded,
      'gradient': [Color(0xFF4A1009), Color(0xFF8B2516)],
      'accent': Color(0xFFFF6B6B),
    },
    {
      'theme': LevelTheme.water,
      'name': 'Water',
      'icon': Icons.water_drop_rounded,
      'gradient': [Color(0xFF0D2847), Color(0xFF1B4978)],
      'accent': Color(0xFF4EA8DE),
    },
    {
      'theme': LevelTheme.ice,
      'name': 'Ice',
      'icon': Icons.ac_unit_rounded,
      'gradient': [Color(0xFF133240), Color(0xFF28586E)],
      'accent': Color(0xFF90E0EF),
    },
    {
      'theme': LevelTheme.desert,
      'name': 'Desert',
      'icon': Icons.wb_sunny_rounded,
      'gradient': [Color(0xFF4D2B0B), Color(0xFF824D1B)],
      'accent': Color(0xFFFFD166),
    },
    {
      'theme': LevelTheme.thunder,
      'name': 'Thunder',
      'icon': Icons.flash_on_rounded,
      'gradient': [Color(0xFF281338), Color(0xFF4E266B)],
      'accent': Color(0xFFC77DFF),
    },
    {
      'theme': LevelTheme.poison,
      'name': 'Poison',
      'icon': Icons.coronavirus_rounded,
      'gradient': [Color(0xFF251030), Color(0xFF432052)],
      'accent': Color(0xFF00F5D4),
    },
    {
      'theme': LevelTheme.sky,
      'name': 'Sky',
      'icon': Icons.cloud_rounded,
      'gradient': [Color(0xFF123B59), Color(0xFF286A9C)],
      'accent': Color(0xFFBEE9E8),
    },
    {
      'theme': LevelTheme.shadow,
      'name': 'Shadow',
      'icon': Icons.nights_stay_rounded,
      'gradient': [Color(0xFF0B0D19), Color(0xFF181C33)],
      'accent': Color(0xFF9B5DE5),
    },
    {
      'theme': LevelTheme.crystal,
      'name': 'Crystal',
      'icon': Icons.diamond_rounded,
      'gradient': [Color(0xFF33113B), Color(0xFF6B267B)],
      'accent': Color(0xFFF72585),
    },
  ];

  Map<String, dynamic> _getMetaForLevel(int lvlNum) {
    int templateIndex = (lvlNum - 1) % 10;
    final template = _themeTemplates[templateIndex];
    return {
      'num': lvlNum,
      'formattedNum': lvlNum < 10 ? '0$lvlNum' : '$lvlNum',
      'name': template['name'],
      'icon': template['icon'],
      'gradient': template['gradient'],
      'accent': template['accent'],
    };
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GameColors.uiGlassBorder),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SELECT LEVEL (1 - 200)',
                      style: TextStyle(
                        color: GameColors.uiTextLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(color: GameColors.portalGlow, blurRadius: 10),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameColors.uiGlassBorder),
                      ),
                      child: Text(
                        'Completed: ${_progressController.completedLevels.length}/200',
                        style: const TextStyle(
                          color: GameColors.uiTextGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Level Grid (200 Levels)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 170.0,
                    mainAxisExtent: 110.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 200,
                  itemBuilder: (context, index) {
                    final int lvlNum = index + 1;
                    final meta = _getMetaForLevel(lvlNum);
                    final bool isCompleted = _progressController.isCompleted(lvlNum);

                    return _buildLevelCard(
                      meta: meta,
                      isCompleted: isCompleted,
                      onTap: () {
                        widget.onSelectLevel(lvlNum);
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                        color: accentColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2EC4B6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.black, size: 12),
                      )
                    else
                      Icon(Icons.play_arrow_rounded, color: accentColor, size: 18),
                  ],
                ),

                // Center Icon
                Icon(
                  icon,
                  size: 26,
                  color: accentColor,
                ),

                // Bottom Title
                Text(
                  meta['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
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
