import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? ApiAuthService();

  Future<User?> getCurrentUser() => _authService.getCurrentUser();

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  Future<User> login({
    required String email,
    required String password,
  }) {
    return _authService.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPhoneOtp(String phone) =>
      _authService.sendPhoneOtp(phoneNumber: phone);

  Future<User> verifyPhoneOtp(String phone, String otp) =>
      _authService.verifyPhoneOtp(phoneNumber: phone, otpCode: otp);

  Future<void> sendForgotPasswordEmail(String email) =>
      _authService.sendPasswordResetEmail(email: email);

  Future<User> updateProfile(User user) =>
      _authService.updateUserProfile(user);

  Future<void> logout() => _authService.logout();
}
