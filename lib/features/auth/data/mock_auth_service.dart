import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/models/user_model.dart';
import '../domain/auth_repository.dart';

class MockAuthService implements AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _user;

  MockAuthService() {
    _initUser();
  }

  Future<void> _initUser() async {
    final email = await _storage.read(key: 'mock_user_email');
    if (email != null) {
      _user = UserModel(
        uid: 'user_mock_123',
        email: email,
        displayName: email.split('@').first,
        isEmailVerified: true,
      );
    }
    _controller.add(_user);
  }

  @override
  Stream<UserModel?> get authStateChanges => _controller.stream;

  @override
  UserModel? get currentUser => _user;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (password.length < 6) {
      throw Exception('Invalid credentials. Password must be at least 6 characters.');
    }
    _user = UserModel(
      uid: 'user_mock_123',
      email: email,
      displayName: email.split('@').first,
      isEmailVerified: true,
    );
    await _storage.write(key: 'mock_user_email', value: email);
    _controller.add(_user);
    return _user!;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }
    _user = UserModel(
      uid: 'user_mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      isEmailVerified: false,
    );
    await _storage.write(key: 'mock_user_email', value: email);
    _controller.add(_user);
    return _user!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_user != null) {
      _user = _user!.copyWith(isEmailVerified: true);
      _controller.add(_user);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _storage.delete(key: 'mock_user_email');
    _user = null;
    _controller.add(null);
  }
}
