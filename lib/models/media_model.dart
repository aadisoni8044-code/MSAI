enum MediaType { photo, video }

class MediaItem {
  final String id;
  final String url;
  final MediaType type;
  final String? caption;
  final DateTime createdAt;
  final double? durationSeconds;

  MediaItem({
    required this.id,
    required this.url,
    required this.type,
    this.caption,
    required this.createdAt,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type.name,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] == 'video' ? MediaType.video : MediaType.photo,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
    );
  }
}
