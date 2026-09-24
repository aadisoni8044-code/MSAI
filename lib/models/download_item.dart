enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
}

class DownloadItem {
  final String id;
  final String filename;
  final String url;
  final String filePath;
  double progress;
  DownloadStatus status;
  int totalBytes;
  int downloadedBytes;
  final DateTime createdAt;

  DownloadItem({
    required this.id,
    required this.filename,
    required this.url,
    required this.filePath,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'url': url,
        'filePath': filePath,
        'progress': progress,
        'status': status.name,
        'totalBytes': totalBytes,
        'downloadedBytes': downloadedBytes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] as String,
      filename: json['filename'] as String,
      url: json['url'] as String,
      filePath: json['filePath'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.pending,
      ),
      totalBytes: (json['totalBytes'] as int?) ?? 0,
      downloadedBytes: (json['downloadedBytes'] as int?) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
