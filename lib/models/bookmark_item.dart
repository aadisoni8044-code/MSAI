class BookmarkItem {
  final String id;
  final String url;
  final String title;
  final String folder;
  final DateTime createdAt;

  BookmarkItem({
    required this.id,
    required this.url,
    required this.title,
    this.folder = 'General',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'folder': folder,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      folder: (json['folder'] as String?) ?? 'General',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
