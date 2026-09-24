import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/bookmarks_provider.dart';
import '../../models/bookmark_item.dart';

class BookmarksScreen extends StatelessWidget {
  final Function(String url)? onNavigateUrl;

  const BookmarksScreen({super.key, this.onNavigateUrl});

  void _showAddEditBookmarkDialog(BuildContext context, BookmarksProvider provider, {BookmarkItem? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final urlController = TextEditingController(text: item?.url ?? '');
    String selectedFolder = item?.folder ?? 'General';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(item == null ? 'Add Bookmark' : 'Edit Bookmark'),
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
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedFolder,
              decoration: const InputDecoration(labelText: 'Folder'),
              items: provider.folders
                  .where((f) => f != 'All')
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) {
                if (val != null) selectedFolder = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                if (item == null) {
                  provider.addBookmark(
                    urlController.text.trim(),
                    titleController.text.trim(),
                    folder: selectedFolder,
                  );
                } else {
                  provider.editBookmark(
                    item.id,
                    titleController.text.trim(),
                    selectedFolder,
                  );
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider = Provider.of<BookmarksProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditBookmarkDialog(context, bookmarksProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search bookmarks...',
                prefixIcon: Icon(Icons.search_rounded),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => bookmarksProvider.setSearchQuery(val),
            ),
          ),

          // Folder selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: bookmarksProvider.folders.map((folder) {
                final isSelected = bookmarksProvider.selectedFolder == folder;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(folder),
                    selected: isSelected,
                    onSelected: (_) => bookmarksProvider.setSelectedFolder(folder),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Bookmarks List
          Expanded(
            child: bookmarksProvider.bookmarks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_outline_rounded, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No Bookmarks Found',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarksProvider.bookmarks.length,
                    itemBuilder: (context, index) {
                      final item = bookmarksProvider.bookmarks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(Icons.bookmark_rounded, color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${item.folder} • ${item.url}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            if (onNavigateUrl != null) {
                              onNavigateUrl!(item.url);
                            }
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'edit') {
                                _showAddEditBookmarkDialog(context, bookmarksProvider, item: item);
                              } else if (action == 'delete') {
                                bookmarksProvider.deleteBookmark(item.id);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
