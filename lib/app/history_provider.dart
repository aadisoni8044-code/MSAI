import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _history = [];
  String _searchQuery = '';

  List<HistoryItem> get history {
    if (_searchQuery.isEmpty) return List.unmodifiable(_history);
    return _history
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.url.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String get searchQuery => _searchQuery;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('history_items') ?? [];
    _history = raw.map((itemStr) {
      return HistoryItem.fromJson(jsonDecode(itemStr) as Map<String, dynamic>);
    }).toList();
    // Sort descending by timestamp
    _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('history_items', rawList);
  }

  void addHistory(String url, String title) {
    if (url.isEmpty || url == 'msai://home' || url == 'about:blank') return;

    // Remove exact match duplicate if present recently to keep clean list
    _history.removeWhere((item) => item.url == url);

    final newItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: title.isEmpty ? url : title,
      timestamp: DateTime.now(),
    );

    _history.insert(0, newItem);
    _saveHistory();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void deleteHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    _saveHistory();
    notifyListeners();
  }

  void clearAllHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }
}
