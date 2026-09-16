import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool soundEnabled = true;
  bool musicEnabled = true;

  Future<void> init() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBGM(String assetName) async {
    if (!musicEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource(assetName));
    } catch (e) {
      debugPrint("BGM playback notice (asset placeholder): $e");
    }
  }

  Future<void> playSFX(String assetName) async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetName));
    } catch (e) {
      debugPrint("SFX playback notice (asset placeholder): $e");
    }
  }

  void playJump() => playSFX('audio/jump.wav');
  void playAttack() => playSFX('audio/attack.wav');
  void playCollect() => playSFX('audio/collect.wav');
  void playHurt() => playSFX('audio/hurt.wav');
  void playCheckpoint() => playSFX('audio/checkpoint.wav');
  void playLevelComplete() => playSFX('audio/win.wav');

  void stopBGM() {
    _bgmPlayer.stop();
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  void toggleMusic() {
    musicEnabled = !musicEnabled;
    if (!musicEnabled) {
      stopBGM();
    }
  }
}
