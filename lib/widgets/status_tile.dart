import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/status.dart';
import 'avatar.dart';

class StatusTile extends StatelessWidget {
  final UserStatus status;
  final VoidCallback onTap;

  const StatusTile({
    super.key,
    required this.status,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return 'Yesterday';
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestItem = status.items.last;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: status.isViewed ? AppColors.textMuted : AppColors.primary,
            width: 2.5,
          ),
        ),
        child: Avatar(
          imageUrl: status.userAvatar,
          radius: 24,
        ),
      ),
      title: Text(
        status.userName,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _formatTime(latestItem.timestamp),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
