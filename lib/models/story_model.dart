import 'media_model.dart';

class Story {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String mediaUrl;
  final MediaType mediaType;
  final String? caption;
  final DateTime createdAt;
  final int viewsCount;
  final bool isExpired;

  Story({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
    this.viewsCount = 0,
    this.isExpired = false,
  });

  bool get checkExpired {
    return DateTime.now().difference(createdAt).inHours >= 24;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType.name,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'viewsCount': viewsCount,
      'isExpired': isExpired,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] == 'video' ? MediaType.video : MediaType.photo,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }
}
