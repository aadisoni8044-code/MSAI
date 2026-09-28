import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Stack(
                children: [
                  Avatar(imageUrl: user.avatarUrl, radius: 54),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: const TextStyle(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Card(
              color: AppColors.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_rounded, color: AppColors.primary),
                    title: const Text('Name', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    subtitle: Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
                    trailing: const Icon(Icons.edit_rounded, color: AppColors.textMuted, size: 18),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    title: const Text('About', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    subtitle: Text(user.about, style: const TextStyle(color: Colors.white, fontSize: 15)),
                    trailing: const Icon(Icons.edit_rounded, color: AppColors.textMuted, size: 18),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_rounded, color: AppColors.primary),
                    title: const Text('Phone Number', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    subtitle: Text(user.phoneNumber, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surface,
              child: ListTile(
                leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 32),
                title: const Text('ZipGram QR Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Scan to easily add contact or chat', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('ZipGram QR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black),
                            ),
                            const SizedBox(height: 12),
                            Text('@${user.username}', style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('View', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
