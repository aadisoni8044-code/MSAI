import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZombieProgressController extends ChangeNotifier {
  static final ZombieProgressController _instance = ZombieProgressController._internal();
  static ZombieProgressController get instance => _instance;

  ZombieProgressController._internal();

  int _highestWaveCompleted = 0;
  int _totalZombiesDefeated = 0;
  final Set<String> _unlockedWeapons = {'basic'};
  String _selectedWeapon = 'basic';
  bool _towerUnlocked = true; // Default tower available as defensive position
  bool _has50MilestoneShown = false;
  bool _has100MilestoneShown = false;
  bool _initialized = false;

  int get highestWaveCompleted => _highestWaveCompleted;
  int get totalZombiesDefeated => _totalZombiesDefeated;
  Set<String> get unlockedWeapons => Set.unmodifiable(_unlockedWeapons);
  String get selectedWeapon => _selectedWeapon;
  bool get towerUnlocked => _towerUnlocked;
  bool get has50MilestoneShown => _has50MilestoneShown;
  bool get has100MilestoneShown => _has100MilestoneShown;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _highestWaveCompleted = prefs.getInt('zombie_highest_wave') ?? 0;
      _totalZombiesDefeated = prefs.getInt('zombie_total_defeated') ?? 0;

      final weaponsList = prefs.getStringList('zombie_unlocked_weapons') ?? ['basic'];
      _unlockedWeapons.clear();
      _unlockedWeapons.addAll(weaponsList);

      _selectedWeapon = prefs.getString('zombie_selected_weapon') ?? 'basic';
      if (!_unlockedWeapons.contains(_selectedWeapon)) {
        _selectedWeapon = 'basic';
      }

      _towerUnlocked = prefs.getBool('zombie_tower_unlocked') ?? true;
      _has50MilestoneShown = prefs.getBool('zombie_50_milestone') ?? false;
      _has100MilestoneShown = prefs.getBool('zombie_100_milestone') ?? false;
    } catch (e) {
      debugPrint('Error initializing ZombieProgressController: $e');
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> addZombiesDefeated(int count) async {
    _totalZombiesDefeated += count;

    // Check auto unlocks
    if (_totalZombiesDefeated >= 30 && !_unlockedWeapons.contains('ak47')) {
      _unlockedWeapons.add('ak47');
    }

    notifyListeners();
    await _save();
  }

  Future<void> completeWave(int waveNumber) async {
    if (waveNumber > _highestWaveCompleted) {
      _highestWaveCompleted = waveNumber;
    }

    // Unlocks based on wave completion
    if (waveNumber >= 2 && !_unlockedWeapons.contains('ak47')) {
      _unlockedWeapons.add('ak47');
    }

    notifyListeners();
    await _save();
  }

  Future<void> selectWeapon(String weaponId) async {
    if (_unlockedWeapons.contains(weaponId)) {
      _selectedWeapon = weaponId;
      notifyListeners();
      await _save();
    }
  }

  Future<void> unlockWeapon(String weaponId) async {
    _unlockedWeapons.add(weaponId);
    notifyListeners();
    await _save();
  }

  Future<void> setMilestoneShown(int milestone) async {
    if (milestone == 50) {
      _has50MilestoneShown = true;
    } else if (milestone == 100) {
      _has100MilestoneShown = true;
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('zombie_highest_wave', _highestWaveCompleted);
      await prefs.setInt('zombie_total_defeated', _totalZombiesDefeated);
      await prefs.setStringList('zombie_unlocked_weapons', _unlockedWeapons.toList());
      await prefs.setString('zombie_selected_weapon', _selectedWeapon);
      await prefs.setBool('zombie_tower_unlocked', _towerUnlocked);
      await prefs.setBool('zombie_50_milestone', _has50MilestoneShown);
      await prefs.setBool('zombie_100_milestone', _has100MilestoneShown);
    } catch (e) {
      debugPrint('Error saving zombie progress: $e');
    }
  }

  Future<void> resetProgress() async {
    _highestWaveCompleted = 0;
    _totalZombiesDefeated = 0;
    _unlockedWeapons.clear();
    _unlockedWeapons.add('basic');
    _selectedWeapon = 'basic';
    _towerUnlocked = true;
    _has50MilestoneShown = false;
    _has100MilestoneShown = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('zombie_highest_wave');
      await prefs.remove('zombie_total_defeated');
      await prefs.remove('zombie_unlocked_weapons');
      await prefs.remove('zombie_selected_weapon');
      await prefs.remove('zombie_tower_unlocked');
      await prefs.remove('zombie_50_milestone');
      await prefs.remove('zombie_100_milestone');
    } catch (e) {
      debugPrint('Error resetting zombie progress: $e');
    }
  }
}
