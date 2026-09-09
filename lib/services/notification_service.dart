class NotificationService {
  Future<void> initialize() async {
    // Register push notification handlers (FCM / APNs)
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Display local device notification
  }

  Future<void> subscribeToTopic(String topic) async {
    // Subscribe to chat topic or status updates
  }
}
