import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/bookmarks_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/app_theme.dart';

class FirezipStartPage extends StatefulWidget {
  final Function(String url)? onNavigate;

  const FirezipStartPage({super.key, this.onNavigate});

  @override
  State<FirezipStartPage> createState() => _FirezipStartPageState();
}

class _FirezipStartPageState extends State<FirezipStartPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];

  final List<Map<String, String>> _quickShortcuts = [
    {
      'title': 'Google',
      'url': 'https://www.google.com',
      'icon': 'G',
      'color': '0xFF4285F4',
    },
    {
      'title': 'YouTube',
      'url': 'https://www.youtube.com',
      'icon': 'YT',
      'color': '0xFFFF0000',
    },
    {
      'title': 'GitHub',
      'url': 'https://github.com',
      'icon': 'GH',
      'color': '0xFF24292E',
    },
    {
      'title': 'Wikipedia',
      'url': 'https://www.wikipedia.org',
      'icon': 'W',
      'color': '0xFF636466',
    },
    {
      'title': 'Reddit',
      'url': 'https://www.reddit.com',
      'icon': 'R',
      'color': '0xFFFF4500',
    },
    {
      'title': 'Twitter/X',
      'url': 'https://x.com',
      'icon': 'X',
      'color': '0xFF000000',
    },
    {
      'title': 'StackOverflow',
      'url': 'https://stackoverflow.com',
      'icon': 'SO',
      'color': '0xFFF48024',
    },
    {
      'title': 'Flutter',
      'url': 'https://flutter.dev',
      'icon': 'FL',
      'color': '0xFF02569B',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    final settings = context.read<SettingsProvider>();
    final browser = context.read<BrowserProvider>();
    final url = BrowserProvider.parseInputToUrl(query, settings.searchEngine);
    if (widget.onNavigate != null) {
      widget.onNavigate!(url);
    } else {
      browser.navigateCurrentTab(query, settings.searchEngine);
    }
  }

  void _updateSuggestions(String text) {
    if (text.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final query = text.toLowerCase();
    final history = context.read<BrowserProvider>().history;
    final bookmarks = context.read<BookmarksProvider>().bookmarks;

    final Set<String> results = {};
    for (final h in history) {
      if (h.title.toLowerCase().contains(query) || h.url.toLowerCase().contains(query)) {
        results.add(h.title);
      }
    }
    for (final b in bookmarks) {
      if (b.title.toLowerCase().contains(query) || b.url.toLowerCase().contains(query)) {
        results.add(b.title);
      }
    }

    if (!results.contains(text)) {
      results.add('$text search');
      results.add('$text news');
      results.add('$text website');
    }

    setState(() {
      _suggestions = results.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final browser = context.watch<BrowserProvider>();
    final settings = context.watch<SettingsProvider>();
    final horizontalPadding = ResponsiveLayout.getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Firezip Hero Branding
              _buildBranding(isDark),

              const SizedBox(height: 32),

              // Search Bar & Engine Selector
              _buildSearchBar(theme, settings, isDark),

              // Suggestions Dropdown
              if (_suggestions.isNotEmpty && _focusNode.hasFocus)
                _buildSuggestionsCard(theme),

              const SizedBox(height: 40),

              // Quick Shortcuts Grid
              _buildShortcutsSection(theme, isDark),

              const SizedBox(height: 40),

              // Recently Visited Section
              if (browser.history.isNotEmpty)
                _buildRecentSection(theme, browser, isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppTheme.fireOrange,
                AppTheme.primaryBlue,
                AppTheme.accentCyan,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              AppTheme.primaryLightBlue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'FIREZIP',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: isDark ? Colors.white : AppTheme.darkBg,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fast, Private & Next-Gen Web Browser',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
      ThemeData theme, SettingsProvider settings, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppTheme.primaryLightBlue
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            // Engine Selector Button
            PopupMenuButton<SearchEngine>(
              initialValue: settings.searchEngine,
              tooltip: 'Select Search Engine',
              onSelected: (engine) => settings.setSearchEngine(engine),
              itemBuilder: (context) => SearchEngine.values
                  .map(
                    (e) => PopupMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Icon(
                            _getEngineIcon(e),
                            size: 18,
                            color: AppTheme.primaryLightBlue,
                          ),
                          const SizedBox(width: 10),
                          Text(e.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getEngineIcon(settings.searchEngine),
                      size: 16,
                      color: AppTheme.primaryLightBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      settings.searchEngine.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text Input Field
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.go,
                onChanged: _updateSuggestions,
                onSubmitted: _onSearchSubmitted,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search or enter web address...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _updateSuggestions('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Go Search Button
            IconButton(
              onPressed: () => _onSearchSubmitted(_searchController.text),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEngineIcon(SearchEngine engine) {
    switch (engine) {
      case SearchEngine.google:
        return Icons.search_rounded;
      case SearchEngine.duckDuckGo:
        return Icons.security_rounded;
      case SearchEngine.bing:
        return Icons.travel_explore_rounded;
      case SearchEngine.brave:
        return Icons.shield_rounded;
      case SearchEngine.yahoo:
        return Icons.public_rounded;
      case SearchEngine.ecosia:
        return Icons.eco_rounded;
    }
  }

  Widget _buildSuggestionsCard(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppTheme.darkBorder
              : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        children: _suggestions.map((item) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.search_rounded, size: 18),
            title: Text(item),
            onTap: () {
              _searchController.text = item;
              _onSearchSubmitted(item);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShortcutsSection(ThemeData theme, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top Shortcuts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                tooltip: 'Add Shortcut',
                onPressed: _showAddShortcutDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _quickShortcuts.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              mainAxisExtent: 90,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final shortcut = _quickShortcuts[index];
              final rawColor = shortcut['color']!.replaceFirst('0x', '');
              final colorHex = int.parse(rawColor, radix: 16);
              final bg = Color(colorHex);

              return InkWell(
                onTap: () {
                  final url = shortcut['url']!;
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(url);
                  } else {
                    context.read<BrowserProvider>().navigateCurrentTab(
                          url,
                          context.read<SettingsProvider>().searchEngine,
                        );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          shortcut['icon']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shortcut['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddShortcutDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL (e.g. https://...)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() {
                  _quickShortcuts.add({
                    'title': titleController.text.trim().isEmpty
                        ? urlController.text.trim()
                        : titleController.text.trim(),
                    'url': urlController.text.trim(),
                    'icon': titleController.text.trim().isNotEmpty
                        ? titleController.text.trim()[0].toUpperCase()
                        : 'S',
                    'color': '0xFF2563EB',
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(
      ThemeData theme, BrowserProvider browser, bool isDark) {
    final recentItems = browser.history.take(4).toList();

    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recently Visited',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppTheme.primaryLightBlue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    item.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_outward_rounded, size: 18),
                  onTap: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(item.url);
                    } else {
                      browser.navigateCurrentTab(
                        item.url,
                        context.read<SettingsProvider>().searchEngine,
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
