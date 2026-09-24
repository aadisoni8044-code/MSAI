import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_item.dart';

class BookmarksProvider extends ChangeNotifier {
  List<BookmarkItem> _bookmarks = [];
  String _selectedFolder = 'All';
  String _searchQuery = '';

  List<BookmarkItem> get bookmarks {
    return _bookmarks.where((item) {
      final matchesFolder =
          _selectedFolder == 'All' || item.folder == _selectedFolder;
      final matchesQuery = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.url.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFolder && matchesQuery;
    }).toList();
  }

  List<String> get folders {
    final set = <String>{'All', 'General', 'Work', 'Personal', 'Favorites'};
    for (var b in _bookmarks) {
      set.add(b.folder);
    }
    return set.toList();
  }

  String get selectedFolder => _selectedFolder;
  String get searchQuery => _searchQuery;

  BookmarksProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookmark_items') ?? [];
    if (raw.isEmpty) {
      // Default initial bookmarks
      _bookmarks = [
        BookmarkItem(
            id: '1',
            url: 'https://flutter.dev',
            title: 'Flutter - Build apps for any screen',
            folder: 'Favorites'),
        BookmarkItem(
            id: '2',
            url: 'https://dart.dev',
            title: 'Dart programming language',
            folder: 'Favorites'),
        BookmarkItem(
            id: '3',
            url: 'https://news.ycombinator.com',
            title: 'Hacker News',
            folder: 'General'),
        BookmarkItem(
            id: '4',
            url: 'https://wikipedia.org',
            title: 'Wikipedia',
            folder: 'General'),
      ];
      _saveBookmarks();
    } else {
      _bookmarks = raw.map((itemStr) {
        return BookmarkItem.fromJson(
            jsonDecode(itemStr) as Map<String, dynamic>);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _bookmarks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('bookmark_items', rawList);
  }

  bool isBookmarked(String url) {
    return _bookmarks.any((item) => item.url == url);
  }

  void toggleBookmark(String url, String title, {String folder = 'General'}) {
    if (isBookmarked(url)) {
      _bookmarks.removeWhere((item) => item.url == url);
    } else {
      _bookmarks.insert(
        0,
        BookmarkItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          title: title.isEmpty ? url : title,
          folder: folder,
        ),
      );
    }
    _saveBookmarks();
    notifyListeners();
  }

  void addBookmark(String url, String title, {String folder = 'General'}) {
    if (!isBookmarked(url)) {
      _bookmarks.insert(
        0,
        BookmarkItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          title: title.isEmpty ? url : title,
          folder: folder,
        ),
      );
      _saveBookmarks();
      notifyListeners();
    }
  }

  void editBookmark(String id, String newTitle, String newFolder) {
    final index = _bookmarks.indexWhere((item) => item.id == id);
    if (index != -1) {
      final old = _bookmarks[index];
      _bookmarks[index] = BookmarkItem(
        id: old.id,
        url: old.url,
        title: newTitle,
        folder: newFolder,
        createdAt: old.createdAt,
      );
      _saveBookmarks();
      notifyListeners();
    }
  }

  void deleteBookmark(String id) {
    _bookmarks.removeWhere((item) => item.id == id);
    _saveBookmarks();
    notifyListeners();
  }

  void setSelectedFolder(String folder) {
    _selectedFolder = folder;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
