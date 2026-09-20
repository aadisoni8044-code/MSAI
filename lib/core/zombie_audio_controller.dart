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
  int _lastChaseTime = 0;

  void init() {
    if (_sfxPool.isNotEmpty) return;

    try {
      _musicPlayer = AudioPlayer();
      _windPlayer = AudioPlayer();

      for (int i = 0; i < 6; i++) {
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
        await _musicPlayer!.setVolume(_musicVolume);
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

  Future<void> _playSfx(String assetPath, {double volumeFactor = 1.0, int minIntervalMs = 0, int? timerRefKey}) async {
    if (!_isZombieAudioActive || _sfxVolume <= 0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (minIntervalMs > 0 && timerRefKey != null) {
      if (timerRefKey + minIntervalMs > now) return;
    }

    try {
      if (_sfxPool.isEmpty) return;
      final player = _sfxPool[_nextPoolIndex];
      _nextPoolIndex = (_nextPoolIndex + 1) % _sfxPool.length;

      await player.stop();
      await player.setVolume((_sfxVolume * volumeFactor).clamp(0.0, 1.0));
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sfx $assetPath: $e');
    }
  }

  void playZombieGrowl({bool isLarge = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastGrowlTime < 1800) return;
    _lastGrowlTime = now;

    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_roar.wav', volumeFactor: 0.9);
    } else {
      final String file = _random.nextBool()
          ? 'audio/zombie/zombie_growl_1.wav'
          : 'audio/zombie/zombie_growl_2.wav';
      _playSfx(file, volumeFactor: 0.65);
    }
  }

  void playZombieScream() {
    _playSfx('audio/zombie/zombie_scream.wav', volumeFactor: 0.75, minIntervalMs: 2500, timerRefKey: _lastGrowlTime);
  }

  void playChaseAmbience(int activeZombiesCount) {
    if (activeZombiesCount <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastChaseTime < 3000) return;
    _lastChaseTime = now;

    _playSfx('audio/zombie/zombie_chase.wav', volumeFactor: min(1.0, 0.4 + activeZombiesCount * 0.05));
  }

  void playZombieAttack({bool isLarge = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastAttackTime < 800) return;
    _lastAttackTime = now;

    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_roar.wav', volumeFactor: 1.0);
    } else {
      _playSfx('audio/zombie/zombie_attack.wav', volumeFactor: 0.8);
    }
  }

  void playPlayerAttack() {
    _playSfx('audio/zombie/player_attack.wav', volumeFactor: 0.7);
  }

  void playHitImpact() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHitTime < 150) return;
    _lastHitTime = now;

    _playSfx('audio/zombie/hit_impact.wav', volumeFactor: 0.85);
  }

  void playZombieDeath({bool isLarge = false}) {
    if (isLarge) {
      _playSfx('audio/zombie/large_zombie_death.wav', volumeFactor: 0.95);
    } else {
      final file = _random.nextBool()
          ? 'audio/zombie/zombie_death_1.wav'
          : 'audio/zombie/zombie_death_2.wav';
      _playSfx(file, volumeFactor: 0.75);
    }
  }

  void playWaveWarning() {
    _playSfx('audio/zombie/wave_warning.wav', volumeFactor: 0.9);
  }

  void playCountdownBeep(int secondsLeft) {
    _playSfx('audio/zombie/countdown_beep.wav', volumeFactor: secondsLeft <= 3 ? 0.9 : 0.6);
  }

  void playTowerStep() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTowerStepTime < 350) return;
    _lastTowerStepTime = now;

    _playSfx('audio/zombie/tower_step.wav', volumeFactor: 0.5);
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
