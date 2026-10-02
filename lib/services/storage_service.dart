import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/story_model.dart';
import '../models/message_model.dart';
import '../models/post_model.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Theme
  Future<void> saveThemeMode(String mode) async {
    await init();
    await _prefs?.setString(AppConstants.keyThemeMode, mode);
  }

  String? getThemeMode() {
    return _prefs?.getString(AppConstants.keyThemeMode);
  }

  // User Profile
  Future<void> saveUserProfile(User user) async {
    await init();
    await _prefs?.setString(AppConstants.keyUserProfile, jsonEncode(user.toJson()));
  }

  User? getUserProfile() {
    final raw = _prefs?.getString(AppConstants.keyUserProfile);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  // Stories
  Future<void> saveStories(List<Story> stories) async {
    await init();
    final rawList = stories.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs?.setStringList(AppConstants.keyStories, rawList);
  }

  List<Story> getStories() {
    final rawList = _prefs?.getStringList(AppConstants.keyStories);
    if (rawList == null) return [];
    return rawList
        .map((item) {
          try {
            return Story.fromJson(jsonDecode(item));
          } catch (_) {
            return null;
          }
        })
        .whereType<Story>()
        .toList();
  }

  // Messages
  Future<void> saveMessages(List<Message> messages) async {
    await init();
    final rawList = messages.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs?.setStringList(AppConstants.keyChats, rawList);
  }

  List<Message> getMessages() {
    final rawList = _prefs?.getStringList(AppConstants.keyChats);
    if (rawList == null) return [];
    return rawList
        .map((item) {
          try {
            return Message.fromJson(jsonDecode(item));
          } catch (_) {
            return null;
          }
        })
        .whereType<Message>()
        .toList();
  }

  // Posts
  Future<void> savePosts(List<Post> posts) async {
    await init();
    final rawList = posts.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs?.setStringList(AppConstants.keyPosts, rawList);
  }

  List<Post> getPosts() {
    final rawList = _prefs?.getStringList(AppConstants.keyPosts);
    if (rawList == null) return [];
    return rawList
        .map((item) {
          try {
            return Post.fromJson(jsonDecode(item));
          } catch (_) {
            return null;
          }
        })
        .whereType<Post>()
        .toList();
  }

  // Clear cache
  Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }
}
