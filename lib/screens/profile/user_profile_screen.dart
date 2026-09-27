import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/avatar_widget.dart';

class UserProfileScreen extends StatelessWidget {
  final bool isEmbedded;

  const UserProfileScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = MockService().currentUser;

    final body = ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        Center(
          child: Stack(
            children: [
              AvatarWidget(
                imageUrl: user.avatarUrl,
                name: user.name,
                radius: 54,
                showOnlineIndicator: false,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            user.username,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                title: const Text('About', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                subtitle: Text(
                  user.statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textMuted),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: AppColors.primaryBlue),
                title: const Text('Phone', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                subtitle: Text(
                  user.phoneNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryBlue),
                title: const Text('ZIPgram QR Code', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Share your profile link easily', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.darkSurface,
                      title: const Text('My ZIPgram QR', textAlign: TextAlign.center),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded, size: 160, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          Text(user.username, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: AppColors.primaryBlue),
                title: const Text('Share Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile link copied!')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
                title: const Text('Settings', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
        ),
      ],
    );

    if (isEmbedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: body,
    );
  }
}
