import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Dark';
  String _selectedLanguage = 'English';

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Dark (Default)'),
              value: 'Dark',
              groupValue: _selectedTheme,
              onChanged: (val) {
                setState(() => _selectedTheme = val!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'Light',
              groupValue: _selectedTheme,
              onChanged: (val) {
                setState(() => _selectedTheme = val!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'System',
              groupValue: _selectedTheme,
              onChanged: (val) {
                setState(() => _selectedTheme = val!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            if (user != null)
              ListTile(
                leading: UserAvatar(name: user.name, url: user.avatarUrl, radius: 30),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(user.about, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.qr_code),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profileCreation);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Account'),
              subtitle: const Text('Security notifications, change number, delete account'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy'),
              subtitle: const Text('Block contacts, disappearing messages, last seen'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Appearance & Theme'),
              subtitle: Text('Current theme: $_selectedTheme'),
              onTap: _showThemeDialog,
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Message, group & call tones'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.data_usage),
              title: const Text('Storage and Data'),
              subtitle: const Text('Network usage, auto-download settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('App Language'),
              subtitle: Text('Current language: $_selectedLanguage'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              subtitle: const Text('Help center, contact us, privacy policy'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('${AppConstants.appName} v1.0.0'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
