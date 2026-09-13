import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/browser_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarksProvider = context.watch<BookmarksProvider>();

    final filteredBookmarks = bookmarksProvider.bookmarks.where((b) {
      if (_filterQuery.isEmpty) return true;
      final q = _filterQuery.toLowerCase();
      return b.title.toLowerCase().contains(q) || b.url.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bookmark_rounded, color: AppTheme.primaryLightBlue),
            SizedBox(width: 10),
            Text('Bookmarks'),
          ],
        ),
        actions: [
          if (bookmarksProvider.bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear All Bookmarks',
              onPressed: () => _confirmClearAll(context),
            ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Bookmark',
            onPressed: () => _showAddBookmarkDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Filter Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filterQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filterQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Bookmarks List View
          Expanded(
            child: filteredBookmarks.isEmpty
                ? _buildEmptyState(theme, isDark)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredBookmarks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredBookmarks[index];
                      final initial = item.title.isNotEmpty
                          ? item.title[0].toUpperCase()
                          : 'B';

                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLightBlue,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                                tooltip: 'Open Bookmark',
                                onPressed: () {
                                  context.read<BrowserProvider>().navigateCurrentTab(
                                        item.url,
                                        context.read<SettingsProvider>().searchEngine,
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20, color: Colors.redAccent),
                                tooltip: 'Remove Bookmark',
                                onPressed: () {
                                  bookmarksProvider.removeBookmarkById(item.id);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            context.read<BrowserProvider>().navigateCurrentTab(
                                  item.url,
                                  context.read<SettingsProvider>().searchEngine,
                                );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _filterQuery.isNotEmpty ? 'No matching bookmarks' : 'No saved bookmarks',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Save your favorite websites to quickly access them anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBookmarkDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Page Title'),
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
                context.read<BookmarksProvider>().addBookmark(
                      titleController.text.trim(),
                      urlController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Bookmark'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks?'),
        content: const Text('Are you sure you want to remove all saved bookmarks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<BookmarksProvider>().clearBookmarks();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
