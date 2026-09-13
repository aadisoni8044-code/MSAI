class HistoryItemModel {
  final String id;
  final String title;
  final String url;
  final DateTime visitedAt;

  HistoryItemModel({
    required this.id,
    required this.title,
    required this.url,
    DateTime? visitedAt,
  }) : visitedAt = visitedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'visitedAt': visitedAt.toIso8601String(),
      };

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Visited Site',
      url: json['url'] ?? '',
      visitedAt: json['visitedAt'] != null
          ? DateTime.tryParse(json['visitedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
