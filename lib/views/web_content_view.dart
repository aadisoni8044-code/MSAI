import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/tab_model.dart';
import '../providers/browser_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/downloads_provider.dart';
import '../theme/app_theme.dart';
import 'firezip_start_page.dart';

class WebContentView extends StatefulWidget {
  final TabModel tab;

  const WebContentView({super.key, required this.tab});

  @override
  State<WebContentView> createState() => _WebContentViewState();
}

class _WebContentViewState extends State<WebContentView> {
  WebViewController? _webViewController;
  bool _useWebView = false;
  bool _isLoading = false;
  double _loadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initWebViewIfSupported();
  }

  void _initWebViewIfSupported() {
    if (widget.tab.isHomePage) return;

    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                  _loadProgress = 0.2;
                });
              },
              onProgress: (int progress) {
                setState(() {
                  _loadProgress = progress / 100;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                  _loadProgress = 1.0;
                });
              },
            ),
          );

        final Uri? parsedUri = Uri.tryParse(widget.tab.url);
        if (parsedUri != null) {
          controller.loadRequest(parsedUri);
          _webViewController = controller;
          _useWebView = true;
        }
      }
    } catch (_) {
      _useWebView = false;
    }
  }

  @override
  void didUpdateWidget(covariant WebContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab.url != widget.tab.url) {
      if (!widget.tab.isHomePage && _useWebView && _webViewController != null) {
        final Uri? parsedUri = Uri.tryParse(widget.tab.url);
        if (parsedUri != null) {
          _webViewController!.loadRequest(parsedUri);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tab.isHomePage) {
      return FirezipStartPage(
        onNavigate: (url) {
          final settings = context.read<SettingsProvider>();
          context.read<BrowserProvider>().navigateCurrentTab(url, settings.searchEngine);
        },
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarks = context.watch<BookmarksProvider>();
    final isBookmarked = bookmarks.isBookmarked(widget.tab.url);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Column(
        children: [
          // Loading Progress Indicator Bar
          if (_isLoading || widget.tab.isLoading)
            LinearProgressIndicator(
              value: _loadProgress > 0 ? _loadProgress : null,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryLightBlue),
              minHeight: 3,
            ),

          // Site Info Sub-header Bar
          _buildWebHeaderBar(theme, isBookmarked, isDark),

          // Main Web Page Viewport
          Expanded(
            child: _useWebView && _webViewController != null
                ? WebViewWidget(controller: _webViewController!)
                : _buildFirezipEngineViewport(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeaderBar(ThemeData theme, bool isBookmarked, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          // Security Lock / SSL Indicator
          Icon(
            widget.tab.url.startsWith('https://')
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
            size: 16,
            color: widget.tab.url.startsWith('https://')
                ? Colors.green
                : Colors.amber,
          ),
          const SizedBox(width: 8),

          // Host / URL display
          Expanded(
            child: Text(
              widget.tab.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),

          // Zoom Level Indicator
          if (widget.tab.zoomLevel != 1.0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(widget.tab.zoomLevel * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryLightBlue,
                ),
              ),
            ),

          // Desktop Site Badge
          if (widget.tab.isDesktopSite)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DESKTOP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                ),
              ),
            ),

          // Bookmark Toggle Icon Button
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 20,
              color: isBookmarked ? AppTheme.primaryLightBlue : null,
            ),
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
            onPressed: () {
              final bookmarksProvider = context.read<BookmarksProvider>();
              if (isBookmarked) {
                bookmarksProvider.removeBookmark(widget.tab.url);
              } else {
                bookmarksProvider.addBookmark(widget.tab.title, widget.tab.url);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFirezipEngineViewport(ThemeData theme, bool isDark) {
    final settings = context.watch<SettingsProvider>();
    final isSearchQuery = widget.tab.url.contains('search') ||
        widget.tab.url.contains('?q=') ||
        widget.tab.url.contains('&q=');

    return Transform.scale(
      scale: widget.tab.zoomLevel,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.tab.isDesktopSite ? 1200 : 800,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isSearchQuery
                ? _buildSearchResultsEngine(theme, settings, isDark)
                : _buildWebPageSimEngine(theme, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsEngine(
      ThemeData theme, SettingsProvider settings, bool isDark) {
    final uri = Uri.parse(widget.tab.url);
    final query = uri.queryParameters['q'] ??
        uri.queryParameters['p'] ??
        'Firezip Search';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Header
        Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.primaryLightBlue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Results for: "$query"',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Chip(
              avatar: const Icon(Icons.travel_explore_rounded, size: 14),
              label: Text(settings.searchEngine.name),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'About 1,240,000 results (0.24 seconds) • Firezip Accelerated Engine',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Divider(height: 32),

        // Simulated Search Results Items
        _buildSearchResultCard(
          theme: theme,
          title: '$query - Official Site & Information',
          url: 'https://www.${query.replaceAll(' ', '').toLowerCase()}.org',
          snippet:
              'Official website for $query. Discover guides, documentations, recent updates, download links, and developer resources.',
        ),
        const SizedBox(height: 16),
        _buildSearchResultCard(
          theme: theme,
          title: '$query - Wikipedia',
          url: 'https://en.wikipedia.org/wiki/${query.replaceAll(' ', '_')}',
          snippet:
              '$query is an important subject in software engineering and web standards. Read full history, key milestones, and technical overviews.',
        ),
        const SizedBox(height: 16),
        _buildSearchResultCard(
          theme: theme,
          title: 'Top news and articles about $query',
          url: 'https://news.ycombinator.com/item?q=$query',
          snippet:
              'Latest headlines, community discussions, release notes, and technical blogs covering $query.',
        ),
        const SizedBox(height: 16),
        _buildSearchResultCard(
          theme: theme,
          title: 'GitHub Repositories for $query',
          url: 'https://github.com/search?q=$query',
          snippet:
              'Explore thousands of open source repositories, libraries, and sample projects relating to $query.',
        ),
      ],
    );
  }

  Widget _buildSearchResultCard({
    required ThemeData theme,
    required String title,
    required String url,
    required String snippet,
  }) {
    return InkWell(
      onTap: () {
        context.read<BrowserProvider>().navigateCurrentTab(
              url,
              context.read<SettingsProvider>().searchEngine,
            );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              url,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryLightBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              snippet,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPageSimEngine(ThemeData theme, bool isDark) {
    final host = Uri.tryParse(widget.tab.url)?.host ?? widget.tab.url;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Web Page Header Banner
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  host.isNotEmpty ? host[0].toUpperCase() : 'W',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryLightBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tab.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.tab.url,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DownloadsProvider>().startDownload(
                      '${host}_page_export.pdf',
                      widget.tab.url,
                      '4.8 MB',
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started: Page Export PDF')),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Save Page'),
            ),
          ],
        ),
        const Divider(height: 36),

        // Web Article Content Body
        Text(
          'Welcome to $host',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Firezip High-Speed Rendering Engine has successfully connected to $host over TLS 1.3 encrypted protocol.',
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),

        // Interactive Web Elements
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBg : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.terminal_rounded, size: 18, color: AppTheme.accentCyan),
                  SizedBox(width: 8),
                  Text(
                    'Interactive Page Inspector & Web Features',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reload Page'),
                    onPressed: () {
                      context.read<BrowserProvider>().navigateCurrentTab(
                            widget.tab.url,
                            context.read<SettingsProvider>().searchEngine,
                          );
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.devices_rounded, size: 16),
                    label: Text(widget.tab.isDesktopSite ? 'Mobile View' : 'Desktop View'),
                    onPressed: () {
                      context.read<BrowserProvider>().toggleDesktopSite();
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.zoom_in_rounded, size: 16),
                    label: const Text('Zoom In'),
                    onPressed: () {
                      context.read<BrowserProvider>().updateZoomLevel(0.1);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.zoom_out_rounded, size: 16),
                    label: const Text('Zoom Out'),
                    onPressed: () {
                      context.read<BrowserProvider>().updateZoomLevel(-0.1);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Featured Highlights & Navigation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSubPageLink('Documentation & Getting Started', 'https://$host/docs'),
        _buildSubPageLink('API Reference & Integrations', 'https://$host/api'),
        _buildSubPageLink('About $host & Team', 'https://$host/about'),
        _buildSubPageLink('Privacy Policy & Terms', 'https://$host/privacy'),
      ],
    );
  }

  Widget _buildSubPageLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          context.read<BrowserProvider>().navigateCurrentTab(
                url,
                context.read<SettingsProvider>().searchEngine,
              );
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            const Icon(Icons.link_rounded, size: 18, color: AppTheme.primaryLightBlue),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLightBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
