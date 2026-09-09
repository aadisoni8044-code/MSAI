import 'dart:convert';
import '../models/user_model.dart';
import '../core/services/storage_service.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final StorageService _storageService;
  UserModel? _currentUser;

  MockAuthRepository(this._storageService);

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final userJson = _storageService.getString(AppConstants.keyCurrentUser);
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        return _currentUser;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (phoneNumber.trim().isEmpty) {
      throw ValidationFailure('Please enter a valid phone number');
    }
    return true;
  }

  @override
  Future<UserModel> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp != '123456' && otp.length != 6) {
      throw AuthFailure('Invalid OTP verification code.');
    }

    final user = UserModel(
      id: 'user_me',
      name: 'Alex Johnson',
      phoneNumber: phoneNumber.isEmpty ? '+1 555-0199' : phoneNumber,
      about: 'Available | Building Flutter Apps 🚀',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      isOnline: true,
    );

    _currentUser = user;
    await _storageService.setString(AppConstants.keyCurrentUser, jsonEncode(user.toJson()));
    await _storageService.setString(AppConstants.keyAuthToken, 'mock_jwt_token_12345');
    return user;
  }

  @override
  Future<UserModel> registerUser({
    required String name,
    required String phoneNumber,
    String? about,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (name.trim().isEmpty) {
      throw ValidationFailure('Name cannot be empty.');
    }

    final user = UserModel(
      id: 'user_me',
      name: name,
      phoneNumber: phoneNumber,
      about: about ?? 'Hey there! I am using MSAI Chat.',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      isOnline: true,
    );

    _currentUser = user;
    await _storageService.setString(AppConstants.keyCurrentUser, jsonEncode(user.toJson()));
    await _storageService.setString(AppConstants.keyAuthToken, 'mock_jwt_token_12345');
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _storageService.remove(AppConstants.keyCurrentUser);
    await _storageService.remove(AppConstants.keyAuthToken);
  }
}
