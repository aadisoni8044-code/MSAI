import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  AppThemeMode get themeMode => _settings.themeMode;

  ThemeProvider({required StorageService storageService})
      : _storageService = storageService {
    _init();
  }

  void _init() async {
    _settings = await _storageService.loadAppSettings();
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _storageService.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveAppSettings(_settings);
    notifyListeners();
  }
}
