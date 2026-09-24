import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/download_item.dart';

class DownloadsProvider extends ChangeNotifier {
  List<DownloadItem> _downloads = [];

  List<DownloadItem> get downloads => List.unmodifiable(_downloads);

  DownloadsProvider() {
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('download_items') ?? [];
    if (raw.isEmpty) {
      // Demo download entries
      _downloads = [
        DownloadItem(
          id: 'demo1',
          filename: 'flutter_documentation.pdf',
          url: 'https://flutter.dev/docs/flutter_guide.pdf',
          filePath: '/storage/emulated/0/Download/flutter_documentation.pdf',
          progress: 1.0,
          status: DownloadStatus.completed,
          totalBytes: 5242880,
          downloadedBytes: 5242880,
        ),
      ];
      _saveDownloads();
    } else {
      _downloads = raw.map((str) {
        return DownloadItem.fromJson(jsonDecode(str) as Map<String, dynamic>);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> _saveDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _downloads.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('download_items', rawList);
  }

  void startDownload(String url, String filename) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = DownloadItem(
      id: id,
      filename: filename.isEmpty ? 'download_${id.substring(8)}' : filename,
      url: url,
      filePath: '/storage/emulated/0/Download/$filename',
      progress: 0.0,
      status: DownloadStatus.downloading,
      totalBytes: 10485760, // 10MB simulated size
      downloadedBytes: 0,
    );

    _downloads.insert(0, newItem);
    _saveDownloads();
    notifyListeners();

    // Simulate progress updates for web/platform downloads
    double currentProgress = 0.0;
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      currentProgress += 0.15;
      if (currentProgress >= 1.0) {
        newItem.progress = 1.0;
        newItem.downloadedBytes = newItem.totalBytes;
        newItem.status = DownloadStatus.completed;
        timer.cancel();
        _saveDownloads();
        notifyListeners();
      } else {
        newItem.progress = currentProgress;
        newItem.downloadedBytes = (newItem.totalBytes * currentProgress).toInt();
        _saveDownloads();
        notifyListeners();
      }
    });
  }

  void deleteDownload(String id) {
    _downloads.removeWhere((item) => item.id == id);
    _saveDownloads();
    notifyListeners();
  }

  void clearAllDownloads() {
    _downloads.clear();
    _saveDownloads();
    notifyListeners();
  }
}
