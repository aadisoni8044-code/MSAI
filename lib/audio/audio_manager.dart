import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool isMuted = false;
  bool _sfxEnabled = true;
  bool _bgmEnabled = true;

  bool get sfxEnabled => _sfxEnabled;
  bool get bgmEnabled => _bgmEnabled;

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  void toggleBgm() {
    _bgmEnabled = !_bgmEnabled;
    if (!_bgmEnabled) {
      stopBgm();
    } else {
      playBgm();
    }
  }

  Future<void> init() async {
    try {
      FlameAudio.bgm.initialize();
    } catch (e) {
      debugPrint('Audio initialization note: $e');
    }
  }

  void playJump() {
    _playSfx('jump.wav');
  }

  void playAttack() {
    _playSfx('attack.wav');
  }

  void playCollect() {
    _playSfx('collect.wav');
  }

  void playDamage() {
    _playSfx('damage.wav');
  }

  void playCheckpoint() {
    _playSfx('checkpoint.wav');
  }

  void playLevelComplete() {
    _playSfx('level_complete.wav');
  }

  void playBgm() {
    if (!_bgmEnabled) return;
    try {
      FlameAudio.bgm.play('bgm.mp3', volume: 0.4);
    } catch (e) {
      debugPrint('BGM playback note: $e');
    }
  }

  void stopBgm() {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      debugPrint('BGM stop note: $e');
    }
  }

  void _playSfx(String fileName) {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play(fileName, volume: 0.8);
    } catch (e) {
      // Audio playback fails safely if asset is missing or sound device unavailable
    }
  }
}
