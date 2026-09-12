import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final NotificationService notificationService;

  const NotificationsScreen({
    super.key,
    required this.notificationService,
  });

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.missedCall:
        return Icons.phone_missed_rounded;
      case NotificationType.contactJoined:
        return Icons.person_add_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return AppColors.primaryBlueLight;
      case NotificationType.missedCall:
        return AppColors.missedCallRed;
      case NotificationType.contactJoined:
        return AppColors.onlineGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => notificationService.markAllAsRead(),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primaryBlueLight)),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: notificationService,
        builder: (context, _) {
          final items = notificationService.notifications;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondaryDark.withAlpha(80)),
                  const SizedBox(height: 12),
                  const Text('No new notifications', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final color = _getNotificationColor(item.type);

              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => notificationService.clearNotification(item.id),
                background: Container(
                  color: AppColors.missedCallRed,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                child: Container(
                  color: item.isRead ? Colors.transparent : AppColors.primaryBlue.withAlpha(15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha(30),
                      child: Icon(_getNotificationIcon(item.type), color: color, size: 22),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(item.timestamp),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item.body,
                        style: const TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    ),
                    onTap: () {
                      notificationService.markAsRead(item.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
