import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isPrivateAccount = true;
  bool _locationGeofiltersEnabled = true;
  int _cacheSizeBytes = 18450000; // ~18.4 MB

  bool get isDarkMode => _isDarkMode;
  bool get isPrivateAccount => _isPrivateAccount;
  bool get locationGeofiltersEnabled => _locationGeofiltersEnabled;
  int get cacheSizeBytes => _cacheSizeBytes;
  String get formattedCacheSize => '${(_cacheSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _isPrivateAccount = prefs.getBool('isPrivateAccount') ?? true;
      _locationGeofiltersEnabled = prefs.getBool('locationGeofiltersEnabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> togglePrivateAccount(bool value) async {
    _isPrivateAccount = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPrivateAccount', value);
  }

  Future<void> toggleLocationGeofilters(bool value) async {
    _locationGeofiltersEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationGeofiltersEnabled', value);
  }

  Future<void> clearCache() async {
    _cacheSizeBytes = 0;
    notifyListeners();
  }
}
