import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/main.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/providers/group_provider.dart';
import 'package:app/providers/auxiliary_providers.dart';
import 'package:app/repositories/mock_auth_repository.dart';
import 'package:app/repositories/mock_user_repository.dart';
import 'package:app/repositories/mock_chat_repository.dart';
import 'package:app/repositories/mock_group_repository.dart';
import 'package:app/repositories/mock_media_status_call_repository.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/core/services/network_service.dart';

class MockStorageService implements StorageService {
  final Map<String, dynamic> _data = {};

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}

void main() {
  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    final mockStorage = MockStorageService();
    final networkService = MockNetworkService();

    final authRepo = MockAuthRepository(mockStorage);
    final userRepo = MockUserRepository();
    final chatRepo = MockChatRepository();
    final groupRepo = MockGroupRepository();
    final statusRepo = MockStatusRepository();
    final callRepo = MockCallRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(mockStorage)),
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
          ChangeNotifierProvider(create: (_) => ChatProvider(chatRepo, networkService)),
          ChangeNotifierProvider(create: (_) => GroupProvider(groupRepo)),
          ChangeNotifierProvider(create: (_) => StatusProvider(statusRepo)),
          ChangeNotifierProvider(create: (_) => CallProvider(callRepo)),
          ChangeNotifierProvider(create: (_) => UserProvider(userRepo)),
          ChangeNotifierProvider(create: (_) => SearchProvider(userRepo, chatRepo)),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
