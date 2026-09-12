import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SettingsTab extends StatelessWidget {
  final SettingsService settingsService;
  final AuthService authService;
  final VoidCallback onOpenProfile;

  const SettingsTab({
    super.key,
    required this.settingsService,
    required this.authService,
    required this.onOpenProfile,
  });

  void _showLanguageSelector(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Hindi', 'Japanese', 'Chinese'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select App Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = settingsService.selectedLanguage == lang;
                    return ListTile(
                      title: Text(lang),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlueLight) : null,
                      onTap: () {
                        settingsService.setSelectedLanguage(lang);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.bolt_rounded, color: AppColors.primaryBlueLight),
            SizedBox(width: 8),
            Text('About ZIPGRAM'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('ZIPGRAM Version 1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('A modern, fast, blue-inspired messaging app constructed purely with Flutter and Dart.'),
            SizedBox(height: 12),
            Text('© 2026 ZIPGRAM Inc. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryBlueLight)),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, String title, String contentText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(contentText, style: const TextStyle(fontSize: 14, height: 1.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryBlueLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, _) {
        final currentUser = authService.currentUser;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // User Header Quick Card
            if (currentUser != null)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryBlue.withAlpha(50),
                    child: Text(
                      currentUser.name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryBlueLight),
                    ),
                  ),
                  title: Text(currentUser.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(currentUser.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlueLight),
                  onTap: onOpenProfile,
                ),
              ),
            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight, letterSpacing: 1.0)),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlueLight),
                    title: const Text('Profile Details'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: onOpenProfile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlueLight),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy & Security options active')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('APP SETTINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight, letterSpacing: 1.0)),
            ),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryBlueLight),
                    title: const Text('Dark Mode (Default)'),
                    subtitle: Text(settingsService.isDarkMode ? 'Enabled' : 'Light Theme Active'),
                    value: settingsService.isDarkMode,
                    onChanged: (val) => settingsService.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.primaryBlueLight),
                    title: const Text('Notifications'),
                    value: settingsService.notificationsEnabled,
                    onChanged: (val) => settingsService.setNotificationsEnabled(val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.mark_chat_read_outlined, color: AppColors.primaryBlueLight),
                    title: const Text('Read Receipts'),
                    value: settingsService.readReceiptsEnabled,
                    onChanged: (val) => settingsService.setReadReceiptsEnabled(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primaryBlueLight),
                    title: const Text('Language'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(settingsService.selectedLanguage, style: const TextStyle(color: AppColors.textSecondaryDark)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: () => _showLanguageSelector(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('ABOUT & LEGAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight, letterSpacing: 1.0)),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlueLight),
                    title: const Text('About ZIPGRAM'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: AppColors.primaryBlueLight),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPolicyDialog(
                      context,
                      'Terms of Service',
                      'Welcome to ZIPGRAM. By using our messaging service, you agree to comply with our terms of service designed to maintain a fast, reliable, and secure messaging environment.',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryBlueLight),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPolicyDialog(
                      context,
                      'Privacy Policy',
                      'ZIPGRAM values your privacy above all. All messaging transactions are handled securely. We do not sell your private communication data.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
