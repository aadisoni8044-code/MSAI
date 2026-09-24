import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final themeMode = _prefs.getString('themeMode') ?? 'system';
    final searchEngineIndex = _prefs.getInt('searchEngine') ?? 0;
    final trackingProtection = _prefs.getBool('trackingProtection') ?? true;
    final blockCookies = _prefs.getBool('blockCookies') ?? false;
    final httpsOnly = _prefs.getBool('httpsOnly') ?? true;
    final cameraAllowed = _prefs.getBool('cameraPermission') ?? true;
    final micAllowed = _prefs.getBool('micPermission') ?? true;
    final locationAllowed = _prefs.getBool('locationPermission') ?? false;
    final notificationAllowed = _prefs.getBool('notificationPermission') ?? true;
    final aiApiKey = _prefs.getString('aiApiKey') ?? '';
    final aiModel = _prefs.getString('aiModel') ?? 'gemini-1.5-flash';

    _settings = AppSettings(
      themeMode: themeMode,
      searchEngine: SearchEngineOption.values[
          searchEngineIndex.clamp(0, SearchEngineOption.values.length - 1)],
      trackingProtection: trackingProtection,
      blockCookies: blockCookies,
      httpsOnly: httpsOnly,
      cameraPermissionAllowed: cameraAllowed,
      micPermissionAllowed: micAllowed,
      locationPermissionAllowed: locationAllowed,
      notificationPermissionAllowed: notificationAllowed,
      aiApiKey: aiApiKey,
      aiModel: aiModel,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _settings.themeMode = mode;
    await _prefs.setString('themeMode', mode);
    notifyListeners();
  }

  Future<void> setSearchEngine(SearchEngineOption engine) async {
    _settings.searchEngine = engine;
    await _prefs.setInt('searchEngine', engine.index);
    notifyListeners();
  }

  Future<void> setTrackingProtection(bool enabled) async {
    _settings.trackingProtection = enabled;
    await _prefs.setBool('trackingProtection', enabled);
    notifyListeners();
  }

  Future<void> setBlockCookies(bool enabled) async {
    _settings.blockCookies = enabled;
    await _prefs.setBool('blockCookies', enabled);
    notifyListeners();
  }

  Future<void> setHttpsOnly(bool enabled) async {
    _settings.httpsOnly = enabled;
    await _prefs.setBool('httpsOnly', enabled);
    notifyListeners();
  }

  Future<void> setPermission(String type, bool value) async {
    switch (type) {
      case 'camera':
        _settings.cameraPermissionAllowed = value;
        await _prefs.setBool('cameraPermission', value);
        break;
      case 'mic':
        _settings.micPermissionAllowed = value;
        await _prefs.setBool('micPermission', value);
        break;
      case 'location':
        _settings.locationPermissionAllowed = value;
        await _prefs.setBool('locationPermission', value);
        break;
      case 'notification':
        _settings.notificationPermissionAllowed = value;
        await _prefs.setBool('notificationPermission', value);
        break;
    }
    notifyListeners();
  }

  Future<void> setAiApiKey(String key) async {
    _settings.aiApiKey = key;
    await _prefs.setString('aiApiKey', key);
    notifyListeners();
  }

  Future<void> setAiModel(String model) async {
    _settings.aiModel = model;
    await _prefs.setString('aiModel', model);
    notifyListeners();
  }
}
