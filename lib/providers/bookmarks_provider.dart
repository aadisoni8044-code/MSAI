import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

class BookmarksProvider with ChangeNotifier {
  static const String _storageKey = 'firezip_bookmarks';
  final List<BookmarkModel> _bookmarks = [];

  List<BookmarkModel> get bookmarks => List.unmodifiable(_bookmarks);

  BookmarksProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _bookmarks.clear();
        _bookmarks.addAll(list.map((item) => BookmarkModel.fromJson(item)));
      } else {
        _populateDefaultBookmarks();
      }
    } catch (_) {
      _populateDefaultBookmarks();
    }
    notifyListeners();
  }

  void _populateDefaultBookmarks() {
    _bookmarks.clear();
    _bookmarks.addAll([
      BookmarkModel(
        id: '1',
        title: 'Google Search',
        url: 'https://www.google.com',
      ),
      BookmarkModel(
        id: '2',
        title: 'GitHub',
        url: 'https://github.com',
      ),
      BookmarkModel(
        id: '3',
        title: 'Wikipedia',
        url: 'https://www.wikipedia.org',
      ),
      BookmarkModel(
        id: '4',
        title: 'Flutter Dev',
        url: 'https://flutter.dev',
      ),
      BookmarkModel(
        id: '5',
        title: 'Reddit',
        url: 'https://www.reddit.com',
      ),
    ]);
    _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_bookmarks.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  bool isBookmarked(String url) {
    if (url == 'firezip://home' || url.isEmpty) return false;
    return _bookmarks.any((b) => b.url.toLowerCase() == url.toLowerCase());
  }

  Future<void> addBookmark(String title, String url, {String? faviconUrl}) async {
    if (url == 'firezip://home' || url.isEmpty) return;
    if (isBookmarked(url)) return;

    final bookmark = BookmarkModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? url : title,
      url: url,
      faviconUrl: faviconUrl,
    );

    _bookmarks.insert(0, bookmark);
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> removeBookmark(String url) async {
    _bookmarks.removeWhere((b) => b.url.toLowerCase() == url.toLowerCase());
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> removeBookmarkById(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> clearBookmarks() async {
    _bookmarks.clear();
    notifyListeners();
    await _saveBookmarks();
  }
}
