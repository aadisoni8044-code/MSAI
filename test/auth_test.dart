import 'package:flutter_test/flutter_test.dart';
import 'package:msai_chat/providers/auth_provider.dart';
import 'package:msai_chat/repositories/auth_repository.dart';
import 'package:msai_chat/services/auth_service.dart';

void main() {
  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider(
      authRepository: AuthRepository(authService: ApiAuthService()),
    );
  });

  group('Auth Provider Unit Tests', () {
    test('Initial state is unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
    });

    test('Login success updates currentUser and state', () async {
      final success = await authProvider.login('user@example.com', 'password123');
      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.email, 'user@example.com');
    });

    test('SignUp creates user and updates currentUser', () async {
      final success = await authProvider.signUp(
        'newuser@example.com',
        'password123',
        'New User',
      );
      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.name, 'New User');
    });

    test('Logout clears current user session', () async {
      await authProvider.login('user@example.com', 'password123');
      expect(authProvider.isAuthenticated, true);

      await authProvider.logout();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
    });
  });
}
