import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<bool> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp(String phoneNumber, String otp);
  Future<UserModel> registerUser({required String name, required String phoneNumber, String? about});
  Future<void> logout();
}
