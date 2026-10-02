import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../widgets/settings_tile.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final authProv = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZipPro Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('APP PREFERENCES', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Toggle dark and light UI theme',
            trailing: Switch(
              value: themeProv.isDarkMode,
              activeColor: AppTheme.primaryCyan,
              onChanged: (val) => themeProv.toggleTheme(val),
            ),
          ),
          SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ZipPro currently supports English.')),
              );
            },
          ),
          const Divider(height: 32),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('PERMISSIONS & PRIVACY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          SettingsTile(
            icon: Icons.camera_outlined,
            title: 'Camera & Microphone',
            subtitle: 'Manage camera permissions',
            onTap: () {
              PermissionService.showPermissionDialog(
                context: context,
                title: 'Camera Access',
                description: 'ZipPro requires camera permissions to capture photos and video stories.',
                onGrant: () {},
              );
            },
          ),
          SettingsTile(
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            subtitle: 'Story replies and message alerts',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.storage_outlined,
            title: 'Storage & Cache',
            subtitle: 'Clear local app cache',
            onTap: () async {
              await StorageService().clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully! 🧹')),
                );
              }
            },
          ),
          const Divider(height: 32),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('ABOUT & LEGAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About ${AppConstants.appName}',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationLegalese: '© 2026 ZipPro. All rights reserved.',
              );
            },
          ),
          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.15),
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await authProv.logout();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out of ZipPro', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
