enum SearchEngineOption {
  google(name: 'Google', searchUrl: 'https://www.google.com/search?q='),
  duckDuckGo(name: 'DuckDuckGo', searchUrl: 'https://duckduckgo.com/?q='),
  bing(name: 'Bing', searchUrl: 'https://www.bing.com/search?q='),
  ecosia(name: 'Ecosia', searchUrl: 'https://www.ecosia.org/search?q='),
  brave(name: 'Brave', searchUrl: 'https://search.brave.com/search?q=');

  final String name;
  final String searchUrl;
  const SearchEngineOption({required this.name, required this.searchUrl});
}

class AppSettings {
  String themeMode; // 'system', 'light', 'dark'
  SearchEngineOption searchEngine;
  bool trackingProtection;
  bool blockCookies;
  bool httpsOnly;
  bool cameraPermissionAllowed;
  bool micPermissionAllowed;
  bool locationPermissionAllowed;
  bool notificationPermissionAllowed;
  String aiApiKey;
  String aiModel;
  String homepageUrl;

  AppSettings({
    this.themeMode = 'system',
    this.searchEngine = SearchEngineOption.google,
    this.trackingProtection = true,
    this.blockCookies = false,
    this.httpsOnly = true,
    this.cameraPermissionAllowed = true,
    this.micPermissionAllowed = true,
    this.locationPermissionAllowed = false,
    this.notificationPermissionAllowed = true,
    this.aiApiKey = '',
    this.aiModel = 'gemini-1.5-flash',
    this.homepageUrl = 'msai://home',
  });
}
