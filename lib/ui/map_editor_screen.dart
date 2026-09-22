import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/custom_map_progress_controller.dart';
import 'package:enchanted_forest_adventure/models/custom_map_data.dart';
import 'package:enchanted_forest_adventure/widgets/character_preview_widget.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/ui/custom_map_game_screen.dart';

enum EditorCategory {
  terrain,
  platforms,
  enemies,
  items,
  hazards,
  decor,
  special,
  themes,
  actions,
}

class MapEditorScreen extends StatefulWidget {
  final CustomMapData mapData;

  const MapEditorScreen({
    super.key,
    required this.mapData,
  });

  @override
  State<MapEditorScreen> createState() => _MapEditorScreenState();
}

class _MapEditorScreenState extends State<MapEditorScreen> {
  late CustomMapData _map;
  EditorCategory _activeCategory = EditorCategory.platforms;
  String _activeToolType = 'platform_medium'; // Selected tool to place
  bool _gridSnap = true;
  double _gridSize = 20.0;

  // Viewport / Pan offset
  double _scrollX = 0.0;
  double _scrollY = 0.0;

  // Selection
  String? _selectedEntityId;
  bool _isDraggingEntity = false;
  Offset _dragOffset = Offset.zero;

  // Notification Toast
  String? _messageText;
  bool _isSuccessMessage = true;

  // Undo / Redo History Stack
  final List<List<CustomMapEntity>> _undoStack = [];
  final List<List<CustomMapEntity>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _map = widget.mapData;
    _saveHistoryState();
  }

  void _saveHistoryState() {
    if (_undoStack.length > 25) {
      _undoStack.removeAt(0);
    }
    _undoStack.add(_map.entities.map((e) => e.copyWith()).toList());
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.length > 1) {
      _redoStack.add(_undoStack.removeLast());
      final previous = _undoStack.last;
      setState(() {
        _map.entities = previous.map((e) => e.copyWith()).toList();
        _selectedEntityId = null;
      });
      _showMessage('Undo applied', success: true);
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final next = _redoStack.removeLast();
      _undoStack.add(next.map((e) => e.copyWith()).toList());
      setState(() {
        _map.entities = next.map((e) => e.copyWith()).toList();
        _selectedEntityId = null;
      });
      _showMessage('Redo applied', success: true);
    }
  }

  void _showMessage(String message, {bool success = true}) {
    setState(() {
      _messageText = message;
      _isSuccessMessage = success;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _messageText == message) {
        setState(() {
          _messageText = null;
        });
      }
    });
  }

  bool _validateMap() {
    // 1. Check Player Start
    if (_map.playerStartX < 0 || _map.playerStartX > _map.worldWidth) {
      _showMessage('⚠️ Add or adjust Player Start position!', success: false);
      return false;
    }
    // 2. Check Finish Portal
    if (_map.finishX < 0 || _map.finishX > _map.worldWidth) {
      _showMessage('⚠️ Add a Finish Point before playing this map!', success: false);
      return false;
    }
    // 3. Check platforms / ground exist
    final hasPlatforms = _map.entities.any((e) => e.type.contains('platform') || e.type.contains('ground'));
    if (!hasPlatforms) {
      _showMessage('⚠️ Add at least one Platform or Ground before playing!', success: false);
      return false;
    }
    return true;
  }

  Future<void> _saveMap() async {
    await CustomMapProgressController.instance.saveMap(_map);
    _showMessage('✨ Map "${_map.name}" saved successfully!', success: true);
  }

  void _testPlayMap() async {
    if (!_validateMap()) return;
    await _saveMap();

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomMapGameScreen(mapData: _map),
      ),
    );
  }

  void _openRenameDialog() {
    final controller = TextEditingController(text: _map.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rename Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Map Name',
              labelStyle: const TextStyle(color: Color(0xFF38BDF8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF38BDF8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF80FFDB), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _map.name = newName;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('RENAME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _addNewEntity(Offset canvasPosition) {
    double x = canvasPosition.dx + _scrollX;
    double y = canvasPosition.dy + _scrollY;

    if (_gridSnap) {
      x = (x / _gridSize).round() * _gridSize;
      y = (y / _gridSize).round() * _gridSize;
    }

    // Special tools handling
    if (_activeToolType == 'special_player_start') {
      setState(() {
        _map.playerStartX = x;
        _map.playerStartY = y;
      });
      _showMessage('Player Start set to (${x.toInt()}, ${y.toInt()})');
      return;
    } else if (_activeToolType == 'special_finish') {
      setState(() {
        _map.finishX = x;
        _map.finishY = y;
      });
      _showMessage('Finish Portal set to (${x.toInt()}, ${y.toInt()})');
      return;
    }

    // Map tool string to Entity details
    final String entityId = 'ent_${DateTime.now().microsecondsSinceEpoch}';
    late double width;
    late double height;
    late String entityType;

    switch (_activeToolType) {
      // Ground & Terrain
      case 'ground_grass':
        entityType = 'platform';
        width = 400;
        height = 100;
        break;
      case 'ground_dirt':
        entityType = 'platform';
        width = 400;
        height = 100;
        break;
      case 'ground_stone':
        entityType = 'platform';
        width = 400;
        height = 100;
        break;

      // Platforms
      case 'platform_small':
        entityType = 'platform';
        width = 120;
        height = 28;
        break;
      case 'platform_medium':
        entityType = 'platform';
        width = 180;
        height = 28;
        break;
      case 'platform_large':
        entityType = 'platform';
        width = 260;
        height = 28;
        break;
      case 'platform_moving':
        entityType = 'movingPlatform';
        width = 140;
        height = 28;
        break;
      case 'platform_slippery':
        entityType = 'slipperyPlatform';
        width = 180;
        height = 28;
        break;

      // Enemies
      case 'enemy_slime':
        entityType = 'enemySlime';
        width = 36;
        height = 32;
        break;
      case 'enemy_shadow':
        entityType = 'enemyShadow';
        width = 40;
        height = 44;
        break;
      case 'enemy_fire':
        entityType = 'enemyFire';
        width = 40;
        height = 40;
        break;
      case 'enemy_ice':
        entityType = 'enemyIce';
        width = 40;
        height = 40;
        break;
      case 'enemy_toxic':
        entityType = 'enemyToxic';
        width = 40;
        height = 40;
        break;

      // Items & Collectibles
      case 'item_coin':
        entityType = 'coin';
        width = 22;
        height = 22;
        break;
      case 'item_health_pot':
        entityType = 'healthPot';
        width = 24;
        height = 28;
        break;
      case 'item_checkpoint':
        entityType = 'checkpoint';
        width = 44;
        height = 60;
        break;

      // Hazards
      case 'hazard_spike':
        entityType = 'hazardSpike';
        width = 80;
        height = 20;
        break;
      case 'hazard_lava':
        entityType = 'hazardLava';
        width = 300;
        height = 60;
        break;
      case 'hazard_poison':
        entityType = 'hazardPoison';
        width = 300;
        height = 60;
        break;
      case 'hazard_lightning':
        entityType = 'hazardLightning';
        width = 100;
        height = 24;
        break;

      // Decor
      case 'decor_tree':
        entityType = 'decorTree';
        width = 80;
        height = 120;
        break;
      case 'decor_rock':
        entityType = 'decorRock';
        width = 50;
        height = 30;
        break;
      case 'decor_bush':
        entityType = 'decorBush';
        width = 60;
        height = 36;
        break;
      case 'decor_flower':
        entityType = 'decorFlower';
        width = 28;
        height = 28;
        break;
      case 'decor_crystal':
        entityType = 'decorCrystal';
        width = 32;
        height = 44;
        break;
      case 'decor_ruin':
        entityType = 'decorRuin';
        width = 70;
        height = 80;
        break;
      case 'decor_lamp':
        entityType = 'decorLamp';
        width = 28;
        height = 60;
        break;
      case 'decor_sign':
        entityType = 'decorSign';
        width = 32;
        height = 38;
        break;

      default:
        entityType = 'platform';
        width = 180;
        height = 28;
    }

    final newEntity = CustomMapEntity(
      id: entityId,
      type: entityType,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    setState(() {
      _map.entities.add(newEntity);
      _selectedEntityId = entityId;
    });
    _saveHistoryState();
  }

  void _deleteSelectedEntity() {
    if (_selectedEntityId != null) {
      setState(() {
        _map.entities.removeWhere((e) => e.id == _selectedEntityId);
        _selectedEntityId = null;
      });
      _saveHistoryState();
      _showMessage('Object deleted');
    }
  }

  void _duplicateSelectedEntity() {
    if (_selectedEntityId != null) {
      final existing = _map.entities.firstWhere((e) => e.id == _selectedEntityId);
      final newId = 'ent_${DateTime.now().microsecondsSinceEpoch}';
      final duplicate = existing.copyWith(
        id: newId,
        x: existing.x + 30,
        y: existing.y + 30,
      );
      setState(() {
        _map.entities.add(duplicate);
        _selectedEntityId = newId;
      });
      _saveHistoryState();
      _showMessage('Object duplicated');
    }
  }

  Color _getThemeBgColor() {
    switch (_map.theme) {
      case 'fire':
        return const Color(0xFF1E0B0B);
      case 'water':
        return const Color(0xFF071B26);
      case 'ice':
        return const Color(0xFF0A202D);
      case 'desert':
        return const Color(0xFF23170B);
      case 'thunder':
        return const Color(0xFF130E26);
      case 'poison':
        return const Color(0xFF0B1E13);
      case 'sky':
        return const Color(0xFF0F1E36);
      case 'shadow':
        return const Color(0xFF090B12);
      case 'crystal':
        return const Color(0xFF180A26);
      case 'forest':
      default:
        return const Color(0xFF040C1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _getThemeBgColor(),
      body: Stack(
        children: [
          // 1. Interactive Canvas Area
          GestureDetector(
            onPanUpdate: (details) {
              if (_isDraggingEntity && _selectedEntityId != null) {
                final idx = _map.entities.indexWhere((e) => e.id == _selectedEntityId);
                if (idx >= 0) {
                  double newX = _map.entities[idx].x + details.delta.dx;
                  double newY = _map.entities[idx].y + details.delta.dy;
                  if (_gridSnap) {
                    newX = (newX / _gridSize).round() * _gridSize;
                    newY = (newY / _gridSize).round() * _gridSize;
                  }
                  setState(() {
                    _map.entities[idx].x = newX.clamp(0, _map.worldWidth);
                    _map.entities[idx].y = newY.clamp(0, _map.worldHeight);
                  });
                }
              } else {
                setState(() {
                  _scrollX = (_scrollX - details.delta.dx).clamp(0.0, max(0.0, _map.worldWidth - screenSize.width));
                  _scrollY = (_scrollY - details.delta.dy).clamp(0.0, max(0.0, _map.worldHeight - screenSize.height));
                });
              }
            },
            onPanEnd: (_) {
              if (_isDraggingEntity) {
                _isDraggingEntity = false;
                _saveHistoryState();
              }
            },
            onTapDown: (details) {
              final localPos = details.localPosition;
              final worldX = localPos.dx + _scrollX;
              final worldY = localPos.dy + _scrollY;

              // Check if tapped an existing entity
              for (int i = _map.entities.length - 1; i >= 0; i--) {
                final e = _map.entities[i];
                final rect = Rect.fromLTWH(e.x, e.y, e.width, e.height);
                if (rect.contains(Offset(worldX, worldY))) {
                  setState(() {
                    _selectedEntityId = e.id;
                    _isDraggingEntity = true;
                  });
                  return;
                }
              }

              // Check Player Start marker tap
              final pStartRect = Rect.fromLTWH(_map.playerStartX - 20, _map.playerStartY - 40, 40, 60);
              if (pStartRect.contains(Offset(worldX, worldY))) {
                _showMessage('🎯 Player Start Marker');
                return;
              }

              // Check Finish Portal marker tap
              final finishRect = Rect.fromLTWH(_map.finishX - 30, _map.finishY - 60, 60, 90);
              if (finishRect.contains(Offset(worldX, worldY))) {
                _showMessage('🏁 Finish Portal Marker');
                return;
              }

              // Tapped blank canvas -> Place new entity with active tool
              _addNewEntity(localPos);
            },
            child: CustomPaint(
              size: screenSize,
              painter: MapEditorCanvasPainter(
                map: _map,
                scrollX: _scrollX,
                scrollY: _scrollY,
                selectedEntityId: _selectedEntityId,
                gridSnap: _gridSnap,
                gridSize: _gridSize,
              ),
            ),
          ),

          // 2. Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xDD0F172A),
                border: Border(bottom: BorderSide(color: GameColors.uiGlassBorder, width: 1.2)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(width: 8),

                    // Map Name Title & Rename Button
                    GestureDetector(
                      onTap: _openRenameDialog,
                      child: Row(
                        children: [
                          Text(
                            _map.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_rounded, color: Color(0xFF38BDF8), size: 16),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Grid Snap Toggle Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _gridSnap ? const Color(0x4438BDF8) : Colors.transparent,
                        side: BorderSide(color: _gridSnap ? const Color(0xFF38BDF8) : Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        setState(() {
                          _gridSnap = !_gridSnap;
                        });
                        _showMessage(_gridSnap ? 'Grid Snap ON (20px)' : 'Grid Snap OFF');
                      },
                      icon: Icon(Icons.grid_on_rounded, size: 16, color: _gridSnap ? const Color(0xFF38BDF8) : Colors.white54),
                      label: Text(
                        _gridSnap ? 'GRID ON' : 'GRID OFF',
                        style: TextStyle(
                          color: _gridSnap ? const Color(0xFF38BDF8) : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Undo / Redo Buttons
                    IconButton(
                      icon: const Icon(Icons.undo_rounded, color: Colors.white, size: 20),
                      onPressed: _undoStack.length > 1 ? _undo : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo_rounded, color: Colors.white, size: 20),
                      onPressed: _redoStack.isNotEmpty ? _redo : null,
                    ),

                    const SizedBox(width: 8),

                    // Save Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveMap,
                      icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'SAVE',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Test / Play Map Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _testPlayMap,
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'PLAY TEST',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Toolbar for Selected Entity (Delete / Duplicate / Move)
          if (_selectedEntityId != null)
            Positioned(
              top: 75,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xEE0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x4438BDF8), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('OBJECT SELECTED', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF80FFDB), size: 18),
                      onPressed: _duplicateSelectedEntity,
                      tooltip: 'Duplicate',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF4D4D), size: 18),
                      onPressed: _deleteSelectedEntity,
                      tooltip: 'Delete',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                      onPressed: () => setState(() => _selectedEntityId = null),
                      tooltip: 'Deselect',
                    ),
                  ],
                ),
              ),
            ),

          // 4. Toast Notification
          if (_messageText != null)
            Positioned(
              top: 75,
              left: screenSize.width * 0.25,
              right: screenSize.width * 0.25,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isSuccessMessage ? const Color(0xEE065F46) : const Color(0xEE991B1B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSuccessMessage ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _messageText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // 5. Bottom Palette Drawer Tools
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xEE0F172A),
                border: Border(top: BorderSide(color: GameColors.uiGlassBorder, width: 1.5)),
              ),
              child: Column(
                children: [
                  // Category Tabs Bar
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      children: [
                        _buildCategoryTab('🧱 PLATFORMS', EditorCategory.platforms),
                        _buildCategoryTab('🪵 TERRAIN', EditorCategory.terrain),
                        _buildCategoryTab('👾 ENEMIES', EditorCategory.enemies),
                        _buildCategoryTab('💰 ITEMS', EditorCategory.items),
                        _buildCategoryTab('⚠️ HAZARDS', EditorCategory.hazards),
                        _buildCategoryTab('🌲 DECOR', EditorCategory.decor),
                        _buildCategoryTab('🎯 SPECIAL', EditorCategory.special),
                        _buildCategoryTab('🎨 THEMES', EditorCategory.themes),
                        _buildCategoryTab('🛠 ACTIONS', EditorCategory.actions),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Colors.white12),

                  // Active Category Objects Ribbon
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: _buildActiveCategoryTools(),
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

  Widget _buildCategoryTab(String title, EditorCategory category) {
    final isSelected = _activeCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActiveCategoryTools() {
    switch (_activeCategory) {
      case EditorCategory.platforms:
        return [
          _buildToolChip('Small Plat', 'platform_small', Icons.horizontal_rule_rounded),
          _buildToolChip('Medium Plat', 'platform_medium', Icons.horizontal_rule_rounded),
          _buildToolChip('Large Plat', 'platform_large', Icons.horizontal_rule_rounded),
          _buildToolChip('Moving Plat', 'platform_moving', Icons.swap_horiz_rounded),
          _buildToolChip('Slippery Ice', 'platform_slippery', Icons.ac_unit_rounded),
        ];

      case EditorCategory.terrain:
        return [
          _buildToolChip('Grass Ground', 'ground_grass', Icons.landscape_rounded),
          _buildToolChip('Dirt Ground', 'ground_dirt', Icons.landscape_rounded),
          _buildToolChip('Stone Ground', 'ground_stone', Icons.landscape_rounded),
        ];

      case EditorCategory.enemies:
        return [
          _buildToolChip('Slime', 'enemy_slime', Icons.bug_report_rounded),
          _buildToolChip('Shadow', 'enemy_shadow', Icons.coronavirus_rounded),
          _buildToolChip('Fire Beast', 'enemy_fire', Icons.local_fire_department_rounded),
          _buildToolChip('Ice Beast', 'enemy_ice', Icons.ac_unit_rounded),
          _buildToolChip('Toxic Beast', 'enemy_toxic', Icons.science_rounded),
        ];

      case EditorCategory.items:
        return [
          _buildToolChip('Gold Coin', 'item_coin', Icons.monetization_on_rounded),
          _buildToolChip('Health Pot', 'item_health_pot', Icons.local_pharmacy_rounded),
          _buildToolChip('Checkpoint', 'item_checkpoint', Icons.flag_rounded),
        ];

      case EditorCategory.hazards:
        return [
          _buildToolChip('Spikes', 'hazard_spike', Icons.warning_amber_rounded),
          _buildToolChip('Lava Pit', 'hazard_lava', Icons.whatshot_rounded),
          _buildToolChip('Poison Mud', 'hazard_poison', Icons.science_rounded),
          _buildToolChip('Lightning', 'hazard_lightning', Icons.flash_on_rounded),
        ];

      case EditorCategory.decor:
        return [
          _buildToolChip('Ancient Tree', 'decor_tree', Icons.park_rounded),
          _buildToolChip('Forest Rock', 'decor_rock', Icons.grain_rounded),
          _buildToolChip('Green Bush', 'decor_bush', Icons.forest_rounded),
          _buildToolChip('Magic Flower', 'decor_flower', Icons.local_florist_rounded),
          _buildToolChip('Crystal Shard', 'decor_crystal', Icons.diamond_rounded),
          _buildToolChip('Ruin Pillars', 'decor_ruin', Icons.account_balance_rounded),
          _buildToolChip('Forest Lamp', 'decor_lamp', Icons.lightbulb_rounded),
          _buildToolChip('Sign Board', 'decor_sign', Icons.signpost_rounded),
        ];

      case EditorCategory.special:
        return [
          _buildToolChip('🎯 Player Start', 'special_player_start', Icons.my_location_rounded),
          _buildToolChip('🏁 Finish Portal', 'special_finish', Icons.sports_score_rounded),
        ];

      case EditorCategory.themes:
        return [
          'forest',
          'fire',
          'water',
          'ice',
          'desert',
          'thunder',
          'poison',
          'sky',
          'shadow',
          'crystal',
        ].map((themeName) {
          final isSelected = _map.theme == themeName;
          return GestureDetector(
            onTap: () {
              setState(() {
                _map.theme = themeName;
              });
              _showMessage('Theme set to ${themeName.toUpperCase()}');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF38BDF8) : const Color(0x330F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.white : Colors.white24),
              ),
              child: Center(
                child: Text(
                  themeName.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList();

      case EditorCategory.actions:
        return [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            onPressed: () {
              setState(() {
                _map.worldWidth += 1200;
              });
              _showMessage('Map width expanded to ${_map.worldWidth.toInt()}px');
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Expand Map Width (+1200px)'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              if (_map.entities.isNotEmpty) {
                setState(() {
                  _map.entities.clear();
                  _selectedEntityId = null;
                });
                _saveHistoryState();
                _showMessage('Cleared all objects');
              }
            },
            icon: const Icon(Icons.delete_sweep_rounded, size: 16),
            label: const Text('Clear All Objects'),
          ),
        ];
    }
  }

  Widget _buildToolChip(String label, String toolType, IconData icon) {
    final isSelected = _activeToolType == toolType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeToolType = toolType;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : const Color(0x440F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF80FFDB) : Colors.white24,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapEditorCanvasPainter extends CustomPainter {
  final CustomMapData map;
  final double scrollX;
  final double scrollY;
  final String? selectedEntityId;
  final bool gridSnap;
  final double gridSize;

  MapEditorCanvasPainter({
    required this.map,
    required this.scrollX,
    required this.scrollY,
    required this.selectedEntityId,
    required this.gridSnap,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-scrollX, -scrollY);

    // 1. Grid Lines
    if (gridSnap) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 1.0;

      for (double x = 0; x < map.worldWidth; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, map.worldHeight), gridPaint);
      }
      for (double y = 0; y < map.worldHeight; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(map.worldWidth, y), gridPaint);
      }
    }

    // 2. Render Map Entities
    for (final e in map.entities) {
      final rect = Rect.fromLTWH(e.x, e.y, e.width, e.height);
      final isSelected = e.id == selectedEntityId;

      late Paint paint;
      if (e.type.contains('platform') || e.type.contains('ground')) {
        paint = Paint()..color = e.type == 'slipperyPlatform' ? const Color(0xFF38BDF8) : const Color(0xFF15803D);
      } else if (e.type.contains('enemy')) {
        paint = Paint()..color = const Color(0xFFEF4444);
      } else if (e.type == 'coin') {
        paint = Paint()..color = GameColors.coinGold;
      } else if (e.type.contains('hazard')) {
        paint = Paint()..color = const Color(0xFFFF3333);
      } else if (e.type.contains('decor')) {
        paint = Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.7);
      } else {
        paint = Paint()..color = const Color(0xFF3B82F6);
      }

      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);

      if (isSelected) {
        final outlinePaint = Paint()
          ..color = const Color(0xFF80FFDB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawRRect(RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(8)), outlinePaint);
      }
    }

    // 3. Render Player Start Marker
    final pStartPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(map.playerStartX, map.playerStartY), 14, pStartPaint);
    final pStartText = TextPainter(
      text: const TextSpan(text: 'START', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    pStartText.paint(canvas, Offset(map.playerStartX - 13, map.playerStartY - 5));

    // 4. Render Finish Portal Marker
    final finishPaint = Paint()..color = const Color(0xFFC77DFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(map.finishX - 20, map.finishY - 50, 40, 70), const Radius.circular(12)),
      finishPaint,
    );
    final finishText = TextPainter(
      text: const TextSpan(text: 'FINISH', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    finishText.paint(canvas, Offset(map.finishX - 16, map.finishY - 20));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MapEditorCanvasPainter oldDelegate) => true;
}
