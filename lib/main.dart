import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/network_service.dart';
import 'repositories/mock_auth_repository.dart';
import 'repositories/mock_user_repository.dart';
import 'repositories/mock_chat_repository.dart';
import 'repositories/mock_group_repository.dart';
import 'repositories/mock_media_status_call_repository.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/group_provider.dart';
import 'providers/auxiliary_providers.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await SharedPreferencesStorageService.getInstance();
  final notificationService = MockNotificationService();
  await notificationService.initialize();
  final networkService = MockNetworkService();

  final authRepo = MockAuthRepository(storageService);
  final userRepo = MockUserRepository();
  final chatRepo = MockChatRepository();
  final groupRepo = MockGroupRepository();
  final statusRepo = MockStatusRepository();
  final callRepo = MockCallRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MSAI Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
