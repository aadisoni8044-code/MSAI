import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tab_model.dart';
import '../models/history_item_model.dart';
import 'settings_provider.dart';

class BrowserProvider with ChangeNotifier {
  static const String _tabsStorageKey = 'firezip_tabs';
  static const String _activeTabStorageKey = 'firezip_active_tab';
  static const String _historyStorageKey = 'firezip_history';

  final List<TabModel> _tabs = [];
  int _activeTabIndex = 0;
  final List<HistoryItemModel> _history = [];

  List<TabModel> get tabs => List.unmodifiable(_tabs);
  int get activeTabIndex => _activeTabIndex;
  List<HistoryItemModel> get history => List.unmodifiable(_history);

  TabModel get currentTab {
    if (_tabs.isEmpty) {
      final initialTab = TabModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: 'firezip://home',
        title: 'Firezip Home',
      );
      _tabs.add(initialTab);
      _activeTabIndex = 0;
      return initialTab;
    }
    if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    }
    return _tabs[_activeTabIndex];
  }

  BrowserProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load History
      final String? historyJson = prefs.getString(_historyStorageKey);
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(historyJson);
        _history.clear();
        _history.addAll(list.map((item) => HistoryItemModel.fromJson(item)));
      } else {
        _populateDefaultHistory();
      }

      // Load Tabs
      final String? tabsJson = prefs.getString(_tabsStorageKey);
      if (tabsJson != null && tabsJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(tabsJson);
        _tabs.clear();
        _tabs.addAll(list.map((item) => TabModel.fromJson(item)));
        _activeTabIndex = prefs.getInt(_activeTabStorageKey) ?? 0;
        if (_activeTabIndex >= _tabs.length) {
          _activeTabIndex = _tabs.length > 0 ? _tabs.length - 1 : 0;
        }
      }

      if (_tabs.isEmpty) {
        _tabs.add(TabModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: 'firezip://home',
          title: 'Firezip Home',
        ));
        _activeTabIndex = 0;
      }
    } catch (_) {
      if (_tabs.isEmpty) {
        _tabs.add(TabModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: 'firezip://home',
          title: 'Firezip Home',
        ));
        _activeTabIndex = 0;
      }
    }
    notifyListeners();
  }

  void _populateDefaultHistory() {
    _history.clear();
    _history.addAll([
      HistoryItemModel(
        id: 'h1',
        title: 'Google Search',
        url: 'https://www.google.com',
        visitedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      HistoryItemModel(
        id: 'h2',
        title: 'GitHub: Let\'s build from here',
        url: 'https://github.com',
        visitedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      HistoryItemModel(
        id: 'h3',
        title: 'Wikipedia - The Free Encyclopedia',
        url: 'https://www.wikipedia.org',
        visitedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      HistoryItemModel(
        id: 'h4',
        title: 'Flutter - Build apps for any screen',
        url: 'https://flutter.dev',
        visitedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
    _saveHistory();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tabsJson = jsonEncode(_tabs.map((e) => e.toJson()).toList());
      await prefs.setString(_tabsStorageKey, tabsJson);
      await prefs.setInt(_activeTabStorageKey, _activeTabIndex);
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_history.map((e) => e.toJson()).toList());
      await prefs.setString(_historyStorageKey, historyJson);
    } catch (_) {}
  }

  // --- Tab Management ---

  void openNewTab({String url = 'firezip://home', String title = 'Firezip Home'}) {
    final tab = TabModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: title,
    );
    _tabs.add(tab);
    _activeTabIndex = _tabs.length - 1;
    notifyListeners();
    _saveState();
  }

  void switchTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeTabIndex = index;
      notifyListeners();
      _saveState();
    }
  }

  void closeTab(int index) {
    if (_tabs.isEmpty) return;
    _tabs.removeAt(index);
    if (_tabs.isEmpty) {
      _tabs.add(TabModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: 'firezip://home',
        title: 'Firezip Home',
      ));
      _activeTabIndex = 0;
    } else if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    }
    notifyListeners();
    _saveState();
  }

  void duplicateTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      final source = _tabs[index];
      final duplicate = TabModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: source.url,
        title: source.title,
        historyStack: List.from(source.historyStack),
        historyIndex: source.historyIndex,
        isDesktopSite: source.isDesktopSite,
        zoomLevel: source.zoomLevel,
      );
      _tabs.insert(index + 1, duplicate);
      _activeTabIndex = index + 1;
      notifyListeners();
      _saveState();
    }
  }

  void closeAllTabs() {
    _tabs.clear();
    _tabs.add(TabModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: 'firezip://home',
      title: 'Firezip Home',
    ));
    _activeTabIndex = 0;
    notifyListeners();
    _saveState();
  }

  // --- Navigation & Web URL Parsing ---

  void navigateCurrentTab(String rawInput, SearchEngine searchEngine) {
    final formattedUrl = parseInputToUrl(rawInput, searchEngine);
    currentTab.navigateTo(formattedUrl);

    // Add to history if not internal start page
    if (formattedUrl != 'firezip://home') {
      _addToHistory(currentTab.title, formattedUrl);
    }

    notifyListeners();
    _saveState();
  }

  static String parseInputToUrl(String rawInput, SearchEngine searchEngine) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return 'firezip://home';
    if (trimmed == 'firezip://home' || trimmed == 'about:blank') {
      return 'firezip://home';
    }

    // Check if input is a valid URL or host name
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?' // protocol
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
      r'localhost|' // localhost
      r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' // OR ip
      r'(:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    );

    if (urlRegExp.hasMatch(trimmed) ||
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://')) {
      if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
        return 'https://$trimmed';
      }
      return trimmed;
    }

    // Check if simple single word host like "google.com" or "github.com"
    if (!trimmed.contains(' ') && trimmed.contains('.') && trimmed.split('.').last.length >= 2) {
      return 'https://$trimmed';
    }

    // Otherwise format as search query using the configured search engine
    final encodedQuery = Uri.encodeComponent(trimmed);
    return '${searchEngine.searchUrlPrefix}$encodedQuery';
  }

  void goBack() {
    if (currentTab.canGoBack) {
      currentTab.goBack();
      notifyListeners();
      _saveState();
    }
  }

  void goForward() {
    if (currentTab.canGoForward) {
      currentTab.goForward();
      notifyListeners();
      _saveState();
    }
  }

  void goHome() {
    currentTab.navigateTo('firezip://home', newTitle: 'Firezip Home');
    notifyListeners();
    _saveState();
  }

  void toggleDesktopSite() {
    currentTab.isDesktopSite = !currentTab.isDesktopSite;
    notifyListeners();
    _saveState();
  }

  void updateZoomLevel(double delta) {
    final newZoom = (currentTab.zoomLevel + delta).clamp(0.5, 2.0);
    currentTab.zoomLevel = newZoom;
    notifyListeners();
  }

  void resetZoomLevel() {
    currentTab.zoomLevel = 1.0;
    notifyListeners();
  }

  void _addToHistory(String title, String url) {
    // Remove duplicates if same url visited recently
    _history.removeWhere((h) => h.url == url);
    _history.insert(
      0,
      HistoryItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        url: url,
        visitedAt: DateTime.now(),
      ),
    );
    if (_history.length > 100) {
      _history.removeLast();
    }
    _saveHistory();
  }

  void removeHistoryItem(String id) {
    _history.removeWhere((h) => h.id == id);
    notifyListeners();
    _saveHistory();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
    _saveHistory();
  }
}
