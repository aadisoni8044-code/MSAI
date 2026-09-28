enum StatusType { image, video, text }

class StatusItem {
  final String id;
  final StatusType type;
  final String content; // Image URL or text content
  final String? caption;
  final DateTime timestamp;
  final String? backgroundColorHex;

  StatusItem({
    required this.id,
    required this.type,
    required this.content,
    this.caption,
    required this.timestamp,
    this.backgroundColorHex,
  });
}

class UserStatus {
  final String userId;
  final String userName;
  final String userAvatar;
  final List<StatusItem> items;
  final bool isViewed;

  UserStatus({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.items,
    this.isViewed = false,
  });
}
