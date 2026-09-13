import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchEngine {
  google('Google', 'https://www.google.com/search?q='),
  duckDuckGo('DuckDuckGo', 'https://duckduckgo.com/?q='),
  bing('Bing', 'https://www.bing.com/search?q='),
  brave('Brave', 'https://search.brave.com/search?q='),
  yahoo('Yahoo', 'https://search.yahoo.com/search?p='),
  ecosia('Ecosia', 'https://www.ecosia.org/search?q=');

  final String name;
  final String searchUrlPrefix;
  const SearchEngine(this.name, this.searchUrlPrefix);
}

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'firezip_theme_mode';
  static const String _searchEngineKey = 'firezip_search_engine';
  static const String _homepageKey = 'firezip_homepage';
  static const String _blockAdsKey = 'firezip_block_ads';
  static const String _defaultDesktopKey = 'firezip_default_desktop';

  ThemeMode _themeMode = ThemeMode.dark;
  SearchEngine _searchEngine = SearchEngine.google;
  String _homepageUrl = 'firezip://home';
  bool _blockAds = true;
  bool _defaultDesktopMode = false;

  ThemeMode get themeMode => _themeMode;
  SearchEngine get searchEngine => _searchEngine;
  String get homepageUrl => _homepageUrl;
  bool get blockAds => _blockAds;
  bool get defaultDesktopMode => _defaultDesktopMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeStr = prefs.getString(_themeKey);
      if (themeStr != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == themeStr,
          orElse: () => ThemeMode.dark,
        );
      }

      final searchStr = prefs.getString(_searchEngineKey);
      if (searchStr != null) {
        _searchEngine = SearchEngine.values.firstWhere(
          (e) => e.name == searchStr,
          orElse: () => SearchEngine.google,
        );
      }

      _homepageUrl = prefs.getString(_homepageKey) ?? 'firezip://home';
      _blockAds = prefs.getBool(_blockAdsKey) ?? true;
      _defaultDesktopMode = prefs.getBool(_defaultDesktopKey) ?? false;

      notifyListeners();
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setSearchEngine(SearchEngine engine) async {
    _searchEngine = engine;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_searchEngineKey, engine.name);
  }

  Future<void> setHomepageUrl(String url) async {
    _homepageUrl = url;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homepageKey, url);
  }

  Future<void> setBlockAds(bool value) async {
    _blockAds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_blockAdsKey, value);
  }

  Future<void> setDefaultDesktopMode(bool value) async {
    _defaultDesktopMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultDesktopKey, value);
  }
}
