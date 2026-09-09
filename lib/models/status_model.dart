enum StatusType { text, image, video }

class StatusItem {
  final String id;
  final StatusType type;
  final String mediaUrl;
  final String caption;
  final DateTime timestamp;
  final List<String> viewerIds;

  const StatusItem({
    required this.id,
    required this.type,
    required this.mediaUrl,
    this.caption = '',
    required this.timestamp,
    this.viewerIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'timestamp': timestamp.toIso8601String(),
      'viewerIds': viewerIds,
    };
  }

  factory StatusItem.fromJson(Map<String, dynamic> json) {
    return StatusItem(
      id: json['id'] as String,
      type: StatusType.values.byName(json['type'] as String? ?? 'image'),
      mediaUrl: json['mediaUrl'] as String,
      caption: json['caption'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      viewerIds: List<String>.from(json['viewerIds'] as List? ?? []),
    );
  }
}

class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final List<StatusItem> items;
  final DateTime updatedAt;
  final bool isSeen;

  const StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.items,
    required this.updatedAt,
    this.isSeen = false,
  });

  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    List<StatusItem>? items,
    DateTime? updatedAt,
    bool? isSeen,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'items': items.map((i) => i.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSeen': isSeen,
    };
  }

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      items: (json['items'] as List)
          .map((i) => StatusItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSeen: json['isSeen'] as bool? ?? false,
    );
  }
}
