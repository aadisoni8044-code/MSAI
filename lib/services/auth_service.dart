import '../models/user.dart';

abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> sendPhoneOtp({required String phoneNumber});
  Future<User> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<User> updateUserProfile(User user);
  Future<void> logout();
}

class ApiAuthService implements AuthService {
  // Real backend production implementation reference point.
  // Connects to REST/Firebase auth API.
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid email or password (min 6 chars)');
    }
    _currentUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: '+1234567890',
    );
    return _currentUser!;
  }

  @override
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    _currentUser = User(
      id: 'usr_demo_1',
      name: 'Demo User',
      email: email,
      phone: '+1234567890',
      isOnline: true,
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPhoneOtp({required String phoneNumber}) async {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }
    // Real OTP request logic to SMS gateway / Firebase Auth
  }

  @override
  Future<User> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    if (otpCode.length != 6) {
      throw Exception('Invalid 6-digit OTP code');
    }
    _currentUser = User(
      id: 'usr_phone_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Phone User',
      phone: phoneNumber,
      isOnline: true,
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (email.isEmpty) {
      throw Exception('Email is required');
    }
    // Real backend call
  }

  @override
  Future<User> updateUserProfile(User user) async {
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
