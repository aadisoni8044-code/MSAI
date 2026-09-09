enum StatusType { text, image, video }

class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final StatusType type;
  final String content; // Text or Media URL
  final String? caption;
  final String? backgroundColorHex;
  final DateTime timestamp;
  final DateTime expiresAt;
  final List<String> viewerIds;

  const StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.type,
    required this.content,
    this.caption,
    this.backgroundColorHex,
    required this.timestamp,
    required this.expiresAt,
    this.viewerIds = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'type': type.name,
      'content': content,
      'caption': caption,
      'backgroundColorHex': backgroundColorHex,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewerIds': viewerIds,
    };
  }

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String? ?? '',
      type: StatusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatusType.text,
      ),
      content: json['content'] as String? ?? '',
      caption: json['caption'] as String?,
      backgroundColorHex: json['backgroundColorHex'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewerIds: List<String>.from(json['viewerIds'] as List? ?? []),
    );
  }

  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    StatusType? type,
    String? content,
    String? caption,
    String? backgroundColorHex,
    DateTime? timestamp,
    DateTime? expiresAt,
    List<String>? viewerIds,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      type: type ?? this.type,
      content: content ?? this.content,
      caption: caption ?? this.caption,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      viewerIds: viewerIds ?? this.viewerIds,
    );
  }
}
