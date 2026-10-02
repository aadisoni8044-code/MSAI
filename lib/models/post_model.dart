import 'media_model.dart';

class Post {
  final String id;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final String title;
  final String description;
  final String mediaUrl;
  final MediaType mediaType;
  final String category;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.mediaType,
    required this.category,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    String? authorName,
    String? authorUsername,
    String? authorAvatar,
    String? title,
    String? description,
    String? mediaUrl,
    MediaType? mediaType,
    String? category,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'title': title,
      'description': description,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType.name,
      'category': category,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorUsername: json['authorUsername'] as String,
      authorAvatar: json['authorAvatar'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] == 'video' ? MediaType.video : MediaType.photo,
      category: json['category'] as String,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
