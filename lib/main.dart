import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/message_provider.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MSAIChatApp());
}

class MSAIChatApp extends StatelessWidget {
  const MSAIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'MSAI Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default theme is dark and modern
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
