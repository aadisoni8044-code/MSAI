import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';
import 'package:enchanted_forest_adventure/core/custom_map_progress_controller.dart';
import 'package:enchanted_forest_adventure/game/game_engine.dart';
import 'package:enchanted_forest_adventure/models/custom_map_data.dart';
import 'package:enchanted_forest_adventure/models/level_data.dart';
import 'package:enchanted_forest_adventure/models/game_entity.dart';
import 'package:enchanted_forest_adventure/rendering/forest_painter.dart';
import 'package:enchanted_forest_adventure/rendering/character_painter.dart';
import 'package:enchanted_forest_adventure/rendering/enemy_painter.dart';
import 'package:enchanted_forest_adventure/rendering/particle_painter.dart';
import 'package:enchanted_forest_adventure/widgets/game_hud.dart';
import 'package:enchanted_forest_adventure/widgets/virtual_joystick.dart';
import 'package:enchanted_forest_adventure/widgets/action_buttons.dart';
import 'package:enchanted_forest_adventure/ui/map_editor_screen.dart';

class CustomMapGameScreen extends StatefulWidget {
  final CustomMapData mapData;

  const CustomMapGameScreen({
    super.key,
    required this.mapData,
  });

  @override
  State<CustomMapGameScreen> createState() => _CustomMapGameScreenState();
}

class _CustomMapGameScreenState extends State<CustomMapGameScreen> with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  late Ticker _ticker;
  late final FocusNode _focusNode;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;
  bool _hasSavedProgress = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _engine = GameEngine(initialLevel: 1);
    _loadCustomLevelData();
    _ticker = createTicker(_onTick)..start();
    SettingsController.instance.applyCurrentOrientation();

    CustomMapProgressController.instance.recordMapAttempt(widget.mapData.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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

  void _loadCustomLevelData() {
    final map = widget.mapData;

    final List<GameEntity> platforms = [];
    final List<GameEntity> enemies = [];
    final List<GameEntity> collectibles = [];
    final List<GameEntity> hazards = [];
    final List<GameEntity> checkpoints = [];

    for (final e in map.entities) {
      if (e.type == 'platform') {
        platforms.add(GameEntity(id: e.id, type: EntityType.platform, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'movingPlatform') {
        platforms.add(GameEntity(
            id: e.id,
            type: EntityType.movingPlatform,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            patrolRange: e.patrolRange,
            vx: e.vx));
      } else if (e.type == 'slipperyPlatform') {
        platforms.add(GameEntity(id: e.id, type: EntityType.slipperyPlatform, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'enemySlime') {
        enemies.add(GameEntity(
            id: e.id,
            type: EntityType.enemySlime,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            patrolRange: e.patrolRange,
            health: e.health));
      } else if (e.type == 'enemyShadow') {
        enemies.add(GameEntity(
            id: e.id,
            type: EntityType.enemyShadow,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            patrolRange: e.patrolRange,
            health: e.health));
      } else if (e.type == 'enemyFire') {
        enemies.add(GameEntity(
            id: e.id,
            type: EntityType.enemyFire,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            patrolRange: e.patrolRange,
            health: e.health));
      } else if (e.type == 'enemyIce') {
        enemies.add(GameEntity(
            id: e.id,
            type: EntityType.enemyIce,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            patrolRange: e.patrolRange,
            health: e.health));
      } else if (e.type == 'enemyToxic') {
        enemies.add(GameEntity(
            id: e.id,
            type: EntityType.enemyToxic,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            patrolRange: e.patrolRange,
            health: e.health));
      } else if (e.type == 'coin') {
        collectibles.add(GameEntity(id: e.id, type: EntityType.coin, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'healthPot') {
        collectibles.add(GameEntity(id: e.id, type: EntityType.healthPot, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'checkpoint') {
        checkpoints.add(GameEntity(id: e.id, type: EntityType.checkpoint, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'hazardSpike') {
        hazards.add(GameEntity(id: e.id, type: EntityType.hazardSpike, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'hazardLava') {
        hazards.add(GameEntity(id: e.id, type: EntityType.hazardLava, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'hazardPoison') {
        hazards.add(GameEntity(id: e.id, type: EntityType.hazardPoison, x: e.x, y: e.y, width: e.width, height: e.height));
      } else if (e.type == 'hazardLightning') {
        hazards.add(GameEntity(id: e.id, type: EntityType.hazardLightning, x: e.x, y: e.y, width: e.width, height: e.height));
      }
    }

    final customLevel = LevelData(
      levelNumber: 99,
      levelName: map.name,
      theme: _parseTheme(map.theme),
      worldWidth: map.worldWidth,
      worldHeight: map.worldHeight,
      playerStartX: map.playerStartX,
      playerStartY: map.playerStartY,
      platforms: platforms,
      enemies: enemies,
      collectibles: collectibles,
      hazards: hazards,
      checkpoints: checkpoints,
      goalPortal: GameEntity(id: 'goal', type: EntityType.goalPortal, x: map.finishX, y: map.finishY, width: 60, height: 90),
    );

    _engine.levelData = customLevel;
    _engine.spawnX = map.playerStartX;
    _engine.spawnY = map.playerStartY;
    _engine.player.reset(map.playerStartX, map.playerStartY);
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    _time += dt;

    _engine.tick(dt);

    if (_engine.status == GameStatus.victory && !_hasSavedProgress) {
      _hasSavedProgress = true;
      CustomMapProgressController.instance.recordMapCompletion(
        widget.mapData.id,
        timeSeconds: _time,
        coinsCollected: _engine.player.coins,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ticker.dispose();
    _engine.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    final bool isDown = event is KeyDownEvent;
    final bool isUp = event is KeyUpEvent;
    final bool isRepeat = event is KeyRepeatEvent;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyA) {
      if (isDown) _engine.setKeyLeft(true);
      if (isUp) _engine.setKeyLeft(false);
    } else if (key == LogicalKeyboardKey.keyD) {
      if (isDown) _engine.setKeyRight(true);
      if (isUp) _engine.setKeyRight(false);
    } else if (key == LogicalKeyboardKey.keyS) {
      if (isDown) _engine.setKeyDown(true);
      if (isUp) _engine.setKeyDown(false);
    } else if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.space) {
      if (isDown && !isRepeat) {
        _engine.jump();
      } else if (isUp) {
        _engine.releaseJump();
      }
    } else if (key == LogicalKeyboardKey.keyJ) {
      if (isDown && !isRepeat) {
        _engine.attack();
      }
    } else if (key == LogicalKeyboardKey.escape) {
      if (isDown && !isRepeat) {
        _engine.togglePause();
      }
    }
  }

  void _restartMap() {
    setState(() {
      _hasSavedProgress = false;
      _time = 0.0;
      _loadCustomLevelData();
      _engine.status = GameStatus.playing;
    });
  }

  void _openMapEditor() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MapEditorScreen(mapData: widget.mapData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    _engine.updateScreenSize(screenSize.width, screenSize.height);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: GameColors.skyBackground,
        body: ListenableBuilder(
          listenable: _engine,
          builder: (context, _) {
            return Stack(
              children: [
                // 1. World & Platforms
                CustomPaint(
                  size: screenSize,
                  painter: ForestPainter(
                    levelData: _engine.levelData,
                    cameraX: _engine.cameraX,
                    cameraY: _engine.cameraY,
                    time: _time,
                  ),
                ),

                // 2. Enemies & Hazards
                CustomPaint(
                  size: screenSize,
                  painter: EnemyPainter(
                    levelData: _engine.levelData,
                    cameraX: _engine.cameraX,
                    cameraY: _engine.cameraY,
                    time: _time,
                  ),
                ),

                // 3. Player Character
                CustomPaint(
                  size: screenSize,
                  painter: CharacterPainter(
                    player: _engine.player,
                    cameraX: _engine.cameraX,
                    cameraY: _engine.cameraY,
                    time: _time,
                  ),
                ),

                // 4. Particles
                CustomPaint(
                  size: screenSize,
                  painter: ParticlePainter(
                    particles: _engine.particles,
                    cameraX: _engine.cameraX,
                    cameraY: _engine.cameraY,
                    time: _time,
                  ),
                ),

                // 5. Game HUD
                SafeArea(
                  child: GameHud(
                    currentHealth: _engine.player.currentHealth,
                    maxHealth: _engine.player.maxHealth,
                    coins: _engine.player.coins,
                    onPause: () => _engine.togglePause(),
                  ),
                ),

                // 6. Mobile Touch Controls
                if (_engine.status == GameStatus.playing)
                  Positioned(
                    left: isLandscape ? padding.left + 24 : 20,
                    bottom: isLandscape ? 20 : 30,
                    child: VirtualJoystick(
                      onChanged: (val) => _engine.setJoystickInput(val),
                    ),
                  ),

                if (_engine.status == GameStatus.playing)
                  Positioned(
                    right: isLandscape ? padding.right + 24 : 20,
                    bottom: isLandscape ? 20 : 30,
                    child: ActionButtons(
                      onJump: () => _engine.jump(),
                      onJumpRelease: () => _engine.releaseJump(),
                      onAttack: () => _engine.attack(),
                    ),
                  ),

                // 7. Custom Map Pause Overlay
                if (_engine.status == GameStatus.paused)
                  _buildCustomPauseOverlay(),

                // 8. Custom Map Game Over Overlay
                if (_engine.status == GameStatus.gameOver)
                  _buildCustomGameOverOverlay(),

                // 9. Custom Map Completion Overlay
                if (_engine.status == GameStatus.victory)
                  _buildCustomVictoryOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomPauseOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.70),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size.fromHeight(44)),
                onPressed: () => _engine.togglePause(),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text('RESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), minimumSize: const Size.fromHeight(44)),
                onPressed: _restartMap,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('RESTART MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), minimumSize: const Size.fromHeight(44)),
                onPressed: _openMapEditor,
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                label: const Text('EDIT MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(44)),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70),
                label: const Text('EXIT TO MY MAPS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomGameOverOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE1E1B4B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFF3333), width: 1.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'YOU FELL!',
                style: TextStyle(color: Color(0xFFFF4D4D), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(widget.mapData.name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size.fromHeight(44)),
                onPressed: _restartMap,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('TRY AGAIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), minimumSize: const Size.fromHeight(44)),
                onPressed: _openMapEditor,
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                label: const Text('EDIT MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(44)),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('EXIT TO MY MAPS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomVictoryOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF80FFDB), width: 2.0),
            boxShadow: const [BoxShadow(color: Color(0x6680FFDB), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF80FFDB), Color(0xFF38BDF8), Color(0xFFEAB308)],
                ).createShader(bounds),
                child: const Text(
                  'MAP COMPLETE!',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 6),
              Text(widget.mapData.name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('TIME', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${_time.toStringAsFixed(1)}s', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('COINS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${_engine.player.coins}', style: const TextStyle(color: GameColors.coinGold, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size.fromHeight(44)),
                onPressed: _restartMap,
                icon: const Icon(Icons.replay_rounded, color: Colors.white),
                label: const Text('PLAY AGAIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), minimumSize: const Size.fromHeight(44)),
                onPressed: _openMapEditor,
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                label: const Text('EDIT MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(44)),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('EXIT TO MY MAPS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
