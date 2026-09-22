import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/custom_map_data.dart';

class CustomMapProgressController extends ChangeNotifier {
  static final CustomMapProgressController instance = CustomMapProgressController._internal();

  CustomMapProgressController._internal();

  static const String _storageKey = 'enchanted_custom_user_maps_v1';

  final List<CustomMapData> _userMaps = [];
  bool _initialized = false;

  bool get isInitialized => _initialized;
  List<CustomMapData> get userMaps => List.unmodifiable(_userMaps);
  List<CustomMapData> get templates => CustomMapData.builtInTemplates;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final loaded = CustomMapData.deserializeList(jsonStr);
        _userMaps.clear();
        _userMaps.addAll(loaded);
      }
    } catch (e) {
      debugPrint('Error loading custom maps: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = CustomMapData.serializeList(_userMaps);
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving custom maps: $e');
    }
  }

  CustomMapData? getMapById(String id) {
    for (final map in _userMaps) {
      if (map.id == id) return map;
    }
    for (final tpl in templates) {
      if (tpl.id == id) return tpl;
    }
    return null;
  }

  Future<CustomMapData> createNewBlankMap({String name = 'My New Map', String theme = 'forest'}) async {
    final newId = 'map_${DateTime.now().millisecondsSinceEpoch}';
    const double groundY = 680.0;

    final newMap = CustomMapData(
      id: newId,
      name: name.trim().isEmpty ? 'My New Map' : name.trim(),
      theme: theme,
      worldWidth: 4800,
      worldHeight: 800,
      playerStartX: 100,
      playerStartY: groundY - 60,
      finishX: 4500,
      finishY: groundY - 90,
      isTemplate: false,
      entities: [
        // Default ground platform to start with
        CustomMapEntity(
          id: 'ent_start_ground',
          type: 'platform',
          x: 0,
          y: groundY,
          width: 1200,
          height: 120,
        ),
        CustomMapEntity(
          id: 'ent_end_ground',
          type: 'platform',
          x: 3600,
          y: groundY,
          width: 1200,
          height: 120,
        ),
      ],
    );

    _userMaps.add(newMap);
    await _saveToPrefs();
    notifyListeners();
    return newMap;
  }

  Future<CustomMapData> duplicateTemplateAsNewMap(CustomMapData templateMap, {String? customName}) async {
    final newId = 'map_${DateTime.now().millisecondsSinceEpoch}';
    final name = customName ?? '${templateMap.name} (My Copy)';

    final newMap = templateMap.copyAsNewMap(
      newId: newId,
      newName: name,
    );

    _userMaps.add(newMap);
    await _saveToPrefs();
    notifyListeners();
    return newMap;
  }

  Future<void> saveMap(CustomMapData map) async {
    map.updatedDate = DateTime.now();

    final existingIndex = _userMaps.indexWhere((m) => m.id == map.id);
    if (existingIndex >= 0) {
      _userMaps[existingIndex] = map;
    } else {
      _userMaps.add(map);
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteMap(String mapId) async {
    _userMaps.removeWhere((m) => m.id == mapId);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> recordMapAttempt(String mapId) async {
    final map = getMapById(mapId);
    if (map != null && !map.isTemplate) {
      map.totalAttempts += 1;
      await saveMap(map);
    }
  }

  Future<void> recordMapCompletion(String mapId, {required double timeSeconds, required int coinsCollected}) async {
    final map = getMapById(mapId);
    if (map != null && !map.isTemplate) {
      map.isCompleted = true;
      if (map.bestTimeSeconds == null || timeSeconds < map.bestTimeSeconds!) {
        map.bestTimeSeconds = timeSeconds;
      }
      if (coinsCollected > map.highestCoinsCollected) {
        map.highestCoinsCollected = coinsCollected;
      }
      await saveMap(map);
    }
  }
}
