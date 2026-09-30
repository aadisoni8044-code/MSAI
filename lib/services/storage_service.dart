import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/contact.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _keyProfile = 'zipgram_user_profile';
  static const String _keySettings = 'zipgram_app_settings';
  static const String _keyContacts = 'zipgram_contacts';
  static const String _keyMessagesPrefix = 'zipgram_messages_';
  static const String _keyBlockedDevices = 'zipgram_blocked_devices';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Profile Storage
  Future<UserProfile> loadUserProfile() async {
    final p = await prefs;
    final jsonStr = p.getString(_keyProfile);
    if (jsonStr != null) {
      try {
        return UserProfile.fromJson(json.decode(jsonStr));
      } catch (_) {}
    }
    // Default initial profile
    final defaultProfile = UserProfile(
      id: 'user_local_me',
      username: 'zip_user_1',
      displayName: 'ZIP User',
      deviceName: 'My ZIP Device',
    );
    await saveUserProfile(defaultProfile);
    return defaultProfile;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final p = await prefs;
    await p.setString(_keyProfile, json.encode(profile.toJson()));
  }

  // App Settings Storage
  Future<AppSettings> loadAppSettings() async {
    final p = await prefs;
    final jsonStr = p.getString(_keySettings);
    if (jsonStr != null) {
      try {
        return AppSettings.fromJson(json.decode(jsonStr));
      } catch (_) {}
    }
    return AppSettings();
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    final p = await prefs;
    await p.setString(_keySettings, json.encode(settings.toJson()));
  }

  // Chat Messages Storage
  Future<List<ChatMessage>> loadMessagesForChat(String peerId) async {
    final p = await prefs;
    final jsonStr = p.getString('$_keyMessagesPrefix$peerId');
    if (jsonStr != null) {
      try {
        final List<dynamic> rawList = json.decode(jsonStr);
        return rawList.map((item) => ChatMessage.fromJson(item)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveMessagesForChat(
      String peerId, List<ChatMessage> messages) async {
    final p = await prefs;
    final encoded = json.encode(messages.map((m) => m.toJson()).toList());
    await p.setString('$_keyMessagesPrefix$peerId', encoded);
  }

  // Saved Contacts Storage
  Future<List<Contact>> loadContacts() async {
    final p = await prefs;
    final jsonStr = p.getString(_keyContacts);
    if (jsonStr != null) {
      try {
        final List<dynamic> rawList = json.decode(jsonStr);
        return rawList.map((item) => Contact.fromJson(item)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveContacts(List<Contact> contacts) async {
    final p = await prefs;
    final encoded = json.encode(contacts.map((c) => c.toJson()).toList());
    await p.setString(_keyContacts, encoded);
  }

  // Blocked Devices Storage
  Future<List<String>> loadBlockedDeviceIds() async {
    final p = await prefs;
    return p.getStringList(_keyBlockedDevices) ?? [];
  }

  Future<void> saveBlockedDeviceIds(List<String> blockedIds) async {
    final p = await prefs;
    await p.setStringList(_keyBlockedDevices, blockedIds);
  }

  Future<void> clearAllData() async {
    final p = await prefs;
    await p.clear();
  }
}
