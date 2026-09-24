import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/browser_provider.dart';
import '../../app/bookmarks_provider.dart';
import '../../app/history_provider.dart';
import '../../app/downloads_provider.dart';
import '../../app/settings_provider.dart';
import '../../models/tab_item.dart';
import '../../widgets/error_view.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _urlBarController = TextEditingController();
  bool _showFindInPage = false;
  final TextEditingController _findController = TextEditingController();
  InAppWebViewController? _webViewController;
  CustomErrorType? _currentError;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void dispose() {
    _urlBarController.dispose();
    _findController.dispose();
    super.dispose();
  }

  void _syncUrlBar(String url) {
    if (_urlBarController.text != url) {
      _urlBarController.text = url;
    }
  }

  void _showPageInfoDialog(TabItem activeTab) {
    final isHttps = activeTab.url.startsWith('https://');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              isHttps ? Icons.lock_rounded : Icons.info_outline_rounded,
              color: isHttps ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('Page Security'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHttps ? 'Connection is Secure' : 'Connection is Not Encrypted',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHttps ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText('URL: ${activeTab.url}'),
            const SizedBox(height: 12),
            const Text(
              'Your passwords, cookies, and browsing state are protected by local encryption and active privacy shield.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final browserProvider = Provider.of<BrowserProvider>(context);
    final bookmarksProvider = Provider.of<BookmarksProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    final downloadsProvider = Provider.of<DownloadsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final activeTab = browserProvider.activeTab;
    if (activeTab == null || activeTab.url == 'msai://home') {
      return const SizedBox.shrink();
    }

    _syncUrlBar(activeTab.url);
    final isBookmarked = bookmarksProvider.isBookmarked(activeTab.url);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Top Navigation Bar / Address Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: activeTab.isPrivate
                ? const Color(0xFF1E293B)
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  browserProvider.updateTabUrl(activeTab.id, 'msai://home');
                },
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: activeTab.isPrivate
                        ? const Color(0xFF334155)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _showPageInfoDialog(activeTab),
                        child: Icon(
                          activeTab.url.startsWith('https://')
                              ? Icons.lock_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: activeTab.url.startsWith('https://')
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _urlBarController,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            browserProvider.loadUrlInActiveTab(
                                value, settingsProvider.settings.searchEngine);
                          },
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ),
                      if (activeTab.isLoading)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() => _currentError = null);
                            _webViewController?.reload();
                          },
                        ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  bookmarksProvider.toggleBookmark(activeTab.url, activeTab.title);
                },
              ),
            ],
          ),
        ),

        // Progress indicator
        if (activeTab.isLoading)
          LinearProgressIndicator(
            value: activeTab.progress > 0 ? activeTab.progress : null,
            minHeight: 2.5,
            backgroundColor: Colors.transparent,
            color: theme.colorScheme.primary,
          ),

        // Find in Page search bar overlay
        if (_showFindInPage)
          Container(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _findController,
                    decoration: const InputDecoration(
                      hintText: 'Find in page...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (text) {
                      _webViewController?.findAllAsync(find: text);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  onPressed: () {
                    _webViewController?.findNext(forward: false);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  onPressed: () {
                    _webViewController?.findNext(forward: true);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _webViewController?.clearMatches();
                    setState(() => _showFindInPage = false);
                  },
                ),
              ],
            ),
          ),

        // Web Content Stack or Custom Error View
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(activeTab.url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  userAgent: activeTab.isDesktopMode
                      ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
                      : null,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  browserProvider.registerController(activeTab.id, controller);
                },
                onLoadStart: (controller, url) {
                  setState(() => _currentError = null);
                  browserProvider.updateTabLoadingState(activeTab.id, isLoading: true, progress: 0.2);
                  if (url != null) {
                    browserProvider.updateTabUrl(activeTab.id, url.toString());
                  }
                },
                onLoadStop: (controller, url) async {
                  browserProvider.updateTabLoadingState(activeTab.id, isLoading: false, progress: 1.0);
                  if (url != null) {
                    final title = await controller.getTitle();
                    browserProvider.updateTabUrl(activeTab.id, url.toString(), title: title);
                    if (!activeTab.isPrivate) {
                      historyProvider.addHistory(url.toString(), title ?? url.toString());
                    }
                  }
                  final canBack = await controller.canGoBack();
                  final canForward = await controller.canGoForward();
                  setState(() {
                    _canGoBack = canBack;
                    _canGoForward = canForward;
                  });
                },
                onProgressChanged: (controller, progress) {
                  browserProvider.updateTabLoadingState(activeTab.id, progress: progress / 100.0);
                },
                onReceivedError: (controller, request, error) {
                  setState(() {
                    _currentError = CustomErrorType.pageLoadError;
                  });
                },
                onDownloadStartRequest: (controller, downloadStartRequest) {
                  final filename = downloadStartRequest.suggestedFilename ?? 'download';
                  downloadsProvider.startDownload(downloadStartRequest.url.toString(), filename);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading $filename...')),
                  );
                },
              ),

              if (_currentError != null)
                Container(
                  color: theme.scaffoldBackgroundColor,
                  child: CustomErrorView(
                    errorType: _currentError!,
                    onRetry: () {
                      setState(() => _currentError = null);
                      _webViewController?.reload();
                    },
                    onGoHome: () {
                      browserProvider.updateTabUrl(activeTab.id, 'msai://home');
                    },
                  ),
                ),
            ],
          ),
        ),

        // Bottom Browser Quick Toolbar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: activeTab.isPrivate
                ? const Color(0xFF1E293B)
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: _canGoBack ? () => _webViewController?.goBack() : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onPressed: _canGoForward ? () => _webViewController?.goForward() : null,
              ),
              IconButton(
                icon: Icon(
                  Icons.desktop_windows_rounded,
                  size: 20,
                  color: activeTab.isDesktopMode ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  browserProvider.toggleDesktopMode(activeTab.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 20),
                onPressed: () {
                  setState(() => _showFindInPage = !_showFindInPage);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 20),
                onPressed: () {
                  Share.share(activeTab.url, subject: activeTab.title);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
