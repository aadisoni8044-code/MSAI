import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/download_model.dart';

class DownloadsProvider with ChangeNotifier {
  static const String _storageKey = 'firezip_downloads';
  final List<DownloadModel> _downloads = [];
  final Map<String, Timer> _activeSimulations = {};

  List<DownloadModel> get downloads => List.unmodifiable(_downloads);

  DownloadsProvider() {
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _downloads.clear();
        _downloads.addAll(list.map((item) => DownloadModel.fromJson(item)));
      } else {
        _populateDefaultDownloads();
      }
    } catch (_) {
      _populateDefaultDownloads();
    }
    notifyListeners();
  }

  void _populateDefaultDownloads() {
    _downloads.clear();
    _downloads.addAll([
      DownloadModel(
        id: 'dl_1',
        fileName: 'Firezip_Setup_v1.0.exe',
        url: 'https://firezip.com/releases/v1.0.exe',
        fileSize: '42.5 MB',
        progress: 1.0,
        state: DownloadState.completed,
      ),
      DownloadModel(
        id: 'dl_2',
        fileName: 'Sample_Document.pdf',
        url: 'https://example.com/docs/sample.pdf',
        fileSize: '3.2 MB',
        progress: 1.0,
        state: DownloadState.completed,
      ),
    ]);
    _saveDownloads();
  }

  Future<void> _saveDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_downloads.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  void startDownload(String fileName, String url, String fileSize) {
    final id = 'dl_${DateTime.now().millisecondsSinceEpoch}';
    final download = DownloadModel(
      id: id,
      fileName: fileName,
      url: url,
      fileSize: fileSize,
      progress: 0.0,
      state: DownloadState.downloading,
    );

    _downloads.insert(0, download);
    notifyListeners();
    _saveDownloads();

    // Start simulation timer
    _simulateDownloadProgress(id);
  }

  void _simulateDownloadProgress(String id) {
    _activeSimulations[id]?.cancel();
    _activeSimulations[id] = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      final index = _downloads.indexWhere((d) => d.id == id);
      if (index == -1) {
        timer.cancel();
        _activeSimulations.remove(id);
        return;
      }

      final download = _downloads[index];
      if (download.state != DownloadState.downloading) {
        timer.cancel();
        _activeSimulations.remove(id);
        return;
      }

      download.progress += 0.1;
      if (download.progress >= 1.0) {
        download.progress = 1.0;
        download.state = DownloadState.completed;
        timer.cancel();
        _activeSimulations.remove(id);
      }

      notifyListeners();
      _saveDownloads();
    });
  }

  void pauseDownload(String id) {
    final index = _downloads.indexWhere((d) => d.id == id);
    if (index != -1) {
      _downloads[index].state = DownloadState.paused;
      _activeSimulations[id]?.cancel();
      _activeSimulations.remove(id);
      notifyListeners();
      _saveDownloads();
    }
  }

  void resumeDownload(String id) {
    final index = _downloads.indexWhere((d) => d.id == id);
    if (index != -1 && _downloads[index].state == DownloadState.paused) {
      _downloads[index].state = DownloadState.downloading;
      notifyListeners();
      _saveDownloads();
      _simulateDownloadProgress(id);
    }
  }

  void cancelDownload(String id) {
    final index = _downloads.indexWhere((d) => d.id == id);
    if (index != -1) {
      _downloads[index].state = DownloadState.canceled;
      _activeSimulations[id]?.cancel();
      _activeSimulations.remove(id);
      notifyListeners();
      _saveDownloads();
    }
  }

  void removeDownload(String id) {
    _activeSimulations[id]?.cancel();
    _activeSimulations.remove(id);
    _downloads.removeWhere((d) => d.id == id);
    notifyListeners();
    _saveDownloads();
  }

  void clearCompleted() {
    _downloads.removeWhere((d) => d.state == DownloadState.completed);
    notifyListeners();
    _saveDownloads();
  }
}
