import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/custom_map_progress_controller.dart';
import 'package:enchanted_forest_adventure/models/custom_map_data.dart';
import 'package:enchanted_forest_adventure/ui/map_editor_screen.dart';
import 'package:enchanted_forest_adventure/ui/custom_map_game_screen.dart';

class CreateMapHomeScreen extends StatefulWidget {
  const CreateMapHomeScreen({super.key});

  @override
  State<CreateMapHomeScreen> createState() => _CreateMapHomeScreenState();
}

class _CreateMapHomeScreenState extends State<CreateMapHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCreateNewMap() async {
    final newMap = await CustomMapProgressController.instance.createNewBlankMap(
      name: 'My New Adventure',
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapEditorScreen(mapData: newMap),
      ),
    );
  }

  void _openEditor(CustomMapData map) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapEditorScreen(mapData: map),
      ),
    );
  }

  void _playMap(CustomMapData map) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomMapGameScreen(mapData: map),
      ),
    );
  }

  void _editTemplate(CustomMapData templateMap) async {
    final userCopy = await CustomMapProgressController.instance.duplicateTemplateAsNewMap(
      templateMap,
      customName: 'My ${templateMap.name}',
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapEditorScreen(mapData: userCopy),
      ),
    );
  }

  void _confirmDeleteMap(CustomMapData map) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Map?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete "${map.name}"? This action cannot be undone.',
              style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3333),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                CustomMapProgressController.instance.deleteMap(map.id);
                Navigator.of(context).pop();
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapCtrl = CustomMapProgressController.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF040817),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF070C1A),
                  Color(0xFF02040A),
                ],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back to Lobby
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0F172A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'LOBBY',
                                style: TextStyle(
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

                      // Screen Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF80FFDB), Color(0xFF38BDF8), Color(0xFFEAB308)],
                        ).createShader(bounds),
                        child: const Text(
                          'CREATE MAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),

                      // Create New Map Primary Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: _onCreateNewMap,
                        icon: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'CREATE NEW MAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Tabs Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GameColors.uiGlassBorder, width: 1.2),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF38BDF8),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF38BDF8),
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
                    tabs: const [
                      Tab(text: '🗺 MY MAPS'),
                      Tab(text: '⭐ FEATURED TEMPLATES'),
                    ],
                  ),
                ),

                // Tab Views Content
                Expanded(
                  child: ListenableBuilder(
                    listenable: mapCtrl,
                    builder: (context, _) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: My Custom Maps
                          _buildMyMapsGrid(mapCtrl.userMaps),

                          // Tab 2: Featured Templates
                          _buildTemplatesGrid(mapCtrl.templates),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMapsGrid(List<CustomMapData> maps) {
    if (maps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 64, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'No Custom Maps Created Yet',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "CREATE NEW MAP" or pick a template to build your first level!',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
              onPressed: _onCreateNewMap,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('BUILD A NEW MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.35,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: maps.length,
      itemBuilder: (context, index) {
        final map = maps[index];
        return _buildMapCard(
          map: map,
          isTemplate: false,
          onPlay: () => _playMap(map),
          onEdit: () => _openEditor(map),
          onDelete: () => _confirmDeleteMap(map),
        );
      },
    );
  }

  Widget _buildTemplatesGrid(List<CustomMapData> templates) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.15,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final templateMap = templates[index];
        return _buildMapCard(
          map: templateMap,
          isTemplate: true,
          onPlay: () => _playMap(templateMap),
          onEdit: () => _editTemplate(templateMap),
          onDelete: null,
        );
      },
    );
  }

  Widget _buildMapCard({
    required CustomMapData map,
    required bool isTemplate,
    required VoidCallback onPlay,
    required VoidCallback onEdit,
    VoidCallback? onDelete,
  }) {
    Color themeAccent;
    switch (map.theme) {
      case 'fire':
        themeAccent = const Color(0xFFEF4444);
        break;
      case 'water':
        themeAccent = const Color(0xFF0EA5E9);
        break;
      case 'ice':
        themeAccent = const Color(0xFF38BDF8);
        break;
      case 'desert':
        themeAccent = const Color(0xFFF59E0B);
        break;
      case 'thunder':
        themeAccent = const Color(0xFFA855F7);
        break;
      case 'poison':
        themeAccent = const Color(0xFF10B981);
        break;
      case 'sky':
        themeAccent = const Color(0xFF60A5FA);
        break;
      case 'shadow':
        themeAccent = const Color(0xFF8B5CF6);
        break;
      case 'crystal':
        themeAccent = const Color(0xFFEC4899);
        break;
      case 'forest':
      default:
        themeAccent = const Color(0xFF22C55E);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: themeAccent.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: themeAccent.withValues(alpha: 0.2), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Theme Badge & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  map.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: themeAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeAccent, width: 1),
                ),
                child: Text(
                  map.theme.toUpperCase(),
                  style: TextStyle(
                    color: themeAccent,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Subtitle / Object Count & Stats
          Text(
            '${map.entities.length} Objects  •  ${map.worldWidth.toInt()}px Width',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),

          if (!isTemplate && map.isCompleted) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: GameColors.coinGold, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Best: ${map.bestTimeSeconds?.toStringAsFixed(1)}s  |  Coins: ${map.highestCoinsCollected}',
                  style: const TextStyle(color: GameColors.coinGold, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],

          const Spacer(),

          // Action Buttons
          Row(
            children: [
              // Play Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                  label: const Text('PLAY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(width: 6),

              // Edit Button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF38BDF8), size: 14),
                  label: Text(
                    isTemplate ? 'COPY & EDIT' : 'EDIT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF4D4D), size: 18),
                  onPressed: onDelete,
                  tooltip: 'Delete Map',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
