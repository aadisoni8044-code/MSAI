import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/mock_service.dart';
import '../settings/settings_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.security_rounded), title: Text('Security notifications')),
          ListTile(leading: Icon(Icons.phonelink_setup_rounded), title: Text('Two-step verification')),
          ListTile(leading: Icon(Icons.phonelink_ring_rounded), title: Text('Change number')),
          ListTile(leading: Icon(Icons.download_rounded), title: Text('Request account info')),
          ListTile(leading: Icon(Icons.delete_outline_rounded, color: AppColors.error), title: Text('Delete account', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        children: const [
          ListTile(title: Text('Last seen & online'), subtitle: Text('Everyone', style: TextStyle(color: AppColors.textSecondary))),
          ListTile(title: Text('Profile photo'), subtitle: Text('Everyone', style: TextStyle(color: AppColors.textSecondary))),
          ListTile(title: Text('About'), subtitle: Text('Everyone', style: TextStyle(color: AppColors.textSecondary))),
          ListTile(title: Text('Status'), subtitle: Text('My contacts', style: TextStyle(color: AppColors.textSecondary))),
          Divider(),
          ListTile(title: Text('Read receipts'), subtitle: Text('If turned off, you won\'t send or receive Read receipts.'), trailing: Switch(value: true, onChanged: null)),
          Divider(),
          ListTile(title: Text('Blocked contacts'), subtitle: Text('None', style: TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats Settings')),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.wallpaper_rounded), title: Text('Wallpaper')),
          ListTile(leading: Icon(Icons.keyboard_return_rounded), title: Text('Enter is send'), trailing: Switch(value: true, onChanged: null)),
          ListTile(leading: Icon(Icons.text_fields_rounded), title: Text('Font size'), subtitle: Text('Medium', style: TextStyle(color: AppColors.textSecondary))),
          Divider(),
          ListTile(leading: Icon(Icons.backup_rounded), title: Text('Chat backup')),
          ListTile(leading: Icon(Icons.history_rounded), title: Text('Chat history')),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            title: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(user.about, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            trailing: const Icon(Icons.qr_code_rounded, color: AppColors.primary),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key_rounded, color: AppColors.primary),
            title: const Text('Account', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Security notifications, change number', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_rounded, color: AppColors.primary),
            title: const Text('Privacy', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Block contacts, disappearing messages', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_rounded, color: AppColors.primary),
            title: const Text('Chats', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Theme, wallpapers, chat history', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatSettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_rounded, color: AppColors.primary),
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Message, group & call tones', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.data_usage_rounded, color: AppColors.primary),
            title: const Text('Storage and Data', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Network usage, auto-download', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
            title: const Text('Help', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Help center, contact us, privacy policy', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () {},
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text('ZipGram for Flutter', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Version 1.0.0 (Build 2026)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
