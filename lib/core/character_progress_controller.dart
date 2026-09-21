import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';

class CharacterProgressController extends ChangeNotifier {
  static final CharacterProgressController _instance = CharacterProgressController._internal();
  static CharacterProgressController get instance => _instance;

  CharacterProgressController._internal();

  int _totalCoins = 500; // Starter coins for a great initial experience!
  final Set<String> _unlockedCharacterIds = {'char_1'};
  String _selectedCharacterId = 'char_1';
  bool _initialized = false;

  int get totalCoins => _totalCoins;
  Set<String> get unlockedCharacterIds => Set.unmodifiable(_unlockedCharacterIds);
  String get selectedCharacterId => _selectedCharacterId;
  CharacterData get selectedCharacter => CharacterData.getById(_selectedCharacterId);

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalCoins = prefs.getInt('total_coins') ?? 500;
      final savedUnlocked = prefs.getStringList('unlocked_characters_list');
      if (savedUnlocked != null && savedUnlocked.isNotEmpty) {
        _unlockedCharacterIds.clear();
        _unlockedCharacterIds.addAll(savedUnlocked);
      }
      _unlockedCharacterIds.add('char_1'); // Always ensure default character is unlocked

      final savedSelected = prefs.getString('selected_character_id');
      if (savedSelected != null && _unlockedCharacterIds.contains(savedSelected)) {
        _selectedCharacterId = savedSelected;
      } else {
        _selectedCharacterId = 'char_1';
      }
    } catch (e) {
      debugPrint('Error initializing CharacterProgressController: $e');
    }
    _initialized = true;
    notifyListeners();
  }

  bool isUnlocked(String characterId) {
    if (characterId == 'char_1') return true;
    return _unlockedCharacterIds.contains(characterId);
  }

  bool isSelected(String characterId) {
    return _selectedCharacterId == characterId;
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    _totalCoins += amount;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<bool> purchaseCharacter(CharacterData character) async {
    if (isUnlocked(character.id)) {
      return true;
    }
    if (_totalCoins < character.price) {
      return false; // Insufficient coins
    }

    _totalCoins -= character.price;
    _unlockedCharacterIds.add(character.id);
    _selectedCharacterId = character.id; // Auto select on purchase
    notifyListeners();
    await _saveToPrefs();
    return true;
  }

  Future<void> selectCharacter(String characterId) async {
    if (!isUnlocked(characterId)) return;
    _selectedCharacterId = characterId;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('total_coins', _totalCoins);
      await prefs.setStringList('unlocked_characters_list', _unlockedCharacterIds.toList());
      await prefs.setString('selected_character_id', _selectedCharacterId);
    } catch (e) {
      debugPrint('Error saving character progress: $e');
    }
  }

  Future<void> resetProgress() async {
    _totalCoins = 500;
    _unlockedCharacterIds.clear();
    _unlockedCharacterIds.add('char_1');
    _selectedCharacterId = 'char_1';
    notifyListeners();
    await _saveToPrefs();
  }
}
