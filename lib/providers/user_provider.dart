import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  List<User> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  List<User> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchUsers(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _searchResults = await _userRepository.searchUsers(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    await _userRepository.blockUser(currentUserId, targetUserId);
    notifyListeners();
  }

  Future<void> reportUser(String targetUserId, String reason) async {
    await _userRepository.reportUser(targetUserId, reason);
    notifyListeners();
  }
}
