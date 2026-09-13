import 'package:flutter/foundation.dart';

class TabModel {
  final String id;
  String url;
  String title;
  String? faviconUrl;
  List<String> historyStack;
  int historyIndex;
  bool isLoading;
  bool isDesktopSite;
  double zoomLevel;

  TabModel({
    required this.id,
    this.url = 'firezip://home',
    this.title = 'New Tab',
    this.faviconUrl,
    List<String>? historyStack,
    this.historyIndex = 0,
    this.isLoading = false,
    this.isDesktopSite = false,
    this.zoomLevel = 1.0,
  }) : historyStack = historyStack ?? [url];

  bool get canGoBack => historyIndex > 0;
  bool get canGoForward => historyIndex < historyStack.length - 1;
  bool get isHomePage => url == 'firezip://home';

  void navigateTo(String newUrl, {String? newTitle}) {
    if (url == newUrl) return;

    // Truncate forward history if navigating to new page
    if (historyIndex < historyStack.length - 1) {
      historyStack = historyStack.sublist(0, historyIndex + 1);
    }

    historyStack.add(newUrl);
    historyIndex = historyStack.length - 1;
    url = newUrl;
    if (newTitle != null) {
      title = newTitle;
    } else if (newUrl == 'firezip://home') {
      title = 'Firezip Home';
    } else {
      title = _formatTitleFromUrl(newUrl);
    }
  }

  void goBack() {
    if (canGoBack) {
      historyIndex--;
      url = historyStack[historyIndex];
      if (url == 'firezip://home') {
        title = 'Firezip Home';
      } else {
        title = _formatTitleFromUrl(url);
      }
    }
  }

  void goForward() {
    if (canGoForward) {
      historyIndex++;
      url = historyStack[historyIndex];
      if (url == 'firezip://home') {
        title = 'Firezip Home';
      } else {
        title = _formatTitleFromUrl(url);
      }
    }
  }

  static String _formatTitleFromUrl(String rawUrl) {
    try {
      final uri = Uri.parse(rawUrl);
      if (uri.host.isNotEmpty) {
        final host = uri.host.replaceFirst('www.', '');
        return host[0].toUpperCase() + host.substring(1);
      }
    } catch (_) {}
    return rawUrl;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'faviconUrl': faviconUrl,
        'historyStack': historyStack,
        'historyIndex': historyIndex,
        'isDesktopSite': isDesktopSite,
        'zoomLevel': zoomLevel,
      };

  factory TabModel.fromJson(Map<String, dynamic> json) {
    final stackList = (json['historyStack'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [json['url'] ?? 'firezip://home'];
    return TabModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      url: json['url'] ?? 'firezip://home',
      title: json['title'] ?? 'New Tab',
      faviconUrl: json['faviconUrl'],
      historyStack: stackList,
      historyIndex: json['historyIndex'] ?? 0,
      isDesktopSite: json['isDesktopSite'] ?? false,
      zoomLevel: (json['zoomLevel'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
