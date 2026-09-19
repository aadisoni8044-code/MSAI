import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum GameOrientationMode {
  portrait,
  landscape,
}

class SettingsController extends ChangeNotifier {
  static final SettingsController instance = SettingsController._internal();

  factory SettingsController() {
    return instance;
  }

  SettingsController._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  GameOrientationMode _orientationMode = GameOrientationMode.portrait;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  GameOrientationMode get orientationMode => _orientationMode;

  void setSoundEnabled(bool value) {
    if (_soundEnabled != value) {
      _soundEnabled = value;
      notifyListeners();
    }
  }

  void setMusicEnabled(bool value) {
    if (_musicEnabled != value) {
      _musicEnabled = value;
      notifyListeners();
    }
  }

  void setOrientationMode(GameOrientationMode mode) {
    if (_orientationMode != mode) {
      _orientationMode = mode;
      _applyOrientation();
      notifyListeners();
    }
  }

  void _applyOrientation() {
    if (_orientationMode == GameOrientationMode.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void applyCurrentOrientation() {
    _applyOrientation();
  }
}
