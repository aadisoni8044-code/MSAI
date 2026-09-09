import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/user_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: UserAvatar(
              avatarUrl: user?.avatarUrl ?? '',
              name: user?.name ?? 'User',
              radius: 30,
            ),
            title: Text(user?.name ?? 'Alex Johnson', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(user?.about ?? 'Available', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.qr_code, color: Colors.teal),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Account'),
            subtitle: const Text('Security notifications, change number'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacySettings),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy'),
            subtitle: const Text('Block contacts, disappearing messages'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacySettings),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Message, group & call tones'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettings),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text('Current mode: ${themeProvider.themeMode.name}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Choose Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('System default'),
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (val) {
                          if (val != null) themeProvider.setThemeMode(val);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Light'),
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (val) {
                          if (val != null) themeProvider.setThemeMode(val);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Dark'),
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (val) {
                          if (val != null) themeProvider.setThemeMode(val);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Storage and data'),
            subtitle: const Text('Network usage, auto-download'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.mediaGallery),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            subtitle: const Text('Help center, contact us, privacy policy'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
