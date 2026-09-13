class BookmarkModel {
  final String id;
  final String title;
  final String url;
  final String? faviconUrl;
  final DateTime createdAt;
  final String? category;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.url,
    this.faviconUrl,
    DateTime? createdAt,
    this.category,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'faviconUrl': faviconUrl,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
      };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled Bookmark',
      url: json['url'] ?? '',
      faviconUrl: json['faviconUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      category: json['category'],
    );
  }
}
