import 'dart:async';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });
  Stream<String?> get onNotificationClicked;
}

class MockNotificationService implements NotificationService {
  final StreamController<String?> _notificationController = StreamController<String?>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}

  @override
  Stream<String?> get onNotificationClicked => _notificationController.stream;

  void simulateClick(String payload) {
    _notificationController.add(payload);
  }

  void dispose() {
    _notificationController.close();
  }
}
