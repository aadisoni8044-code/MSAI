import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/status_ring_avatar.dart';

class StatusView extends StatelessWidget {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final statuses = service.statuses;
        final myStatus = statuses.firstWhere(
          (s) => s.userId == service.currentUser.id,
          orElse: () => statuses.first,
        );
        final recentStatuses = statuses.where((s) => s.userId != service.currentUser.id && !s.isViewed).toList();
        final viewedStatuses = statuses.where((s) => s.userId != service.currentUser.id && s.isViewed).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: StatusRingAvatar(
                imageUrl: myStatus.userAvatar,
                name: myStatus.userName,
                radius: 26,
                isMyStatus: true,
                onAddTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add status story clicked')),
                  );
                },
              ),
              title: const Text(
                'My status',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text(
                'Tap to add status update',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.statusViewer, arguments: myStatus);
              },
            ),
            const Divider(height: 24),
            if (recentStatuses.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Recent updates',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              ...recentStatuses.map(
                (status) => ListTile(
                  leading: StatusRingAvatar(
                    imageUrl: status.userAvatar,
                    name: status.userName,
                    radius: 24,
                    isSeen: false,
                  ),
                  title: Text(
                    status.userName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Today, 2 hours ago',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.statusViewer, arguments: status);
                  },
                ),
              ),
            ],
            if (viewedStatuses.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Viewed updates',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              ...viewedStatuses.map(
                (status) => ListTile(
                  leading: StatusRingAvatar(
                    imageUrl: status.userAvatar,
                    name: status.userName,
                    radius: 24,
                    isSeen: true,
                  ),
                  title: Text(
                    status.userName,
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Yesterday',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.statusViewer, arguments: status);
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
