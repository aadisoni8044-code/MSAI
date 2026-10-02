import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initUser();
  }

  Future<void> _initUser() async {
    await _storage.init();
    final saved = _storage.getUserProfile();
    if (saved != null) {
      _currentUser = saved;
    } else {
      _currentUser = User(
        id: 'usr_me',
        username: 'alex_zippro',
        displayName: 'Alex Rivers',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        bio: 'Creating moments in a Zip ⚡️ | Visual Storyteller',
        followersCount: 1420,
        followingCount: 380,
        isVerified: true,
      );
      await _storage.saveUserProfile(_currentUser!);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      displayName: displayName,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    notifyListeners();
    await _storage.saveUserProfile(_currentUser!);
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
