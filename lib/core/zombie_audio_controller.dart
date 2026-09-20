import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';

class ZombieAudioController extends ChangeNotifier {
  static final ZombieAudioController _instance = ZombieAudioController._internal();
  static ZombieAudioController get instance => _instance;

  ZombieAudioController._internal();

  AudioPlayer? _musicPlayer;
  AudioPlayer? _windPlayer;
  final List<AudioPlayer> _sfxPool = [];
  int _nextPoolIndex = 0;

  bool _isZombieAudioActive = false;
  bool get isZombieAudioActive => _isZombieAudioActive;

  final Random _random = Random();

  // Cooldown timers in milliseconds
  int _lastGrowlTime = 0;
  int _lastAttackTime = 0;
  int _lastHitTime = 0;
  int _lastTowerStepTime = 0;
  int _lastZombieStepTime = 0;
  int _lastChaseTime = 0;

  void init() {
    if (_sfxPool.isNotEmpty) return;

    try {
      _musicPlayer = AudioPlayer();
      _windPlayer = AudioPlayer();

      // Pool of 8 reusable SFX players
      for (int i = 0; i < 8; i++) {
        _sfxPool.add(AudioPlayer());
      }
    } catch (e) {
      debugPrint('ZombieAudioController init warning: $e');
    }
  }

  double get _sfxVolume {
    return SettingsController.instance.soundEnabled ? 1.0 : 0.0;
  }

  double get _musicVolume {
    return SettingsController.instance.musicEnabled ? 0.6 : 0.0;
  }

  Future<void> startZombieModeAudio() async {
    init();
    _isZombieAudioActive = true;

    try {
      if (_musicVolume > 0 && _musicPlayer != null) {
        await _musicPlayer!.stop();
        await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer!.setVolume(_musicVolume * 0.5);
        await _musicPlayer!.play(AssetSource('audio/zombie/zombie_bg_music.wav'));
      }

      if (_sfxVolume > 0 && _windPlayer != null) {
        await _windPlayer!.stop();
        await _windPlayer!.setReleaseMode(ReleaseMode.loop);
        await _windPlayer!.setVolume(0.25);
        await _windPlayer!.play(AssetSource('audio/zombie/night_wind.wav'));
      }
    } catch (e) {
      debugPrint('Error starting zombie mode audio: $e');
    }
  }

  Future<void> stopAllZombieAudio() async {
    _isZombieAudioActive = false;
    try {
      await _musicPlayer?.stop();
      await _windPlayer?.stop();
      for (final p in _sfxPool) {
        await p.stop();
      }
    } catch (e) {
      debugPrint('Error stopping zombie audio: $e');
    }
  }

  // Distance attenuation factor: 1.0 at 0px -> 0.0 at 1200px
  double _calculateDistanceFactor(double distance) {
    if (distance <= 200) return 1.0;
    if (distance >= 1200) return 0.0;
    return (1.0 - (distance - 200) / 1000.0).clamp(0.0, 1.0);
  }

  Future<void> _playSfx(
    String assetPath, {
    double volumeFactor = 1.0,
    double distance = 0.0,
    int minIntervalMs = 0,
    int? timerRefKey,
  }) async {
    if (!_isZombieAudioActive || _sfxVolume <= 0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (minIntervalMs > 0 && timerRefKey != null) {
      if (timerRefKey + minIntervalMs > now) return;
    }

    final double distFactor = _calculateDistanceFactor(distance);
    if (distFactor <= 0.01) return;

    // Random volume variation ±12%
    final randomVolVar = 0.88 + _random.nextDouble() * 0.24;
    final finalVolume = (_sfxVolume * volumeFactor * distFactor * randomVolVar).clamp(0.0, 1.0);

    // Random playback rate (pitch) variation: 0.92 to 1.08
    final randomRate = 0.92 + _random.nextDouble() * 0.16;

    try {
      if (_sfxPool.isEmpty) return;
      final player = _sfxPool[_nextPoolIndex];
      _nextPoolIndex = (_nextPoolIndex + 1) % _sfxPool.length;

      await player.stop();
      await player.setVolume(finalVolume);
      await player.setPlaybackRate(randomRate);
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sfx $assetPath: $e');
    }
  }

  void playSpatialGrowl({required double distance, bool isLarge = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastGrowlTime < 1400) return;
    _lastGrowlTime = now;

    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_roar.wav', volumeFactor: 0.95, distance: distance);
    } else {
      final growls = [
        'audio/zombie/zombie_growl_1.wav',
        'audio/zombie/zombie_growl_2.wav',
        'audio/zombie/zombie_growl_3.wav',
      ];
      final String file = growls[_random.nextInt(growls.length)];
      _playSfx(file, volumeFactor: 0.70, distance: distance);
    }
  }

  void playZombieScream({double distance = 0.0}) {
    final screams = [
      'audio/zombie/zombie_scream_1.wav',
      'audio/zombie/zombie_scream_2.wav',
    ];
    final file = screams[_random.nextInt(screams.length)];
    _playSfx(file, volumeFactor: 0.80, distance: distance, minIntervalMs: 2200, timerRefKey: _lastGrowlTime);
  }

  void playChaseAmbience(int activeZombiesCount, {double minDistance = 0.0}) {
    if (activeZombiesCount <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastChaseTime < 2800) return;
    _lastChaseTime = now;

    _playSfx(
      'audio/zombie/zombie_chase.wav',
      volumeFactor: min(1.0, 0.45 + activeZombiesCount * 0.05),
      distance: minDistance,
    );
  }

  void playZombieAttack({bool isLarge = false, double distance = 0.0}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastAttackTime < 600) return;
    _lastAttackTime = now;

    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_roar.wav', volumeFactor: 1.0, distance: distance);
    } else {
      _playSfx('audio/zombie/zombie_attack.wav', volumeFactor: 0.85, distance: distance);
    }
  }

  void playPlayerAttack({bool isHeavy = false}) {
    final file = isHeavy ? 'audio/zombie/player_attack_2.wav' : 'audio/zombie/player_attack_1.wav';
    _playSfx(file, volumeFactor: 0.80);
  }

  void playHitImpact({bool isHeavy = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHitTime < 120) return;
    _lastHitTime = now;

    final file = isHeavy ? 'audio/zombie/hit_impact_heavy.wav' : 'audio/zombie/hit_impact_normal.wav';
    _playSfx(file, volumeFactor: 0.90);
  }

  void playZombieDeath({bool isLarge = false, double distance = 0.0}) {
    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_death.wav', volumeFactor: 1.0, distance: distance);
    } else {
      final deaths = [
        'audio/zombie/zombie_death_1.wav',
        'audio/zombie/zombie_death_2.wav',
        'audio/zombie/zombie_death_3.wav',
      ];
      final file = deaths[_random.nextInt(deaths.length)];
      _playSfx(file, volumeFactor: 0.80, distance: distance);
    }
  }

  void playZombieFootstep({bool isLarge = false, required double distance}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cooldown = isLarge ? 500 : 320;
    if (now - _lastZombieStepTime < cooldown) return;
    _lastZombieStepTime = now;

    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_step.wav', volumeFactor: 0.85, distance: distance);
    }
  }

  void playWaveWarning() {
    _playSfx('audio/zombie/wave_warning.wav', volumeFactor: 0.95);
  }

  void playCountdownBeep(int secondsLeft) {
    _playSfx('audio/zombie/countdown_beep.wav', volumeFactor: secondsLeft <= 3 ? 0.95 : 0.65);
  }

  void playTowerStep() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTowerStepTime < 300) return;
    _lastTowerStepTime = now;

    _playSfx('audio/zombie/tower_step.wav', volumeFactor: 0.60);
  }

  void updateHordeIntensity({required int nearbyZombieCount, required bool isPlayerOnTower}) {
    if (!_isZombieAudioActive) return;

    try {
      if (_musicPlayer != null && _musicVolume > 0) {
        double musicVol = _musicVolume * 0.5;
        if (nearbyZombieCount >= 8) {
          musicVol = _musicVolume * 0.85; // Higher tension pulse when horde is large
        }
        if (isPlayerOnTower) {
          musicVol = _musicVolume * 0.40; // Slightly lower music on tower
        }
        _musicPlayer!.setVolume(musicVol.clamp(0.0, 1.0));
      }

      if (_windPlayer != null && _sfxVolume > 0) {
        double windVol = isPlayerOnTower ? 0.45 : 0.20;
        _windPlayer!.setVolume(windVol.clamp(0.0, 1.0));
      }
    } catch (e) {
      debugPrint('Error updating horde intensity: $e');
    }
  }

  @override
  void dispose() {
    stopAllZombieAudio();
    _musicPlayer?.dispose();
    _windPlayer?.dispose();
    for (final p in _sfxPool) {
      p.dispose();
    }
    _sfxPool.clear();
    super.dispose();
  }
}
