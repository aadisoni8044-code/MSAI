import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/custom_map_progress_controller.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/models/custom_map_data.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/rendering/character_render_helper.dart';
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

enum ResizeHandle {
  none,
  topLeft, // A
  topRight, // B
  bottomRight, // C
  bottomLeft, // D
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

class _MapEditorScreenState extends State<MapEditorScreen> with SingleTickerProviderStateMixin {
  late CustomMapData _map;
  EditorCategory _activeCategory = EditorCategory.platforms;
  String _activeToolType = 'platform_medium';
  bool _gridSnap = true;
  double _gridSize = 20.0;

  // Viewport / Pan offset
  double _scrollX = 0.0;
  double _scrollY = 0.0;

  // Live Animation Ticker for 60 FPS game-world preview
  late Ticker _ticker;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;

  // Selection & Manipulation
  String? _selectedEntityId;
  bool _isDraggingEntity = false;
  ResizeHandle _activeResizeHandle = ResizeHandle.none;

  // Bottom Toolbar Panel Collapse
  bool _isToolbarCollapsed = false;

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
    if (_map.playerStartX < 0 || _map.playerStartX > _map.worldWidth) {
      _showMessage('⚠️ Add or adjust Player Start position!', success: false);
      return false;
    }
    if (_map.finishX < 0 || _map.finishX > _map.worldWidth) {
      _showMessage('⚠️ Add a Finish Point before playing this map!', success: false);
      return false;
    }
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

    final String entityId = 'ent_${DateTime.now().microsecondsSinceEpoch}';
    late double width;
    late double height;
    late String entityType;

    switch (_activeToolType) {
      case 'ground_grass':
      case 'ground_dirt':
      case 'ground_stone':
        entityType = 'platform';
        width = 400;
        height = 100;
        break;

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
      _showMessage('Object duplicated & selected');
    }
  }

  ResizeHandle _hitTestResizeHandles(CustomMapEntity e, Offset worldPos) {
    const double handleRadius = 24.0; // Touch hit area
    final Rect rect = Rect.fromLTWH(e.x, e.y, e.width, e.height);

    final handleA = Offset(rect.left, rect.top);
    final handleB = Offset(rect.right, rect.top);
    final handleC = Offset(rect.right, rect.bottom);
    final handleD = Offset(rect.left, rect.bottom);

    if ((worldPos - handleA).distance <= handleRadius) return ResizeHandle.topLeft;
    if ((worldPos - handleB).distance <= handleRadius) return ResizeHandle.topRight;
    if ((worldPos - handleC).distance <= handleRadius) return ResizeHandle.bottomRight;
    if ((worldPos - handleD).distance <= handleRadius) return ResizeHandle.bottomLeft;

    return ResizeHandle.none;
  }

  void _performHandleResize(CustomMapEntity e, Offset delta) {
    double x = e.x;
    double y = e.y;
    double w = e.width;
    double h = e.height;

    switch (_activeResizeHandle) {
      case ResizeHandle.topLeft: // A
        x += delta.dx;
        y += delta.dy;
        w -= delta.dx;
        h -= delta.dy;
        break;
      case ResizeHandle.topRight: // B
        y += delta.dy;
        w += delta.dx;
        h -= delta.dy;
        break;
      case ResizeHandle.bottomRight: // C
        w += delta.dx;
        h += delta.dy;
        break;
      case ResizeHandle.bottomLeft: // D
        x += delta.dx;
        w -= delta.dx;
        h += delta.dy;
        break;
      case ResizeHandle.none:
        return;
    }

    if (w < 20) w = 20;
    if (h < 15) h = 15;

    if (_gridSnap) {
      x = (x / _gridSize).round() * _gridSize;
      y = (y / _gridSize).round() * _gridSize;
      w = (w / _gridSize).round() * _gridSize;
      h = (h / _gridSize).round() * _gridSize;
      if (w < 20) w = 20;
      if (h < 20) h = 20;
    }

    e.x = x.clamp(0, _map.worldWidth - 20);
    e.y = y.clamp(0, _map.worldHeight - 20);
    e.width = w;
    e.height = h;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final selectedCharacter = CharacterProgressController.instance.selectedCharacter;
    final selectedEntity = _selectedEntityId != null
        ? _map.entities.cast<CustomMapEntity?>().firstWhere((e) => e?.id == _selectedEntityId, orElse: () => null)
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar
            _buildTopNavBar(),

            // 2. Middle Interactive Map Canvas Area
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onPanDown: (details) {
                      final localPos = details.localPosition;
                      final worldPos = Offset(localPos.dx + _scrollX, localPos.dy + _scrollY);

                      // Check if tapped a resize handle on the selected entity
                      if (selectedEntity != null) {
                        final handle = _hitTestResizeHandles(selectedEntity, worldPos);
                        if (handle != ResizeHandle.none) {
                          _activeResizeHandle = handle;
                          _isDraggingEntity = false;
                          return;
                        }
                      }

                      // Check if tapped an existing entity
                      for (int i = _map.entities.length - 1; i >= 0; i--) {
                        final e = _map.entities[i];
                        final rect = Rect.fromLTWH(e.x, e.y, e.width, e.height);
                        if (rect.contains(worldPos)) {
                          setState(() {
                            _selectedEntityId = e.id;
                            _isDraggingEntity = true;
                            _activeResizeHandle = ResizeHandle.none;
                          });
                          return;
                        }
                      }

                      // Check Player Start marker tap
                      final pStartRect = Rect.fromLTWH(_map.playerStartX - 25, _map.playerStartY - 50, 50, 70);
                      if (pStartRect.contains(worldPos)) {
                        _showMessage('🎯 Player Start Position');
                        return;
                      }

                      // Check Finish Portal marker tap
                      final finishRect = Rect.fromLTWH(_map.finishX - 30, _map.finishY - 60, 60, 90);
                      if (finishRect.contains(worldPos)) {
                        _showMessage('🏁 Finish Portal Position');
                        return;
                      }

                      // Tapped blank canvas -> Deselect or place new entity
                      if (_selectedEntityId != null) {
                        setState(() {
                          _selectedEntityId = null;
                        });
                      } else {
                        _addNewEntity(localPos);
                      }
                    },
                    onPanUpdate: (details) {
                      if (selectedEntity != null && _activeResizeHandle != ResizeHandle.none) {
                        setState(() {
                          _performHandleResize(selectedEntity, details.delta);
                        });
                      } else if (selectedEntity != null && _isDraggingEntity) {
                        double newX = selectedEntity.x + details.delta.dx;
                        double newY = selectedEntity.y + details.delta.dy;
                        if (_gridSnap) {
                          newX = (newX / _gridSize).round() * _gridSize;
                          newY = (newY / _gridSize).round() * _gridSize;
                        }
                        setState(() {
                          selectedEntity.x = newX.clamp(0, _map.worldWidth - selectedEntity.width);
                          selectedEntity.y = newY.clamp(0, _map.worldHeight - selectedEntity.height);
                        });
                      } else {
                        setState(() {
                          _scrollX = (_scrollX - details.delta.dx).clamp(0.0, max(0.0, _map.worldWidth - screenSize.width));
                          _scrollY = (_scrollY - details.delta.dy).clamp(0.0, max(0.0, _map.worldHeight - (screenSize.height - 180)));
                        });
                      }
                    },
                    onPanEnd: (_) {
                      if (_isDraggingEntity || _activeResizeHandle != ResizeHandle.none) {
                        _isDraggingEntity = false;
                        _activeResizeHandle = ResizeHandle.none;
                        _saveHistoryState();
                      }
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: MapEditorCanvasPainter(
                        map: _map,
                        scrollX: _scrollX,
                        scrollY: _scrollY,
                        selectedEntityId: _selectedEntityId,
                        gridSnap: _gridSnap,
                        gridSize: _gridSize,
                        time: _time,
                        selectedCharacter: selectedCharacter,
                      ),
                    ),
                  ),

                  // Compact Floating Property Panel for Selected Object
                  if (selectedEntity != null)
                    Positioned(
                      top: 12,
                      left: 16,
                      child: _buildPropertyPanel(selectedEntity),
                    ),

                  // Notification Toast
                  if (_messageText != null)
                    Positioned(
                      top: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isSuccessMessage ? const Color(0xEE065F46) : const Color(0xEE991B1B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isSuccessMessage ? const Color(0xFF34D399) : const Color(0xFFF87171),
                            width: 1.5,
                          ),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
                        ),
                        child: Text(
                          _messageText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 3. Bottom Toolbar Drawer (Non-overflowing & Collapsible)
            _buildBottomToolbarPanel(selectedCharacter),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xDD0F172A),
        border: Border(bottom: BorderSide(color: GameColors.uiGlassBorder, width: 1.2)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _openRenameDialog,
            child: Row(
              children: [
                Text(
                  _map.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit_rounded, color: Color(0xFF38BDF8), size: 15),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: _gridSnap ? const Color(0x4438BDF8) : Colors.transparent,
              side: BorderSide(color: _gridSnap ? const Color(0xFF38BDF8) : Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onPressed: () {
              setState(() {
                _gridSnap = !_gridSnap;
              });
              _showMessage(_gridSnap ? 'Grid Snap ON (20px)' : 'Grid Snap OFF');
            },
            icon: Icon(Icons.grid_on_rounded, size: 15, color: _gridSnap ? const Color(0xFF38BDF8) : Colors.white54),
            label: Text(
              _gridSnap ? 'GRID ON' : 'GRID OFF',
              style: TextStyle(
                color: _gridSnap ? const Color(0xFF38BDF8) : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.undo_rounded, color: Colors.white, size: 18),
            onPressed: _undoStack.length > 1 ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, color: Colors.white, size: 18),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _saveMap,
            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 16),
            label: const Text(
              'SAVE',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _testPlayMap,
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            label: const Text(
              'PLAY TEST',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPanel(CustomMapEntity e) {
    final String typeName = _getFormattedEntityName(e.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                typeName,
                style: const TextStyle(color: Color(0xFF80FFDB), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _selectedEntityId = null),
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'X: ${e.x.toInt()}   Y: ${e.y.toInt()}',
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            'W: ${e.width.toInt()}   H: ${e.height.toInt()}',
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          if (e.type.contains('enemy') || e.type == 'movingPlatform') ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Patrol: ', style: TextStyle(color: Colors.white54, fontSize: 10)),
                Text('${e.patrolRange.toInt()}px', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      e.patrolRange = (e.patrolRange - 20).clamp(40.0, 400.0);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
                    child: const Text('-', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      e.patrolRange = (e.patrolRange + 20).clamp(40.0, 400.0);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
                    child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _duplicateSelectedEntity,
                icon: const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                label: const Text('DUPLICATE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _deleteSelectedEntity,
                icon: const Icon(Icons.delete_rounded, size: 12, color: Colors.white),
                label: const Text('DELETE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedEntityName(String type) {
    switch (type) {
      case 'platform':
        return 'Platform';
      case 'movingPlatform':
        return 'Moving Platform';
      case 'slipperyPlatform':
        return 'Slippery Ice';
      case 'enemySlime':
        return 'Green Slime';
      case 'enemyShadow':
        return 'Shadow Stalker';
      case 'enemyFire':
        return 'Fire Demon';
      case 'enemyIce':
        return 'Ice Golem';
      case 'enemyToxic':
        return 'Toxic Beast';
      case 'coin':
        return 'Gold Coin';
      case 'healthPot':
        return 'Health Potion';
      case 'checkpoint':
        return 'Shrine Checkpoint';
      case 'hazardSpike':
        return 'Spikes';
      case 'hazardLava':
        return 'Lava Pool';
      case 'hazardPoison':
        return 'Poison Mud';
      case 'hazardLightning':
        return 'Lightning Arc';
      case 'decorTree':
        return 'Ancient Tree';
      case 'decorRock':
        return 'Forest Rock';
      case 'decorBush':
        return 'Green Bush';
      case 'decorFlower':
        return 'Magic Flower';
      case 'decorCrystal':
        return 'Crystal Shard';
      case 'decorRuin':
        return 'Ruin Pillars';
      case 'decorLamp':
        return 'Forest Lamp';
      case 'decorSign':
        return 'Sign Board';
      default:
        return 'Map Object';
    }
  }

  Widget _buildBottomToolbarPanel(CharacterData selectedCharacter) {
    if (_isToolbarCollapsed) {
      return Container(
        height: 28,
        color: const Color(0xEE0F172A),
        child: Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => setState(() => _isToolbarCollapsed = false),
            icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF38BDF8), size: 18),
            label: const Text('▲ EXPAND TOOLBAR', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    return Container(
      height: 105,
      decoration: const BoxDecoration(
        color: Color(0xEE0F172A),
        border: Border(top: BorderSide(color: GameColors.uiGlassBorder, width: 1.2)),
      ),
      child: Column(
        children: [
          // Category Bar + Collapse Button
          SizedBox(
            height: 32,
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _isToolbarCollapsed = true),
                  tooltip: 'Collapse Toolbar',
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white12),

          // Active Category Tools Ribbon
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: _buildActiveCategoryTools(selectedCharacter),
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
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActiveCategoryTools(CharacterData selectedCharacter) {
    switch (_activeCategory) {
      case EditorCategory.platforms:
        return [
          _buildToolChip('Small Plat', 'platform_small'),
          _buildToolChip('Medium Plat', 'platform_medium'),
          _buildToolChip('Large Plat', 'platform_large'),
          _buildToolChip('Moving Plat', 'platform_moving'),
          _buildToolChip('Slippery Ice', 'platform_slippery'),
        ];

      case EditorCategory.terrain:
        return [
          _buildToolChip('Grass Ground', 'ground_grass'),
          _buildToolChip('Dirt Ground', 'ground_dirt'),
          _buildToolChip('Stone Ground', 'ground_stone'),
        ];

      case EditorCategory.enemies:
        return [
          _buildToolChip('Green Slime', 'enemy_slime'),
          _buildToolChip('Shadow Stalker', 'enemy_shadow'),
          _buildToolChip('Fire Demon', 'enemy_fire'),
          _buildToolChip('Ice Golem', 'enemy_ice'),
          _buildToolChip('Toxic Beast', 'enemy_toxic'),
        ];

      case EditorCategory.items:
        return [
          _buildToolChip('Gold Coin', 'item_coin'),
          _buildToolChip('Health Pot', 'item_health_pot'),
          _buildToolChip('Checkpoint', 'item_checkpoint'),
        ];

      case EditorCategory.hazards:
        return [
          _buildToolChip('Spikes', 'hazard_spike'),
          _buildToolChip('Lava Pool', 'hazard_lava'),
          _buildToolChip('Poison Pool', 'hazard_poison'),
          _buildToolChip('Lightning Arc', 'hazard_lightning'),
        ];

      case EditorCategory.decor:
        return [
          _buildToolChip('Ancient Tree', 'decor_tree'),
          _buildToolChip('Forest Rock', 'decor_rock'),
          _buildToolChip('Green Bush', 'decor_bush'),
          _buildToolChip('Magic Flower', 'decor_flower'),
          _buildToolChip('Crystal Shard', 'decor_crystal'),
          _buildToolChip('Ruin Pillars', 'decor_ruin'),
          _buildToolChip('Forest Lamp', 'decor_lamp'),
          _buildToolChip('Sign Board', 'decor_sign'),
        ];

      case EditorCategory.special:
        return [
          _buildToolChip('Player Start', 'special_player_start', character: selectedCharacter),
          _buildToolChip('Finish Portal', 'special_finish'),
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
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF38BDF8) : const Color(0x330F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? Colors.white : Colors.white24),
              ),
              child: Center(
                child: Text(
                  themeName.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 10,
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
            icon: const Icon(Icons.add_rounded, size: 14),
            label: const Text('Expand Map Width (+1200px)', style: TextStyle(fontSize: 10)),
          ),
          const SizedBox(width: 6),
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
            icon: const Icon(Icons.delete_sweep_rounded, size: 14),
            label: const Text('Clear All Objects', style: TextStyle(fontSize: 10)),
          ),
        ];
    }
  }

  Widget _buildToolChip(String label, String toolType, {CharacterData? character}) {
    final isSelected = _activeToolType == toolType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeToolType = toolType;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : const Color(0x440F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF80FFDB) : Colors.white24,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(
                painter: ToolThumbnailPainter(
                  toolType: toolType,
                  themeName: _map.theme,
                  character: character,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 10,
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
  final double time;
  final CharacterData selectedCharacter;

  MapEditorCanvasPainter({
    required this.map,
    required this.scrollX,
    required this.scrollY,
    required this.selectedEntityId,
    required this.gridSnap,
    required this.gridSize,
    required this.time,
    required this.selectedCharacter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final LevelTheme theme = _parseTheme(map.theme);

    // 1. Draw Real Live Environment Backgrounds
    _drawSkyBackground(canvas, size, theme);
    _drawFarParallaxLayer(canvas, size, theme);
    _drawGodRaysAndAtmosphere(canvas, size, theme);
    _drawMidParallaxLayer(canvas, size, theme);

    // Translate canvas for Camera Scroll
    canvas.save();
    canvas.translate(-scrollX, -scrollY);

    // 2. Draw Subtle Alignment Grid Overlay (if ON)
    if (gridSnap) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 1.0;

      final double startX = (scrollX / gridSize).floor() * gridSize;
      final double endX = min(map.worldWidth, scrollX + size.width + gridSize);
      final double startY = (scrollY / gridSize).floor() * gridSize;
      final double endY = min(map.worldHeight, scrollY + size.height + gridSize);

      for (double x = startX; x <= endX; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, map.worldHeight), gridPaint);
      }
      for (double y = startY; y <= endY; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(map.worldWidth, y), gridPaint);
      }
    }

    // 3. Render Real World Entities (Platforms, Enemies, Items, Hazards, Decor)
    for (final e in map.entities) {
      if (e.x + e.width < scrollX - 100 || e.x > scrollX + size.width + 100) continue;

      final rect = Rect.fromLTWH(e.x, e.y, e.width, e.height);
      final isSelected = e.id == selectedEntityId;

      _drawEntityAsset(canvas, e, rect, theme);

      // Selection Overlay with Corner Handles A, B, C, D
      if (isSelected) {
        _drawSelectionBoundingBoxAndHandles(canvas, rect);
      }
    }

    // 4. Render Real Player Character at Player Start Position
    _drawPlayerStartCharacter(canvas);

    // 5. Render Real Finish Portal
    _drawFinishPortal(canvas);

    canvas.restore();
  }

  void _drawSelectionBoundingBoxAndHandles(Canvas canvas, Rect rect) {
    // Dashed / Solid Bounding Box
    final outlinePaint = Paint()
      ..color = const Color(0xFF80FFDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(rect, outlinePaint);

    // Corner Handles A, B, C, D
    final handleA = Offset(rect.left, rect.top);
    final handleB = Offset(rect.right, rect.top);
    final handleC = Offset(rect.right, rect.bottom);
    final handleD = Offset(rect.left, rect.bottom);

    _drawHandleBadge(canvas, handleA, 'A');
    _drawHandleBadge(canvas, handleB, 'B');
    _drawHandleBadge(canvas, handleC, 'C');
    _drawHandleBadge(canvas, handleD, 'D');

    // Dimension Banner below object
    final String dimStr = '${rect.width.toInt()} x ${rect.height.toInt()}';
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: dimStr,
        style: const TextStyle(color: Color(0xFF80FFDB), fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double bannerW = tp.width + 8;
    final Rect bannerRect = Rect.fromLTWH(rect.left + rect.width / 2 - bannerW / 2, rect.bottom + 4, bannerW, 14);
    canvas.drawRRect(RRect.fromRectAndRadius(bannerRect, const Radius.circular(4)), Paint()..color = const Color(0xDD0F172A));
    tp.paint(canvas, Offset(bannerRect.left + 4, bannerRect.top + 1));
  }

  void _drawHandleBadge(Canvas canvas, Offset pos, String letter) {
    final handleRect = Rect.fromCenter(center: pos, width: 16, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(handleRect, const Radius.circular(4)), Paint()..color = const Color(0xFF38BDF8));
    canvas.drawRRect(RRect.fromRectAndRadius(handleRect, const Radius.circular(4)), Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2);

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  LevelTheme _parseTheme(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'fire':
        return LevelTheme.fire;
      case 'water':
        return LevelTheme.water;
      case 'ice':
        return LevelTheme.ice;
      case 'desert':
        return LevelTheme.desert;
      case 'thunder':
        return LevelTheme.thunder;
      case 'poison':
        return LevelTheme.poison;
      case 'sky':
        return LevelTheme.sky;
      case 'shadow':
        return LevelTheme.shadow;
      case 'crystal':
        return LevelTheme.crystal;
      case 'forest':
      default:
        return LevelTheme.forest;
    }
  }

  void _drawSkyBackground(Canvas canvas, Size size, LevelTheme theme) {
    final Rect rect = Offset.zero & size;
    final List<Color> skyColors = _getSkyColors(theme);

    final Paint skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skyColors,
      ).createShader(rect);

    canvas.drawRect(rect, skyPaint);

    final Paint starPaint = Paint()..color = _getStarColor(theme);
    for (int i = 0; i < 30; i++) {
      final double sx = ((i * 137.5) % size.width);
      final double sy = ((i * 83.1) % (size.height * 0.5));
      final double pulse = 1.0 + 0.4 * sin(time * 2 + i);
      canvas.drawCircle(Offset(sx, sy), 1.2 * pulse, starPaint);
    }
  }

  List<Color> _getSkyColors(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.forest:
        return [GameColors.skyBackground, GameColors.deepForestTeal, GameColors.atmosphericHaze];
      case LevelTheme.fire:
        return [const Color(0xFF2B0903), const Color(0xFF5A1408), const Color(0xFF8D220F)];
      case LevelTheme.water:
        return [const Color(0xFF031926), const Color(0xFF0A3663), const Color(0xFF1B4978)];
      case LevelTheme.ice:
        return [const Color(0xFF0B2545), const Color(0xFF134074), const Color(0xFF4A90A4)];
      case LevelTheme.desert:
        return [const Color(0xFF3A1C02), const Color(0xFF6B3A0A), const Color(0xFF9E5C1B)];
      case LevelTheme.thunder:
        return [const Color(0xFF19002E), const Color(0xFF2B0040), const Color(0xFF3C096C)];
      case LevelTheme.poison:
        return [const Color(0xFF10002B), const Color(0xFF240046), const Color(0xFF3C096C)];
      case LevelTheme.sky:
        return [const Color(0xFF003049), const Color(0xFF125B8A), const Color(0xFF2A83B9)];
      case LevelTheme.shadow:
        return [const Color(0xFF03071E), const Color(0xFF0D1B2A), const Color(0xFF1B263B)];
      case LevelTheme.crystal:
        return [const Color(0xFF240046), const Color(0xFF5A189A), const Color(0xFF7B2CBF)];
    }
  }

  Color _getStarColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0x77FF6B6B);
      case LevelTheme.water:
        return const Color(0x774EA8DE);
      case LevelTheme.ice:
        return const Color(0x88CAF0F8);
      case LevelTheme.desert:
        return const Color(0x77FFD166);
      case LevelTheme.thunder:
        return const Color(0x88C77DFF);
      case LevelTheme.poison:
        return const Color(0x7700F5D4);
      case LevelTheme.crystal:
        return const Color(0x88F72585);
      default:
        return const Color(0x66A6E3E9);
    }
  }

  void _drawFarParallaxLayer(Canvas canvas, Size size, LevelTheme theme) {
    final double farCamX = scrollX * 0.2;
    final Paint farPaint = Paint()..color = _getFarLayerColor(theme);

    final Path path = Path();
    path.moveTo(0, size.height);

    const double spacing = 200;
    final double startX = -((farCamX) % spacing) - spacing;

    for (double x = startX; x < size.width + spacing * 2; x += spacing) {
      final double h = 320 + sin(x * 0.01) * 80;
      final double topY = size.height - h - (scrollY * 0.1);

      if (theme == LevelTheme.ice || theme == LevelTheme.desert) {
        path.lineTo(x + spacing / 2, topY);
        path.lineTo(x + spacing, topY + h);
      } else {
        path.lineTo(x, topY + 100);
        path.quadraticBezierTo(x + 40, topY - 30, x + 100, topY + 80);
        path.quadraticBezierTo(x + 150, topY - 10, x + spacing, topY + 120);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, farPaint);
  }

  Color _getFarLayerColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF3D0C02);
      case LevelTheme.water:
        return const Color(0xFF041926);
      case LevelTheme.ice:
        return const Color(0xFF0D2838);
      case LevelTheme.desert:
        return const Color(0xFF4A2503);
      case LevelTheme.thunder:
        return const Color(0xFF1D0036);
      case LevelTheme.poison:
        return const Color(0xFF1B0033);
      case LevelTheme.sky:
        return const Color(0xFF0D3B66);
      case LevelTheme.shadow:
        return const Color(0xFF0A0F1D);
      case LevelTheme.crystal:
        return const Color(0xFF38004D);
      default:
        return const Color(0xFF132A36);
    }
  }

  void _drawGodRaysAndAtmosphere(Canvas canvas, Size size, LevelTheme theme) {
    final Paint rayPaint = Paint()..blendMode = BlendMode.screen;

    for (int i = 0; i < 3; i++) {
      final double rayOffset = (time * 15 + i * 250) % (size.width + 300) - 150;
      final double pulse = 0.6 + 0.4 * sin(time + i);

      final Path rayPath = Path()
        ..moveTo(rayOffset, -50)
        ..lineTo(rayOffset + 90, -50)
        ..lineTo(rayOffset - 120, size.height + 50)
        ..lineTo(rayOffset - 210, size.height + 50)
        ..close();

      rayPaint.color = _getStarColor(theme).withValues(alpha: 0.10 * pulse);
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  void _drawMidParallaxLayer(Canvas canvas, Size size, LevelTheme theme) {
    final double midCamX = scrollX * 0.5;
    final double midCamY = scrollY * 0.3;

    final Paint midBodyPaint = Paint()..color = _getMidLayerColor(theme);
    final Paint midDetailPaint = Paint()..color = _getMidAccentColor(theme);

    const double width = 80;
    const double interval = 320;
    final double startX = -((midCamX) % interval) - interval;

    for (double x = startX; x < size.width + interval; x += interval) {
      final double treeY = size.height - 680 - midCamY;

      if (theme == LevelTheme.crystal) {
        final Path spirePath = Path()
          ..moveTo(x + width / 2, treeY)
          ..lineTo(x + width, treeY + 350)
          ..lineTo(x, treeY + 350)
          ..close();
        canvas.drawPath(spirePath, midDetailPaint);
      } else {
        final Path trunkPath = Path()
          ..moveTo(x, size.height)
          ..quadraticBezierTo(x + 10, treeY + 300, x + 20, treeY)
          ..lineTo(x + width - 20, treeY)
          ..quadraticBezierTo(x + width - 10, treeY + 300, x + width, size.height)
          ..close();

        canvas.drawPath(trunkPath, midBodyPaint);
        canvas.drawCircle(Offset(x + width / 2, treeY - 20), 100, midDetailPaint);
      }
    }
  }

  Color _getMidLayerColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF260501);
      case LevelTheme.water:
        return const Color(0xFF082238);
      case LevelTheme.ice:
        return const Color(0xFF113247);
      case LevelTheme.desert:
        return const Color(0xFF331802);
      case LevelTheme.thunder:
        return const Color(0xFF140026);
      case LevelTheme.poison:
        return const Color(0xFF16002B);
      case LevelTheme.sky:
        return const Color(0xFF16425B);
      case LevelTheme.shadow:
        return const Color(0xFF0A0F1D);
      case LevelTheme.crystal:
        return const Color(0xFF2B003B);
      default:
        return GameColors.ancientBarkDark;
    }
  }

  Color _getMidAccentColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF5A1408);
      case LevelTheme.water:
        return const Color(0xFF1B4978);
      case LevelTheme.ice:
        return const Color(0xFF2C5E7A);
      case LevelTheme.desert:
        return const Color(0xFF6B3A0A);
      case LevelTheme.thunder:
        return const Color(0xFF3C096C);
      case LevelTheme.poison:
        return const Color(0xFF240046);
      case LevelTheme.sky:
        return const Color(0xFF2A83B9);
      case LevelTheme.shadow:
        return const Color(0xFF1B263B);
      case LevelTheme.crystal:
        return const Color(0xFF7B2CBF);
      default:
        return const Color(0xFF1E4638);
    }
  }

  void _drawEntityAsset(Canvas canvas, CustomMapEntity e, Rect rect, LevelTheme theme) {
    if (e.type.contains('platform') || e.type.contains('ground')) {
      _drawPlatform(canvas, rect, e.type, theme);
    } else if (e.type.contains('enemy')) {
      _drawEnemy(canvas, e, rect);
    } else if (e.type == 'coin' || e.type == 'healthPot' || e.type == 'checkpoint') {
      _drawItem(canvas, e, rect);
    } else if (e.type.contains('hazard')) {
      _drawHazard(canvas, e, rect);
    } else if (e.type.contains('decor')) {
      _drawDecor(canvas, e, rect);
    }
  }

  void _drawPlatform(Canvas canvas, Rect rect, String type, LevelTheme theme) {
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    Color bodyColor = _getPlatformBodyColor(theme);
    Color topColor = _getPlatformTopColor(theme);

    if (type == 'slipperyPlatform') {
      topColor = const Color(0xFFCAF0F8);
      bodyColor = const Color(0xFF1B3B52);
    } else if (type == 'movingPlatform') {
      topColor = const Color(0xFF80FFDB);
    }

    // Platform Body
    canvas.drawRRect(rrect, Paint()..color = bodyColor);

    // Top Trim Wave
    final Path topPath = Path();
    topPath.moveTo(rect.left - 2, rect.top + 6);
    topPath.lineTo(rect.left - 2, rect.top);

    for (double x = rect.left; x <= rect.right; x += 12) {
      final double wave = sin(x * 0.1) * 3;
      topPath.lineTo(x, rect.top + wave);
    }

    topPath.lineTo(rect.right + 2, rect.top);
    topPath.lineTo(rect.right + 2, rect.top + 8);
    topPath.close();

    canvas.drawPath(topPath, Paint()..color = topColor);
  }

  Color _getPlatformBodyColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFF1E1010);
      case LevelTheme.water:
        return const Color(0xFF0F2537);
      case LevelTheme.ice:
        return const Color(0xFF1B3B52);
      case LevelTheme.desert:
        return const Color(0xFF3D230D);
      case LevelTheme.thunder:
        return const Color(0xFF221133);
      case LevelTheme.poison:
        return const Color(0xFF280C3D);
      case LevelTheme.sky:
        return const Color(0xFF1B3C59);
      case LevelTheme.shadow:
        return const Color(0xFF111422);
      case LevelTheme.crystal:
        return const Color(0xFF3D0C4A);
      default:
        return GameColors.ancientBarkDark;
    }
  }

  Color _getPlatformTopColor(LevelTheme theme) {
    switch (theme) {
      case LevelTheme.fire:
        return const Color(0xFFFF4500);
      case LevelTheme.water:
        return const Color(0xFF00B4D8);
      case LevelTheme.ice:
        return const Color(0xFFCAF0F8);
      case LevelTheme.desert:
        return const Color(0xFFFFC6FF);
      case LevelTheme.thunder:
        return const Color(0xFFC77DFF);
      case LevelTheme.poison:
        return const Color(0xFF00F5D4);
      case LevelTheme.sky:
        return const Color(0xFFE0F1E7);
      case LevelTheme.shadow:
        return const Color(0xFF7B2CBF);
      case LevelTheme.crystal:
        return const Color(0xFFF72585);
      default:
        return GameColors.mossyGreenBright;
    }
  }

  void _drawEnemy(Canvas canvas, CustomMapEntity e, Rect rect) {
    canvas.save();
    canvas.translate(rect.left + rect.width / 2, rect.top + rect.height / 2);

    switch (e.type) {
      case 'enemySlime':
        final double squish = sin(time * 8 + e.x) * 0.12;
        final double w = rect.width * (1.0 + squish);
        final double h = rect.height * (1.0 - squish);
        final RRect rrect = RRect.fromRectAndCorners(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          topLeft: Radius.circular(w * 0.4),
          topRight: Radius.circular(w * 0.4),
          bottomLeft: Radius.circular(w * 0.2),
          bottomRight: Radius.circular(w * 0.2),
        );
        canvas.drawRRect(rrect, Paint()..color = GameColors.slimeGreen);
        canvas.drawCircle(Offset(w * 0.15, -h * 0.1), 3.5, Paint()..color = GameColors.slimeGlow);
        canvas.drawCircle(Offset(-w * 0.15, -h * 0.1), 3.5, Paint()..color = GameColors.slimeGlow);
        break;

      case 'enemyShadow':
        final double hover = sin(time * 5 + e.x) * 3;
        final double w = rect.width;
        final double h = rect.height;
        final Path shadowPath = Path()
          ..moveTo(0, -h / 2 + hover)
          ..quadraticBezierTo(w / 2 + 5, -h / 4 + hover, w / 2, h / 4 + hover)
          ..quadraticBezierTo(w / 3, h / 2 + hover, 0, h / 2 + hover)
          ..quadraticBezierTo(-w / 3, h / 2 + hover, -w / 2, h / 4 + hover)
          ..quadraticBezierTo(-w / 2 - 5, -h / 4 + hover, 0, -h / 2 + hover)
          ..close();
        canvas.drawPath(shadowPath, Paint()..color = GameColors.shadowEnemyBody);
        canvas.drawCircle(Offset(w * 0.15, -h * 0.1 + hover), 3, Paint()..color = GameColors.shadowEnemyGlow);
        canvas.drawCircle(Offset(-w * 0.15, -h * 0.1 + hover), 3, Paint()..color = GameColors.shadowEnemyGlow);
        break;

      case 'enemyFire':
        final double w = rect.width;
        final double h = rect.height;
        final Path path = Path()
          ..moveTo(0, -h / 2)
          ..lineTo(w / 2, 0)
          ..lineTo(w / 3, h / 2)
          ..lineTo(-w / 3, h / 2)
          ..lineTo(-w / 2, 0)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFF3300));
        canvas.drawCircle(Offset(-w * 0.2, -h * 0.3), 5, Paint()..color = const Color(0xFFFFCC00));
        canvas.drawCircle(Offset(w * 0.2, -h * 0.3), 5, Paint()..color = const Color(0xFFFFCC00));
        break;

      case 'enemyIce':
        final double w = rect.width;
        final double h = rect.height;
        final Path path = Path()
          ..moveTo(0, -h / 2)
          ..lineTo(w / 2 - 2, -h / 4)
          ..lineTo(w / 2, h / 3)
          ..lineTo(0, h / 2)
          ..lineTo(-w / 2, h / 3)
          ..lineTo(-w / 2 + 2, -h / 4)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF4EA8DE));
        canvas.drawCircle(Offset(-w * 0.18, -h * 0.1), 3, Paint()..color = const Color(0xFFCAF0F8));
        canvas.drawCircle(Offset(w * 0.18, -h * 0.1), 3, Paint()..color = const Color(0xFFCAF0F8));
        break;

      case 'enemyToxic':
        final double w = rect.width;
        final double h = rect.height;
        final RRect rrect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), const Radius.circular(10));
        canvas.drawRRect(rrect, Paint()..color = const Color(0xFF5A189A));
        canvas.drawCircle(Offset(-w * 0.18, -h * 0.15), 3.5, Paint()..color = const Color(0xFF00F5D4));
        canvas.drawCircle(Offset(w * 0.18, -h * 0.15), 3.5, Paint()..color = const Color(0xFF00F5D4));
        break;
    }

    canvas.restore();
  }

  void _drawItem(Canvas canvas, CustomMapEntity e, Rect rect) {
    final double hover = sin(time * 4 + e.x) * 3;
    final Offset center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2 + hover);

    if (e.type == 'coin') {
      canvas.drawCircle(center, 12, Paint()..color = GameColors.coinGlow.withValues(alpha: 0.4));
      canvas.drawCircle(center, 9, Paint()..color = GameColors.coinGold);
      canvas.drawCircle(center, 5, Paint()..color = const Color(0xFFE9C46A));
    } else if (e.type == 'healthPot') {
      final Paint potPaint = Paint()..color = const Color(0xFFE63946);
      canvas.drawCircle(center, 10, Paint()..color = const Color(0x66E63946));
      canvas.drawCircle(center, 7, potPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, center.dy - 8), width: 5, height: 5), potPaint);
    } else if (e.type == 'checkpoint') {
      final Paint stonePaint = Paint()..color = const Color(0xFF343A40);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + 15, 10, rect.height - 15), stonePaint);
      canvas.drawRect(Rect.fromLTWH(rect.right - 10, rect.top + 15, 10, rect.height - 15), stonePaint);
      canvas.drawRect(Rect.fromLTWH(rect.left - 2, rect.top, rect.width + 4, 12), stonePaint);

      final Offset orbCenter = Offset(rect.left + rect.width / 2, rect.top + 30);
      canvas.drawCircle(orbCenter, 14, Paint()..color = GameColors.shrineActive.withValues(alpha: 0.3));
      canvas.drawCircle(orbCenter, 8, Paint()..color = GameColors.shrineActive);
    }
  }

  void _drawHazard(Canvas canvas, CustomMapEntity e, Rect rect) {
    if (e.type == 'hazardSpike') {
      final Paint spikePaint = Paint()..color = GameColors.hazardSpike;
      final double count = (rect.width / 15).floorToDouble().clamp(1.0, 50.0);
      final double spikeW = rect.width / count;
      for (int i = 0; i < count; i++) {
        final double sx = rect.left + i * spikeW;
        final Path sPath = Path()
          ..moveTo(sx, rect.top + rect.height)
          ..lineTo(sx + spikeW / 2, rect.top)
          ..lineTo(sx + spikeW, rect.top + rect.height)
          ..close();
        canvas.drawPath(sPath, spikePaint);
      }
    } else if (e.type == 'hazardLava') {
      canvas.drawRect(rect, Paint()..color = const Color(0xFFD90429));
      final Path wavePath = Path();
      wavePath.moveTo(rect.left, rect.top);
      for (double x = rect.left; x <= rect.right; x += 15) {
        final double wave = sin(x * 0.08 + time * 5) * 3;
        wavePath.lineTo(x, rect.top + wave);
      }
      wavePath.lineTo(rect.right, rect.bottom);
      wavePath.lineTo(rect.left, rect.bottom);
      wavePath.close();
      canvas.drawPath(wavePath, Paint()..color = const Color(0xFFFF6B6B));
    } else if (e.type == 'hazardPoison') {
      canvas.drawRect(rect, Paint()..color = const Color(0xFF3C096C));
      final Path wavePath = Path();
      wavePath.moveTo(rect.left, rect.top);
      for (double x = rect.left; x <= rect.right; x += 15) {
        final double wave = sin(x * 0.1 + time * 4) * 3;
        wavePath.lineTo(x, rect.top + wave);
      }
      wavePath.lineTo(rect.right, rect.bottom);
      wavePath.lineTo(rect.left, rect.bottom);
      wavePath.close();
      canvas.drawPath(wavePath, Paint()..color = const Color(0xFF00F5D4));
    } else if (e.type == 'hazardLightning') {
      final Paint elecPaint = Paint()
        ..color = const Color(0xFFC77DFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final Path bolt = Path()..moveTo(rect.left, rect.top + rect.height / 2);
      for (double x = rect.left; x < rect.right; x += 18) {
        final double offset = (sin(x + time * 20) > 0 ? 1 : -1) * 6.0;
        bolt.lineTo(x + 9, rect.top + rect.height / 2 + offset);
      }
      bolt.lineTo(rect.right, rect.top + rect.height / 2);
      canvas.drawPath(bolt, elecPaint);
    }
  }

  void _drawDecor(Canvas canvas, CustomMapEntity e, Rect rect) {
    if (e.type == 'decorTree') {
      final Paint trunkPaint = Paint()..color = GameColors.ancientBarkDark;
      final Paint leafPaint = Paint()..color = const Color(0xFF15803D);
      final Path trunk = Path()
        ..moveTo(rect.left + rect.width * 0.3, rect.bottom)
        ..lineTo(rect.left + rect.width * 0.4, rect.top + rect.height * 0.4)
        ..lineTo(rect.left + rect.width * 0.6, rect.top + rect.height * 0.4)
        ..lineTo(rect.left + rect.width * 0.7, rect.bottom)
        ..close();
      canvas.drawPath(trunk, trunkPaint);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.5, rect.top + rect.height * 0.3), rect.width * 0.5, leafPaint);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.3, rect.top + rect.height * 0.4), rect.width * 0.35, leafPaint);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.7, rect.top + rect.height * 0.4), rect.width * 0.35, leafPaint);
    } else if (e.type == 'decorRock') {
      final Paint rockPaint = Paint()..color = const Color(0xFF475569);
      final Path rockPath = Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left + rect.width * 0.2, rect.top + rect.height * 0.2)
        ..lineTo(rect.left + rect.width * 0.7, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..close();
      canvas.drawPath(rockPath, rockPaint);
    } else if (e.type == 'decorBush') {
      final Paint bushPaint = Paint()..color = const Color(0xFF16A34A);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.3, rect.bottom - rect.height * 0.4), rect.height * 0.5, bushPaint);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.7, rect.bottom - rect.height * 0.4), rect.height * 0.5, bushPaint);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.5, rect.bottom - rect.height * 0.6), rect.height * 0.55, bushPaint);
    } else if (e.type == 'decorFlower') {
      final Offset center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
      canvas.drawCircle(center, rect.width * 0.4, Paint()..color = const Color(0xFF80FFDB).withValues(alpha: 0.3));
      canvas.drawCircle(center, rect.width * 0.25, Paint()..color = const Color(0xFFF43F5E));
      canvas.drawCircle(center, rect.width * 0.1, Paint()..color = const Color(0xFFFEF08A));
    } else if (e.type == 'decorCrystal') {
      final Path crystal = Path()
        ..moveTo(rect.left + rect.width * 0.5, rect.top)
        ..lineTo(rect.right, rect.top + rect.height * 0.3)
        ..lineTo(rect.left + rect.width * 0.8, rect.bottom)
        ..lineTo(rect.left + rect.width * 0.2, rect.bottom)
        ..lineTo(rect.left, rect.top + rect.height * 0.3)
        ..close();
      canvas.drawPath(crystal, Paint()..color = const Color(0xFFC084FC));
    } else if (e.type == 'decorRuin') {
      final Paint pillarPaint = Paint()..color = const Color(0xFF64748B);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + 10, rect.width * 0.35, rect.height - 10), pillarPaint);
      canvas.drawRect(Rect.fromLTWH(rect.right - rect.width * 0.35, rect.top + 10, rect.width * 0.35, rect.height - 10), pillarPaint);
      canvas.drawRect(Rect.fromLTWH(rect.left - 4, rect.top, rect.width + 8, 12), pillarPaint);
    } else if (e.type == 'decorLamp') {
      final Paint woodPaint = Paint()..color = const Color(0xFF78350F);
      canvas.drawRect(Rect.fromLTWH(rect.left + rect.width * 0.4, rect.top + 12, rect.width * 0.2, rect.height - 12), woodPaint);
      canvas.drawCircle(Offset(rect.left + rect.width * 0.5, rect.top + 10), 12, Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.4));
      canvas.drawCircle(Offset(rect.left + rect.width * 0.5, rect.top + 10), 6, Paint()..color = const Color(0xFFEAB308));
    } else if (e.type == 'decorSign') {
      final Paint signPaint = Paint()..color = const Color(0xFF92400E);
      canvas.drawRect(Rect.fromLTWH(rect.left + rect.width * 0.4, rect.top + 15, rect.width * 0.2, rect.height - 15), signPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top, rect.width, 18), const Radius.circular(4)), signPaint);
    }
  }

  void _drawPlayerStartCharacter(Canvas canvas) {
    final double cx = map.playerStartX;
    final double cy = map.playerStartY;

    canvas.save();
    canvas.translate(cx, cy);

    CharacterRenderHelper.drawCharacter(
      canvas: canvas,
      character: selectedCharacter,
      w: 40,
      h: 60,
      topY: -30 + sin(time * 4) * 2,
      time: time,
      armAngle: 0,
      legAngle1: 0,
      legAngle2: 0,
      isGrounded: true,
      isAttacking: false,
    );

    final badgePaint = Paint()..color = const Color(0xEE0EA5E9);
    final badgeRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-36, -62, 72, 18), const Radius.circular(8));
    canvas.drawRRect(badgeRect, badgePaint);

    final TextPainter tp = TextPainter(
      text: const TextSpan(
        text: 'PLAYER START',
        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(-31, -59));

    canvas.restore();
  }

  void _drawFinishPortal(Canvas canvas) {
    final Offset pCenter = Offset(map.finishX, map.finishY);

    final Paint portalGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          GameColors.portalGlow,
          GameColors.portalPurple,
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pCenter, radius: 45));

    canvas.drawCircle(pCenter, 45, portalGlow);

    final Paint ringPaint = Paint()
      ..color = GameColors.portalGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int r = 0; r < 3; r++) {
      final double radius = 14 + r * 10;
      final double angle = time * (3 - r) * (r.isEven ? 1 : -1);

      canvas.save();
      canvas.translate(pCenter.dx, pCenter.dy);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 1.3), ringPaint);
      canvas.restore();
    }

    final badgePaint = Paint()..color = const Color(0xEE8B5CF6);
    final badgeRect = RRect.fromRectAndRadius(Rect.fromLTWH(pCenter.dx - 40, pCenter.dy - 62, 80, 18), const Radius.circular(8));
    canvas.drawRRect(badgeRect, badgePaint);

    final TextPainter tp = TextPainter(
      text: const TextSpan(
        text: 'FINISH PORTAL',
        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pCenter.dx - 35, pCenter.dy - 59));
  }

  @override
  bool shouldRepaint(covariant MapEditorCanvasPainter oldDelegate) => true;
}

class ToolThumbnailPainter extends CustomPainter {
  final String toolType;
  final String themeName;
  final CharacterData? character;

  ToolThumbnailPainter({
    required this.toolType,
    required this.themeName,
    this.character,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    canvas.save();

    if (toolType.contains('platform') || toolType.contains('ground')) {
      final Rect rect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.85, height: 10);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), Paint()..color = const Color(0xFF15803D));
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 3), Paint()..color = const Color(0xFF22C55E));
    } else if (toolType.contains('enemy')) {
      if (toolType == 'enemy_slime') {
        canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = GameColors.slimeGreen);
        canvas.drawCircle(Offset(cx - 2.5, cy - 2), 2, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx + 2.5, cy - 2), 2, Paint()..color = Colors.white);
      } else if (toolType == 'enemy_shadow') {
        canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = GameColors.shadowEnemyBody);
        canvas.drawCircle(Offset(cx - 2.5, cy - 2), 2, Paint()..color = GameColors.shadowEnemyGlow);
        canvas.drawCircle(Offset(cx + 2.5, cy - 2), 2, Paint()..color = GameColors.shadowEnemyGlow);
      } else if (toolType == 'enemy_fire') {
        canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = const Color(0xFFFF3300));
        canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFFFFCC00));
      } else if (toolType == 'enemy_ice') {
        canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = const Color(0xFF4EA8DE));
        canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFFCAF0F8));
      } else if (toolType == 'enemy_toxic') {
        canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = const Color(0xFF5A189A));
        canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFF00F5D4));
      }
    } else if (toolType == 'item_coin') {
      canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = GameColors.coinGold);
      canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFFE9C46A));
    } else if (toolType == 'item_health_pot') {
      canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = const Color(0xFFE63946));
    } else if (toolType == 'item_checkpoint') {
      canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = GameColors.shrineActive);
    } else if (toolType.contains('hazard')) {
      if (toolType == 'hazard_spike') {
        final Path path = Path()
          ..moveTo(cx - 8, cy + 6)
          ..lineTo(cx, cy - 6)
          ..lineTo(cx + 8, cy + 6)
          ..close();
        canvas.drawPath(path, Paint()..color = GameColors.hazardSpike);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 8), Paint()..color = const Color(0xFFFF3333));
      }
    } else if (toolType == 'special_player_start' && character != null) {
      canvas.translate(cx, cy + 8);
      CharacterRenderHelper.drawCharacter(
        canvas: canvas,
        character: character!,
        w: 18,
        h: 24,
        topY: -12,
        time: 0,
        armAngle: 0,
        legAngle1: 0,
        legAngle2: 0,
      );
    } else if (toolType == 'special_finish') {
      canvas.drawCircle(Offset(cx, cy), 10, Paint()..color = GameColors.portalGlow);
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(Offset(cx, cy), 9, Paint()..color = const Color(0xFF22C55E));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ToolThumbnailPainter oldDelegate) => false;
}
