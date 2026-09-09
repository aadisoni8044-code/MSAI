import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> checkSession() async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authRepository.login(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPhoneOtp(String phone) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.sendPhoneOtp(phone);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authRepository.verifyPhoneOtp(phone, otp);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendForgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.sendForgotPasswordEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await _authRepository.updateProfile(updatedUser);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }
}
