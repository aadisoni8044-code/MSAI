import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auxiliary_providers.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';

class StatusTab extends StatelessWidget {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (statusProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final statuses = statusProvider.statuses;
    final myStatus = statuses.where((s) => s.userId == 'user_me').firstOrNull;
    final recentStatuses = statuses.where((s) => s.userId != 'user_me').toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Stack(
              children: [
                UserAvatar(
                  avatarUrl: currentUser?.avatarUrl ?? '',
                  name: currentUser?.name ?? 'My Status',
                  radius: 26,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            title: const Text('My Status', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              myStatus != null ? DateFormatter.formatTimestamp(myStatus.updatedAt) : 'Tap to add status update',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              if (myStatus != null) {
                Navigator.pushNamed(context, AppRoutes.statusStories, arguments: {'statusModel': myStatus});
              } else {
                Navigator.pushNamed(context, AppRoutes.cameraMediaPicker);
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Recent updates',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ...recentStatuses.map((status) {
            return ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status.isSeen ? Colors.grey : AppColors.accentGreen,
                    width: 2.5,
                  ),
                ),
                child: UserAvatar(
                  avatarUrl: status.userAvatarUrl,
                  name: status.userName,
                  radius: 24,
                ),
              ),
              title: Text(status.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                DateFormatter.formatTimestamp(status.updatedAt),
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                statusProvider.markStatusSeen(status.id);
                Navigator.pushNamed(context, AppRoutes.statusStories, arguments: {'statusModel': status});
              },
            );
          }),
        ],
      ),
    );
  }
}
