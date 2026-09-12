import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = true; // Default logged in with demo user
  bool _isLoading = false;

  AuthService() {
    _currentUser = User(
      id: 'user_current',
      name: 'Alex Morgan',
      username: 'alexm',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      bio: 'Building the future of communication with ZIPGRAM ⚡',
      phone: '+1 (555) 019-2831',
      status: UserStatus.online,
      lastSeen: DateTime.now(),
    );
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<bool> login(String credential, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    _isAuthenticated = true;
    _currentUser = User(
      id: 'user_current',
      name: 'Alex Morgan',
      username: 'alexm',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      bio: 'Building the future of communication with ZIPGRAM ⚡',
      phone: '+1 (555) 019-2831',
      status: UserStatus.online,
      lastSeen: DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String name, String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    _isAuthenticated = true;
    _currentUser = User(
      id: 'user_current',
      name: name,
      username: username,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      bio: 'Hey there! I am using ZIPGRAM.',
      phone: email,
      status: UserStatus.online,
      lastSeen: DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void updateProfile({String? name, String? username, String? bio, String? phone, String? avatarUrl}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      username: username,
      bio: bio,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
