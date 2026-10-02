import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/story_provider.dart';
import 'providers/discover_provider.dart';
import 'screens/responsive_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZipProApp());
}

class ZipProApp extends StatelessWidget {
  const ZipProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, child) {
          return MaterialApp(
            title: 'ZipPro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProv.themeMode,
            home: const ResponsiveScaffold(),
          );
        },
      ),
    );
  }
}
