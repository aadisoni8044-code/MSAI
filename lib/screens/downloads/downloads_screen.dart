import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/downloads_provider.dart';
import '../../models/download_item.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadsProvider = Provider.of<DownloadsProvider>(context);
    final downloads = downloadsProvider.downloads;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (downloads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear All Downloads',
              onPressed: () => downloadsProvider.clearAllDownloads(),
            ),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_for_offline_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No Downloaded Files', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final item = downloads[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item.status == DownloadStatus.completed
                                  ? Icons.insert_drive_file_rounded
                                  : Icons.downloading_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.filename,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              onPressed: () => downloadsProvider.deleteDownload(item.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (item.status == DownloadStatus.downloading) ...[
                          LinearProgressIndicator(value: item.progress),
                          const SizedBox(height: 6),
                          Text(
                            '${(item.progress * 100).toInt()}% • ${(item.downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB / ${(item.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(item.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB • Completed',
                                style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Opening ${item.filename}')),
                                  );
                                },
                                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                label: const Text('Open'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
