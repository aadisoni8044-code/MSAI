enum StatusType { image, video, text }

class StatusMedia {
  final String id;
  final StatusType type;
  final String url;
  final String caption;
  final String? backgroundColorHex;
  final DateTime timestamp;

  const StatusMedia({
    required this.id,
    required this.type,
    required this.url,
    this.caption = '',
    this.backgroundColorHex,
    required this.timestamp,
  });
}

class Status {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final List<StatusMedia> mediaItems;
  final bool isViewed;

  const Status({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mediaItems,
    this.isViewed = false,
  });

  Status copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    List<StatusMedia>? mediaItems,
    bool? isViewed,
  }) {
    return Status(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      mediaItems: mediaItems ?? this.mediaItems,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
