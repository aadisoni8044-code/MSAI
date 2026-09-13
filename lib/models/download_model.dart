enum DownloadState {
  pending,
  downloading,
  paused,
  completed,
  failed,
  canceled,
}

class DownloadModel {
  final String id;
  final String fileName;
  final String url;
  final String fileSize;
  double progress; // 0.0 to 1.0
  DownloadState state;
  final DateTime startedAt;

  DownloadModel({
    required this.id,
    required this.fileName,
    required this.url,
    required this.fileSize,
    this.progress = 0.0,
    this.state = DownloadState.pending,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'url': url,
        'fileSize': fileSize,
        'progress': progress,
        'state': state.name,
        'startedAt': startedAt.toIso8601String(),
      };

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: json['fileName'] ?? 'file.bin',
      url: json['url'] ?? '',
      fileSize: json['fileSize'] ?? '0 MB',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      state: DownloadState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => DownloadState.completed,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
