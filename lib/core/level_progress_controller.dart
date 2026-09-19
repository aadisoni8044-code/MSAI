import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelProgressController extends ChangeNotifier {
  static final LevelProgressController _instance = LevelProgressController._internal();
  static LevelProgressController get instance => _instance;

  LevelProgressController._internal();

  int _highestUnlockedLevel = 1;
  final Set<int> _completedLevels = {};
  bool _initialized = false;

  int get highestUnlockedLevel => _highestUnlockedLevel;
  Set<int> get completedLevels => Set.unmodifiable(_completedLevels);

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _highestUnlockedLevel = prefs.getInt('highest_unlocked_level') ?? 1;
      final completedList = prefs.getStringList('completed_levels_list') ?? [];
      _completedLevels.clear();
      for (final item in completedList) {
        final val = int.tryParse(item);
        if (val != null) {
          _completedLevels.add(val);
        }
      }
    } catch (e) {
      debugPrint('Error initializing LevelProgressController: $e');
    }
    _initialized = true;
    notifyListeners();
  }

  bool isUnlocked(int levelNumber) {
    return levelNumber <= _highestUnlockedLevel;
  }

  bool isCompleted(int levelNumber) {
    return _completedLevels.contains(levelNumber);
  }

  Future<void> completeLevel(int levelNumber) async {
    _completedLevels.add(levelNumber);
    if (levelNumber < 10 && (levelNumber + 1) > _highestUnlockedLevel) {
      _highestUnlockedLevel = levelNumber + 1;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highest_unlocked_level', _highestUnlockedLevel);
      await prefs.setStringList(
        'completed_levels_list',
        _completedLevels.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint('Error saving level progress: $e');
    }
  }

  Future<void> resetProgress() async {
    _highestUnlockedLevel = 1;
    _completedLevels.clear();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('highest_unlocked_level');
      await prefs.remove('completed_levels_list');
    } catch (e) {
      debugPrint('Error resetting level progress: $e');
    }
  }
}
