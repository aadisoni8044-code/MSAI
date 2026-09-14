import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import '../models/enemy_model.dart';
import '../models/level_model.dart';
import '../models/game_state.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  double maxLife;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
    required this.maxLife,
    required this.color,
  });
}

enum SoundEvent {
  jump,
  attack,
  dash,
  hitPlayer,
  hitEnemy,
  collectCrystal,
  collectCoin,
  enemyDeath,
  buttonPress,
  checkpoint,
  levelWin,
}

class GameService extends ChangeNotifier {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  PlayerModel player = PlayerModel();
  GameSettings settings = GameSettings();
  GameProgress progress = GameProgress();

  LevelModel? currentLevel;
  List<EnemyModel> enemies = [];
  List<Particle> particles = [];

  double cameraX = 0.0;
  double cameraY = 0.0;
  double cameraShake = 0.0;

  double levelTime = 0.0;
  bool isPaused = false;
  bool isGameOver = false;
  bool isLevelComplete = false;

  Offset? activeCheckpoint;
  final Random _random = Random();

  // Key state tracking
  bool keyLeft = false;
  bool keyRight = false;
  bool keyJumpPressed = false;
  bool keyAttackPressed = false;
  bool keyDashPressed = false;

  void init() async {
    await loadSaveData();
    loadLevel(progress.currentLevelId);
  }

  // --- SAVE / LOAD SYSTEM ---
  Future<void> loadSaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final settingsString = prefs.getString('msai_forestbound_settings');
      if (settingsString != null) {
        settings = GameSettings.fromJson(jsonDecode(settingsString));
      }

      final progressString = prefs.getString('msai_forestbound_progress');
      if (progressString != null) {
        progress = GameProgress.fromJson(jsonDecode(progressString));
      }

      final playerString = prefs.getString('msai_forestbound_player');
      if (playerString != null) {
        player.loadFromJson(jsonDecode(playerString));
      }
    } catch (e) {
      debugPrint("Error loading save data: $e");
    }
  }

  Future<void> saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('msai_forestbound_settings', jsonEncode(settings.toJson()));
      await prefs.setString('msai_forestbound_progress', jsonEncode(progress.toJson()));
      await prefs.setString('msai_forestbound_player', jsonEncode(player.toJson()));
    } catch (e) {
      debugPrint("Error saving game data: $e");
    }
  }

  // --- AUDIO ARCHITECTURE HOOKS ---
  void playSound(SoundEvent event) {
    if (!settings.soundEnabled) return;
    // Audio engine hook: integrated for future native audio synthesis/playback
    // Flutter Web/Mobile native audio trigger dispatch
  }

  // --- LEVEL DEFINITIONS ---
  void loadLevel(int levelId) {
    progress.currentLevelId = levelId;
    isPaused = false;
    isGameOver = false;
    isLevelComplete = false;
    levelTime = 0.0;
    particles.clear();

    switch (levelId) {
      case 1:
        currentLevel = _buildLevel1();
        break;
      case 2:
        currentLevel = _buildLevel2();
        break;
      case 3:
        currentLevel = _buildLevel3();
        break;
      default:
        currentLevel = _buildLevel1();
        break;
    }

    activeCheckpoint = currentLevel!.spawnPoint;
    player.reset(currentLevel!.spawnPoint.dx, currentLevel!.spawnPoint.dy);
    enemies = _buildEnemiesForLevel(levelId);

    _updateCamera(0.016, Size(800, 600));
    notifyListeners();
  }

  LevelModel _buildLevel1() {
    // Whispering Woods: 3000px width
    final platforms = <PlatformModel>[
      // Ground platforms
      PlatformModel(id: 'g1', x: 0, y: 520, width: 800, height: 120),
      PlatformModel(id: 'g2', x: 900, y: 520, width: 700, height: 120),
      PlatformModel(id: 'g3', x: 1700, y: 520, width: 1300, height: 120),

      // Mid platforms
      PlatformModel(id: 'p1', x: 250, y: 400, width: 160, height: 28),
      PlatformModel(id: 'p2', x: 500, y: 320, width: 180, height: 28),
      PlatformModel(id: 'p3', x: 820, y: 420, width: 120, height: 28, type: PlatformType.moving, moveMinX: 750, moveMaxX: 950, moveSpeed: 60),
      PlatformModel(id: 'p4', x: 1100, y: 360, width: 160, height: 28),
      PlatformModel(id: 'p5', x: 1350, y: 280, width: 140, height: 28, type: PlatformType.crumbling),
      PlatformModel(id: 'p6', x: 1600, y: 380, width: 180, height: 28),
      PlatformModel(id: 'p7', x: 1950, y: 320, width: 200, height: 28),
      PlatformModel(id: 'p8', x: 2300, y: 260, width: 160, height: 28),
      PlatformModel(id: 'p9', x: 2550, y: 400, width: 220, height: 28),

      // Hazards
      PlatformModel(id: 'sp1', x: 1150, y: 500, width: 100, height: 20, type: PlatformType.spike),
      PlatformModel(id: 'sp2', x: 2000, y: 500, width: 140, height: 20, type: PlatformType.spike),
    ];

    final collectibles = <CollectibleModel>[
      CollectibleModel(id: 'c1', x: 300, y: 360, type: CollectibleType.coin),
      CollectibleModel(id: 'c2', x: 580, y: 280, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c3', x: 1150, y: 310, type: CollectibleType.coin),
      CollectibleModel(id: 'c4', x: 1380, y: 230, type: CollectibleType.healthPickup),
      CollectibleModel(id: 'c5', x: 1700, y: 330, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c6', x: 2000, y: 270, type: CollectibleType.secretRune),
      CollectibleModel(id: 'c7', x: 2380, y: 210, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c8', x: 2650, y: 350, type: CollectibleType.coin),
    ];

    final checkpoints = <CheckpointModel>[
      CheckpointModel(id: 'cp1', x: 1500, y: 520),
    ];

    return LevelModel(
      id: 1,
      name: 'Whispering Woods',
      subtitle: 'Where the dark vines dance and misty shadows lurk',
      worldWidth: 3000,
      worldHeight: 700,
      spawnPoint: const Offset(100, 420),
      exitPortal: const Rect.fromLTWH(2800, 420, 60, 100),
      primaryColor: const Color(0xFF0F3B3E),
      secondaryColor: const Color(0xFF165B5C),
      fogColor: const Color(0x334F908E),
      platforms: platforms,
      collectibles: collectibles,
      checkpoints: checkpoints,
    );
  }

  LevelModel _buildLevel2() {
    // Forgotten Roots: 3600px width
    final platforms = <PlatformModel>[
      PlatformModel(id: 'g1', x: 0, y: 520, width: 600, height: 120),
      PlatformModel(id: 'g2', x: 750, y: 540, width: 500, height: 120),
      PlatformModel(id: 'g3', x: 1400, y: 520, width: 600, height: 120),
      PlatformModel(id: 'g4', x: 2200, y: 520, width: 1400, height: 120),

      PlatformModel(id: 'p1', x: 200, y: 400, width: 140, height: 28),
      PlatformModel(id: 'p2', x: 420, y: 300, width: 160, height: 28, type: PlatformType.moving, moveMinX: 380, moveMaxX: 580, moveSpeed: 80),
      PlatformModel(id: 'p3', x: 650, y: 420, width: 120, height: 28, type: PlatformType.crumbling),
      PlatformModel(id: 'p4', x: 900, y: 380, width: 160, height: 28),
      PlatformModel(id: 'p5', x: 1150, y: 280, width: 140, height: 28),
      PlatformModel(id: 'p6', x: 1450, y: 380, width: 180, height: 28),
      PlatformModel(id: 'p7', x: 1750, y: 300, width: 160, height: 28, type: PlatformType.moving, moveMinX: 1700, moveMaxX: 1950, moveSpeed: 100),
      PlatformModel(id: 'p8', x: 2050, y: 420, width: 120, height: 28, type: PlatformType.crumbling),
      PlatformModel(id: 'p9', x: 2350, y: 340, width: 220, height: 28),
      PlatformModel(id: 'p10', x: 2700, y: 260, width: 180, height: 28),
      PlatformModel(id: 'p11', x: 3050, y: 380, width: 200, height: 28),

      PlatformModel(id: 'sp1', x: 800, y: 520, width: 120, height: 20, type: PlatformType.spike),
      PlatformModel(id: 'sp2', x: 1600, y: 500, width: 160, height: 20, type: PlatformType.spike),
      PlatformModel(id: 'sp3', x: 2500, y: 500, width: 200, height: 20, type: PlatformType.spike),
    ];

    final collectibles = <CollectibleModel>[
      CollectibleModel(id: 'c1', x: 250, y: 350, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c2', x: 480, y: 250, type: CollectibleType.coin),
      CollectibleModel(id: 'c3', x: 950, y: 330, type: CollectibleType.healthPickup),
      CollectibleModel(id: 'c4', x: 1200, y: 230, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c5', x: 1800, y: 250, type: CollectibleType.secretRune),
      CollectibleModel(id: 'c6', x: 2400, y: 290, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c7', x: 2750, y: 210, type: CollectibleType.coin),
      CollectibleModel(id: 'c8', x: 3100, y: 330, type: CollectibleType.energyCrystal),
    ];

    final checkpoints = <CheckpointModel>[
      CheckpointModel(id: 'cp1', x: 1500, y: 520),
      CheckpointModel(id: 'cp2', x: 2800, y: 520),
    ];

    return LevelModel(
      id: 2,
      name: 'Forgotten Roots',
      subtitle: 'Ancient giant roots coiled in deep indigo luminescence',
      worldWidth: 3600,
      worldHeight: 700,
      spawnPoint: const Offset(100, 420),
      exitPortal: const Rect.fromLTWH(3400, 420, 60, 100),
      primaryColor: const Color(0xFF0C2B4B),
      secondaryColor: const Color(0xFF134275),
      fogColor: const Color(0x332E6A9E),
      platforms: platforms,
      collectibles: collectibles,
      checkpoints: checkpoints,
    );
  }

  LevelModel _buildLevel3() {
    // Ancient Hollow: 4200px width
    final platforms = <PlatformModel>[
      PlatformModel(id: 'g1', x: 0, y: 520, width: 700, height: 120),
      PlatformModel(id: 'g2', x: 850, y: 520, width: 600, height: 120),
      PlatformModel(id: 'g3', x: 1600, y: 540, width: 700, height: 120),
      PlatformModel(id: 'g4', x: 2500, y: 520, width: 1700, height: 120),

      PlatformModel(id: 'p1', x: 250, y: 380, width: 160, height: 28),
      PlatformModel(id: 'p2', x: 500, y: 280, width: 140, height: 28, type: PlatformType.moving, moveMinX: 450, moveMaxX: 680, moveSpeed: 90),
      PlatformModel(id: 'p3', x: 750, y: 400, width: 140, height: 28, type: PlatformType.crumbling),
      PlatformModel(id: 'p4', x: 1000, y: 320, width: 180, height: 28),
      PlatformModel(id: 'p5', x: 1300, y: 240, width: 160, height: 28),
      PlatformModel(id: 'p6', x: 1700, y: 380, width: 180, height: 28),
      PlatformModel(id: 'p7', x: 2000, y: 280, width: 160, height: 28, type: PlatformType.moving, moveMinX: 1950, moveMaxX: 2250, moveSpeed: 110),
      PlatformModel(id: 'p8', x: 2350, y: 400, width: 140, height: 28, type: PlatformType.crumbling),
      PlatformModel(id: 'p9', x: 2650, y: 320, width: 220, height: 28),
      PlatformModel(id: 'p10', x: 3000, y: 220, width: 200, height: 28),
      PlatformModel(id: 'p11', x: 3350, y: 340, width: 240, height: 28),
      PlatformModel(id: 'p12', x: 3700, y: 260, width: 200, height: 28),

      PlatformModel(id: 'sp1', x: 950, y: 500, width: 180, height: 20, type: PlatformType.spike),
      PlatformModel(id: 'sp2', x: 1800, y: 520, width: 220, height: 20, type: PlatformType.spike),
      PlatformModel(id: 'sp3', x: 2800, y: 500, width: 300, height: 20, type: PlatformType.spike),
    ];

    final collectibles = <CollectibleModel>[
      CollectibleModel(id: 'c1', x: 300, y: 330, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c2', x: 560, y: 230, type: CollectibleType.healthPickup),
      CollectibleModel(id: 'c3', x: 1050, y: 270, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c4', x: 1350, y: 190, type: CollectibleType.secretRune),
      CollectibleModel(id: 'c5', x: 2050, y: 230, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c6', x: 2720, y: 270, type: CollectibleType.coin),
      CollectibleModel(id: 'c7', x: 3080, y: 170, type: CollectibleType.energyCrystal),
      CollectibleModel(id: 'c8', x: 3420, y: 290, type: CollectibleType.healthPickup),
      CollectibleModel(id: 'c9', x: 3750, y: 210, type: CollectibleType.energyCrystal),
    ];

    final checkpoints = <CheckpointModel>[
      CheckpointModel(id: 'cp1', x: 1500, y: 520),
      CheckpointModel(id: 'cp2', x: 2600, y: 520),
      CheckpointModel(id: 'cp3', x: 3600, y: 520),
    ];

    return LevelModel(
      id: 3,
      name: 'Ancient Hollow',
      subtitle: 'The heart of the woodland realm protected by the Guardian',
      worldWidth: 4200,
      worldHeight: 700,
      spawnPoint: const Offset(100, 420),
      exitPortal: const Rect.fromLTWH(4000, 420, 60, 100),
      primaryColor: const Color(0xFF1B1333),
      secondaryColor: const Color(0xFF33235C),
      fogColor: const Color(0x336842A6),
      platforms: platforms,
      collectibles: collectibles,
      checkpoints: checkpoints,
    );
  }

  List<EnemyModel> _buildEnemiesForLevel(int levelId) {
    if (levelId == 1) {
      return [
        EnemyModel.create(id: 'e1', type: EnemyType.forestBug, x: 400, y: 490, patrolDist: 100),
        EnemyModel.create(id: 'e2', type: EnemyType.flyingCreature, x: 950, y: 300, patrolDist: 120),
        EnemyModel.create(id: 'e3', type: EnemyType.forestBug, x: 1200, y: 490, patrolDist: 80),
        EnemyModel.create(id: 'e4', type: EnemyType.shadowCreature, x: 1800, y: 472, patrolDist: 140),
        EnemyModel.create(id: 'e5', type: EnemyType.flyingCreature, x: 2200, y: 220, patrolDist: 100),
        EnemyModel.create(id: 'e6', type: EnemyType.shadowCreature, x: 2600, y: 472, patrolDist: 100),
      ];
    } else if (levelId == 2) {
      return [
        EnemyModel.create(id: 'e1', type: EnemyType.forestBug, x: 300, y: 490, patrolDist: 80),
        EnemyModel.create(id: 'e2', type: EnemyType.shadowCreature, x: 800, y: 492, patrolDist: 120),
        EnemyModel.create(id: 'e3', type: EnemyType.flyingCreature, x: 1200, y: 220, patrolDist: 150),
        EnemyModel.create(id: 'e4', type: EnemyType.shadowCreature, x: 1600, y: 472, patrolDist: 100),
        EnemyModel.create(id: 'e5', type: EnemyType.guardian, x: 2300, y: 448, patrolDist: 120),
        EnemyModel.create(id: 'e6', type: EnemyType.flyingCreature, x: 2900, y: 200, patrolDist: 140),
      ];
    } else {
      return [
        EnemyModel.create(id: 'e1', type: EnemyType.shadowCreature, x: 450, y: 472, patrolDist: 100),
        EnemyModel.create(id: 'e2', type: EnemyType.flyingCreature, x: 900, y: 240, patrolDist: 120),
        EnemyModel.create(id: 'e3', type: EnemyType.guardian, x: 1800, y: 468, patrolDist: 150),
        EnemyModel.create(id: 'e4', type: EnemyType.shadowCreature, x: 2400, y: 472, patrolDist: 120),
        EnemyModel.create(id: 'e5', type: EnemyType.flyingCreature, x: 3100, y: 180, patrolDist: 160),
        EnemyModel.create(id: 'e6', type: EnemyType.guardian, x: 3800, y: 448, patrolDist: 100),
      ];
    }
  }

  // --- GAME LOOP UPDATE ---
  void update(double dt, Size viewportSize) {
    if (isPaused || isGameOver || isLevelComplete || currentLevel == null) return;

    levelTime += dt;

    // Regulate energy regeneration
    if (player.energy < player.maxEnergy) {
      player.energy = (player.energy + dt * 15).clamp(0.0, player.maxEnergy);
    }

    _handlePlayerTimers(dt);
    _handlePlayerMovement(dt);
    _handlePlatforms(dt);
    _handleCollisions();
    _handleCollectibles();
    _handleCheckpoints();
    _handleEnemies(dt);
    _handleParticles(dt);
    _updateCamera(dt, viewportSize);

    // Check exit portal trigger
    final playerRect = Rect.fromLTWH(player.x, player.y, player.width, player.height);
    if (playerRect.overlaps(currentLevel!.exitPortal)) {
      _completeLevel();
    }

    notifyListeners();
  }

  void _handlePlayerTimers(double dt) {
    if (player.dashTimer > 0) {
      player.dashTimer -= dt;
      if (player.dashTimer <= 0) player.isDashing = false;
    }
    if (player.dashCooldown > 0) player.dashCooldown -= dt;

    if (player.attackTimer > 0) {
      player.attackTimer -= dt;
      if (player.attackTimer <= 0) player.isAttacking = false;
    }

    if (player.hurtTimer > 0) {
      player.hurtTimer -= dt;
      if (player.hurtTimer <= 0) player.isHurt = false;
    }

    if (player.invulnerableTimer > 0) {
      player.invulnerableTimer -= dt;
    }

    if (cameraShake > 0) {
      cameraShake = (cameraShake - dt * 10).clamp(0.0, 20.0);
    }
  }

  void _handlePlayerMovement(double dt) {
    if (player.isDead) return;

    // Horizonal controls
    double moveDir = 0.0;
    if (keyLeft) moveDir -= 1.0;
    if (keyRight) moveDir += 1.0;

    if (moveDir != 0.0) {
      player.facingRight = moveDir > 0;
      double speed = player.isDashing ? 500.0 : 220.0;
      player.vx = moveDir * speed;
    } else {
      player.vx *= 0.75;
      if (player.vx.abs() < 5) player.vx = 0;
    }

    // Apply gravity
    if (!player.isDashing) {
      player.vy += 1200.0 * dt; // Gravity strength
      if (player.vy > 800) player.vy = 800; // Terminal velocity
    }

    // Update position step
    player.x += player.vx * dt;
    player.y += player.vy * dt;

    // Level horizontal boundary bounds
    if (player.x < 0) player.x = 0;
    if (player.x > currentLevel!.worldWidth - player.width) {
      player.x = currentLevel!.worldWidth - player.width;
    }

    // Bottom pit check
    if (player.y > currentLevel!.worldHeight + 100) {
      takeDamage(100);
    }

    player.updateState();
  }

  void triggerJump() {
    if (player.isDead || isPaused) return;

    if (player.isGrounded) {
      player.vy = -540.0;
      player.isGrounded = false;
      player.jumpCount = 1;
      playSound(SoundEvent.jump);
      _addDustParticles(player.x + player.width / 2, player.y + player.height, 8);
    } else if (player.jumpCount < player.maxJumps) {
      player.vy = -480.0;
      player.jumpCount++;
      playSound(SoundEvent.jump);
      _addSparkParticles(player.x + player.width / 2, player.y + player.height, const Color(0xFF64DFDF), 12);
    }
  }

  void triggerAttack() {
    if (player.isDead || isPaused || player.isAttacking) return;

    player.isAttacking = true;
    player.attackTimer = 0.35;
    playSound(SoundEvent.attack);

    // Compute attack hitbox
    double attackX = player.facingRight ? player.x + player.width : player.x - 50.0;
    Rect attackRect = Rect.fromLTWH(attackX, player.y - 10, 60, player.height + 20);

    int damageDealt = 20 + (player.damageUpgrades * 10);

    for (var enemy in enemies) {
      if (enemy.isDead) continue;
      Rect enemyRect = Rect.fromLTWH(enemy.x, enemy.y, enemy.width, enemy.height);
      if (attackRect.overlaps(enemyRect)) {
        enemy.takeDamage(damageDealt);
        playSound(SoundEvent.hitEnemy);
        triggerCameraShake(6.0);
        _addSparkParticles(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2, const Color(0xFFFF5252), 15);

        if (enemy.isDead) {
          playSound(SoundEvent.enemyDeath);
          player.coins += 10;
          progress.totalCoins += 10;
        }
      }
    }
  }

  void triggerDash() {
    if (player.isDead || isPaused || player.isDashing || player.dashCooldown > 0) return;
    if (player.energy < 25) return;

    player.energy -= 25;
    player.isDashing = true;
    player.dashTimer = 0.22;
    player.dashCooldown = 0.6;
    player.vy = 0.0; // Freeze vertical velocity during dash
    playSound(SoundEvent.dash);
    _addSparkParticles(player.x + player.width / 2, player.y + player.height / 2, const Color(0xFF80FFDB), 16);
  }

  void _handlePlatforms(double dt) {
    for (var platform in currentLevel!.platforms) {
      if (platform.type == PlatformType.moving) {
        platform.x += platform.moveSpeed * platform.moveDirection * dt;
        if (platform.x <= platform.moveMinX) {
          platform.x = platform.moveMinX;
          platform.moveDirection = 1;
        } else if (platform.x >= platform.moveMaxX) {
          platform.x = platform.moveMaxX;
          platform.moveDirection = -1;
        }
      } else if (platform.type == PlatformType.crumbling && platform.crumbleTimer > 0) {
        platform.crumbleTimer += dt;
        if (platform.crumbleTimer > 0.8) {
          platform.isBroken = true;
        }
      }
    }
  }

  void _handleCollisions() {
    player.isGrounded = false;
    Rect playerRect = Rect.fromLTWH(player.x, player.y, player.width, player.height);

    for (var platform in currentLevel!.platforms) {
      if (platform.isBroken) continue;

      if (platform.type == PlatformType.spike) {
        if (playerRect.overlaps(platform.rect)) {
          takeDamage(20);
        }
        continue;
      }

      // Standard solid platform check
      if (playerRect.overlaps(platform.rect)) {
        // Falling onto top of platform
        if (player.vy >= 0 && (player.y + player.height - player.vy * 0.03) <= platform.y + 12) {
          player.y = platform.y - player.height;
          player.vy = 0;
          player.isGrounded = true;
          player.jumpCount = 0;

          if (platform.type == PlatformType.moving) {
            player.x += platform.moveSpeed * platform.moveDirection * 0.016;
          } else if (platform.type == PlatformType.crumbling && platform.crumbleTimer == 0) {
            platform.crumbleTimer = 0.01;
          }
        }
      }
    }
  }

  void _handleCollectibles() {
    Rect playerRect = Rect.fromLTWH(player.x, player.y, player.width, player.height);

    for (var c in currentLevel!.collectibles) {
      if (c.isCollected) continue;

      if (playerRect.overlaps(c.rect)) {
        c.isCollected = true;
        switch (c.type) {
          case CollectibleType.energyCrystal:
            player.crystals++;
            progress.totalCrystals++;
            playSound(SoundEvent.collectCrystal);
            _addSparkParticles(c.x, c.y, const Color(0xFF64DFDF), 12);
            break;
          case CollectibleType.coin:
            player.coins += 5;
            progress.totalCoins += 5;
            playSound(SoundEvent.collectCoin);
            _addSparkParticles(c.x, c.y, const Color(0xFFFFD166), 10);
            break;
          case CollectibleType.healthPickup:
            player.health = (player.health + 30).clamp(0, player.maxHealth);
            playSound(SoundEvent.collectCrystal);
            _addSparkParticles(c.x, c.y, const Color(0xFF06D6A0), 12);
            break;
          case CollectibleType.secretRune:
            player.crystals += 5;
            progress.totalCrystals += 5;
            playSound(SoundEvent.collectCrystal);
            _addSparkParticles(c.x, c.y, const Color(0xFFF72585), 20);
            break;
        }
      }
    }
  }

  void _handleCheckpoints() {
    Rect playerRect = Rect.fromLTWH(player.x, player.y, player.width, player.height);

    for (var cp in currentLevel!.checkpoints) {
      if (playerRect.overlaps(cp.rect) && !cp.isActive) {
        cp.isActive = true;
        activeCheckpoint = Offset(cp.x, cp.y - player.height);
        playSound(SoundEvent.checkpoint);
        _addSparkParticles(cp.x, cp.y, const Color(0xFF4CC9F0), 20);
      }
    }
  }

  void _handleEnemies(double dt) {
    for (var enemy in enemies) {
      if (enemy.isDead) {
        if (enemy.deathTimer > 0) enemy.deathTimer -= dt;
        continue;
      }

      if (enemy.hurtTimer > 0) {
        enemy.hurtTimer -= dt;
      }

      // AI Logic
      double distToPlayer = (player.x - enemy.x).abs();

      if (distToPlayer < enemy.detectionRange && !player.isDead) {
        enemy.state = EnemyState.chase;
        enemy.facingRight = player.x > enemy.x;

        if (enemy.type == EnemyType.flyingCreature) {
          double targetY = player.y - 10;
          enemy.vy = (targetY - enemy.y).clamp(-1.0, 1.0) * enemy.speed;
        }

        if (distToPlayer < enemy.attackRange) {
          enemy.state = EnemyState.attack;
        } else {
          enemy.vx = enemy.facingRight ? enemy.speed : -enemy.speed;
        }
      } else {
        enemy.state = EnemyState.patrol;
        if (enemy.x <= enemy.startX) {
          enemy.facingRight = true;
        } else if (enemy.x >= enemy.endX) {
          enemy.facingRight = false;
        }
        enemy.vx = enemy.facingRight ? enemy.speed * 0.6 : -enemy.speed * 0.6;
      }

      enemy.x += enemy.vx * dt;
      enemy.y += enemy.vy * dt;

      // Contact damage to player
      Rect enemyRect = Rect.fromLTWH(enemy.x, enemy.y, enemy.width, enemy.height);
      Rect playerRect = Rect.fromLTWH(player.x, player.y, player.width, player.height);

      if (enemyRect.overlaps(playerRect) && !player.isDead) {
        takeDamage(enemy.damage);
      }
    }
  }

  void takeDamage(int amount) {
    if (player.invulnerableTimer > 0 || player.isDead) return;

    player.health -= amount;
    player.isHurt = true;
    player.hurtTimer = 0.3;
    player.invulnerableTimer = 1.0;
    player.vy = -200; // Knockback lift
    playSound(SoundEvent.hitPlayer);
    triggerCameraShake(10.0);
    _addSparkParticles(player.x + player.width / 2, player.y + player.height / 2, const Color(0xFFEF476F), 15);

    if (player.health <= 0) {
      player.health = 0;
      player.isDead = true;
      isGameOver = true;
      playSound(SoundEvent.hitPlayer);
    }
  }

  void respawnAtCheckpoint() {
    if (activeCheckpoint != null) {
      player.reset(activeCheckpoint!.dx, activeCheckpoint!.dy);
    } else if (currentLevel != null) {
      player.reset(currentLevel!.spawnPoint.dx, currentLevel!.spawnPoint.dy);
    }
    isGameOver = false;
    notifyListeners();
  }

  void _completeLevel() {
    if (isLevelComplete) return;

    isLevelComplete = true;
    playSound(SoundEvent.levelWin);

    // Calculate stars earned (1..3)
    int stars = 1;
    if (player.health > player.maxHealth * 0.5) stars++;
    if (player.crystals >= 3) stars++;

    progress.levelStars[progress.currentLevelId] = max(progress.levelStars[progress.currentLevelId] ?? 0, stars);

    // Unlock next level
    int nextLevel = progress.currentLevelId + 1;
    if (nextLevel <= 3) {
      progress.unlockedLevels.add(nextLevel);
    }

    saveGameData();
    notifyListeners();
  }

  void triggerCameraShake(double amount) {
    cameraShake = amount;
  }

  void _updateCamera(double dt, Size viewportSize) {
    if (currentLevel == null) return;

    double targetX = player.x + player.width / 2 - viewportSize.width / 2;
    double targetY = player.y + player.height / 2 - viewportSize.height * 0.6;

    // Clamp camera within world bounds
    targetX = targetX.clamp(0.0, max(0.0, currentLevel!.worldWidth - viewportSize.width));
    targetY = targetY.clamp(0.0, max(0.0, currentLevel!.worldHeight - viewportSize.height));

    // Smooth lerp camera tracking
    cameraX += (targetX - cameraX) * 0.1;
    cameraY += (targetY - cameraY) * 0.1;
  }

  // --- PARTICLE SYSTEM ---
  void _addSparkParticles(double x, double y, Color color, int count) {
    for (int i = 0; i < count; i++) {
      double angle = _random.nextDouble() * pi * 2;
      double speed = 40 + _random.nextDouble() * 120;
      particles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 3 + _random.nextDouble() * 4,
        life: 0.4 + _random.nextDouble() * 0.4,
        maxLife: 0.8,
        color: color,
      ));
    }
  }

  void _addDustParticles(double x, double y, int count) {
    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 60,
        vy: -20 - _random.nextDouble() * 40,
        size: 4 + _random.nextDouble() * 5,
        life: 0.3 + _random.nextDouble() * 0.3,
        maxLife: 0.6,
        color: const Color(0x66FFFFFF),
      ));
    }
  }

  void _handleParticles(double dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      var p = particles[i];
      p.life -= dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      if (p.life <= 0) {
        particles.removeAt(i);
      }
    }
  }
}
