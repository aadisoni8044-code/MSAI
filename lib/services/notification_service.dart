import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  List<NotificationItem> _notifications = [];

  NotificationService() {
    _initDemoData();
  }

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initDemoData() {
    final now = DateTime.now();

    _notifications = [
      NotificationItem(
        id: 'n1',
        title: 'New Message from Sophia',
        body: 'Awesome! I sent over the updated screen layout specs as an attachment.',
        type: NotificationType.message,
        timestamp: now.subtract(const Duration(minutes: 30)),
        relatedId: 'chat_1',
      ),
      NotificationItem(
        id: 'n2',
        title: 'Missed Call',
        body: 'Missed video call from Emma Watson',
        type: NotificationType.missedCall,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      NotificationItem(
        id: 'n3',
        title: 'Contact Joined',
        body: 'Noah Williams is now on ZIPGRAM!',
        type: NotificationType.contactJoined,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clearNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }
}
