import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/app_settings.dart';
import 'services/storage_service.dart';
import 'services/bluetooth_service.dart';
import 'providers/theme_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/chat_provider.dart';
import 'widgets/responsive_scaffold.dart';
import 'screens/home_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final bluetoothService = BluetoothService();

  runApp(
    ZipgramApp(
      storageService: storageService,
      bluetoothService: bluetoothService,
    ),
  );
}

class ZipgramApp extends StatelessWidget {
  final StorageService storageService;
  final BluetoothService bluetoothService;

  const ZipgramApp({
    super.key,
    required this.storageService,
    required this.bluetoothService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService: storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(
            bluetoothService: bluetoothService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            bluetoothService: bluetoothService,
            storageService: storageService,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          ThemeMode mode;
          switch (themeProvider.themeMode) {
            case AppThemeMode.light:
              mode = ThemeMode.light;
              break;
            case AppThemeMode.dark:
              mode = ThemeMode.dark;
              break;
            case AppThemeMode.system:
              mode = ThemeMode.system;
              break;
          }

          return MaterialApp(
            title: 'ZIPGRAM',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: MainNavigationWrapper(storageService: storageService),
          );
        },
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  final StorageService storageService;

  const MainNavigationWrapper({super.key, required this.storageService});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _onNavigationIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateToTab: _onNavigationIndexChanged,
      ),
      const NearbyScreen(),
      const ContactsScreen(),
      const SettingsScreen(),
    ];

    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onNavigationIndexChanged: _onNavigationIndexChanged,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
