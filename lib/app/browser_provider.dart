import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/tab_item.dart';
import '../models/app_settings.dart';

class BrowserProvider extends ChangeNotifier {
  final List<TabItem> _tabs = [];
  final List<TabItem> _closedTabs = [];
  int _activeTabIndex = 0;
  bool _isIncognito = false;

  // Controller map for active WebViews
  final Map<String, InAppWebViewController> _controllers = {};

  List<TabItem> get tabs =>
      _tabs.where((tab) => tab.isPrivate == _isIncognito).toList();
  List<TabItem> get allTabs => List.unmodifiable(_tabs);
  List<TabItem> get closedTabs => List.unmodifiable(_closedTabs);

  bool get isIncognito => _isIncognito;

  TabItem? get activeTab {
    final visibleTabs = tabs;
    if (visibleTabs.isEmpty) return null;
    if (_activeTabIndex >= visibleTabs.length) {
      _activeTabIndex = visibleTabs.length - 1;
    }
    return visibleTabs[_activeTabIndex];
  }

  int get activeTabIndex => _activeTabIndex;

  BrowserProvider() {
    // Initial home tab
    createTab(url: 'msai://home');
  }

  void registerController(String tabId, InAppWebViewController controller) {
    _controllers[tabId] = controller;
  }

  InAppWebViewController? getController(String tabId) {
    return _controllers[tabId];
  }

  void setIncognitoMode(bool enabled) {
    _isIncognito = enabled;
    final visibleTabs = tabs;
    if (visibleTabs.isEmpty) {
      createTab(url: 'msai://home', isPrivate: enabled);
    } else {
      _activeTabIndex = 0;
    }
    notifyListeners();
  }

  TabItem createTab({
    String url = 'msai://home',
    String title = 'New Tab',
    bool? isPrivate,
  }) {
    final privateFlag = isPrivate ?? _isIncognito;
    final tab = TabItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      url: url,
      title: title,
      isPrivate: privateFlag,
    );
    _tabs.add(tab);

    // Switch active index to the new tab
    final visibleTabs = _tabs.where((t) => t.isPrivate == privateFlag).toList();
    _activeTabIndex = visibleTabs.length - 1;

    notifyListeners();
    return tab;
  }

  void selectTab(String tabId) {
    final visibleTabs = tabs;
    final index = visibleTabs.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  void closeTab(String tabId) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      final removedTab = _tabs.removeAt(index);
      _controllers.remove(tabId);
      if (!removedTab.isPrivate && removedTab.url != 'msai://home') {
        _closedTabs.add(removedTab);
      }

      final visibleTabs = tabs;
      if (visibleTabs.isEmpty) {
        createTab(url: 'msai://home', isPrivate: _isIncognito);
      } else if (_activeTabIndex >= visibleTabs.length) {
        _activeTabIndex = visibleTabs.length - 1;
      }
      notifyListeners();
    }
  }

  void restoreLastClosedTab() {
    if (_closedTabs.isNotEmpty) {
      final tabToRestore = _closedTabs.removeLast();
      _tabs.add(tabToRestore);
      _activeTabIndex = tabs.length - 1;
      notifyListeners();
    }
  }

  void updateTabUrl(String tabId, String url, {String? title}) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      _tabs[index].url = url;
      if (title != null && title.isNotEmpty) {
        _tabs[index].title = title;
      }
      notifyListeners();
    }
  }

  void updateTabLoadingState(String tabId, {bool? isLoading, double? progress}) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      if (isLoading != null) _tabs[index].isLoading = isLoading;
      if (progress != null) _tabs[index].progress = progress;
      notifyListeners();
    }
  }

  void toggleDesktopMode(String tabId) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      _tabs[index].isDesktopMode = !_tabs[index].isDesktopMode;
      final controller = _controllers[tabId];
      if (controller != null) {
        controller.reload();
      }
      notifyListeners();
    }
  }

  String processSearchOrUrl(String input, SearchEngineOption searchEngine) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'msai://home';

    if (trimmed.startsWith('msai://')) return trimmed;

    // Check if valid URL or IP address
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$',
      caseSensitive: false,
    );
    final ipRegex = RegExp(
      r'^(https?:\/\/)?(\d{1,3}\.){3}\d{1,3}(:\d+)?(\/.*)?$',
    );

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    } else if (urlRegex.hasMatch(trimmed) || ipRegex.hasMatch(trimmed) || trimmed == 'localhost') {
      return 'https://$trimmed';
    } else {
      // Search engine query
      final encodedQuery = Uri.encodeComponent(trimmed);
      return '${searchEngine.searchUrl}$encodedQuery';
    }
  }

  void loadUrlInActiveTab(String urlOrQuery, SearchEngineOption searchEngine) {
    final currentTab = activeTab;
    if (currentTab == null) return;

    final targetUrl = processSearchOrUrl(urlOrQuery, searchEngine);
    currentTab.url = targetUrl;
    currentTab.isLoading = true;
    currentTab.progress = 0.1;

    final controller = _controllers[currentTab.id];
    if (controller != null && targetUrl != 'msai://home') {
      controller.loadUrl(urlRequest: URLRequest(url: WebUri(targetUrl)));
    }
    notifyListeners();
  }
}
