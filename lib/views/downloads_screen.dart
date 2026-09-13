import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/download_model.dart';
import '../providers/downloads_provider.dart';
import '../theme/app_theme.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final downloadsProvider = context.watch<DownloadsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppTheme.primaryLightBlue),
            SizedBox(width: 10),
            Text('Downloads'),
          ],
        ),
        actions: [
          if (downloadsProvider.downloads.any((d) => d.state == DownloadState.completed))
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              tooltip: 'Clear Completed',
              onPressed: () {
                downloadsProvider.clearCompleted();
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Simulate Download Task',
            onPressed: () => _showSimulateDownloadDialog(context),
          ),
        ],
      ),
      body: downloadsProvider.downloads.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: downloadsProvider.downloads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = downloadsProvider.downloads[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File Name & Status Chip
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.insert_drive_file_rounded,
                                color: AppTheme.primaryLightBlue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.fileSize} • ${item.url}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStateChip(item.state),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Download Progress Bar
                        if (item.state == DownloadState.downloading ||
                            item.state == DownloadState.paused) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: item.progress,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryLightBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(item.progress * 100).toInt()}% downloaded',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              Row(
                                children: [
                                  if (item.state == DownloadState.downloading)
                                    IconButton(
                                      icon: const Icon(
                                          Icons.pause_circle_outline_rounded,
                                          size: 22),
                                      tooltip: 'Pause',
                                      onPressed: () => downloadsProvider
                                          .pauseDownload(item.id),
                                    )
                                  else if (item.state == DownloadState.paused)
                                    IconButton(
                                      icon: const Icon(
                                          Icons.play_circle_outline_rounded,
                                          size: 22),
                                      tooltip: 'Resume',
                                      onPressed: () => downloadsProvider
                                          .resumeDownload(item.id),
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 22,
                                        color: Colors.redAccent),
                                    tooltip: 'Cancel',
                                    onPressed: () => downloadsProvider
                                        .cancelDownload(item.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ] else if (item.state == DownloadState.completed) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'File downloaded successfully',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(
                                        Icons.folder_open_rounded,
                                        size: 16),
                                    label: const Text('Open'),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Opening file: ${item.fileName}'),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                        color: Colors.redAccent),
                                    tooltip: 'Delete File',
                                    onPressed: () => downloadsProvider
                                        .removeDownload(item.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20, color: Colors.redAccent),
                                tooltip: 'Delete Task',
                                onPressed: () =>
                                    downloadsProvider.removeDownload(item.id),
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

  Widget _buildStateChip(DownloadState state) {
    Color bg;
    Color text;
    String label;

    switch (state) {
      case DownloadState.downloading:
        bg = AppTheme.primaryBlue.withOpacity(0.15);
        text = AppTheme.primaryLightBlue;
        label = 'Downloading';
        break;
      case DownloadState.paused:
        bg = Colors.amber.withOpacity(0.15);
        text = Colors.amber;
        label = 'Paused';
        break;
      case DownloadState.completed:
        bg = Colors.green.withOpacity(0.15);
        text = Colors.green;
        label = 'Completed';
        break;
      case DownloadState.canceled:
      case DownloadState.failed:
        bg = Colors.red.withOpacity(0.15);
        text = Colors.redAccent;
        label = 'Canceled';
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No active downloads',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Downloaded files and active transfers will show up here.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showSimulateDownloadDialog(BuildContext context) {
    final nameController =
        TextEditingController(text: 'Firezip_Asset_Pack.zip');
    final urlController =
        TextEditingController(text: 'https://firezip.com/assets.zip');
    final sizeController = TextEditingController(text: '18.4 MB');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Download Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'File Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'Source URL'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: 'File Size'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DownloadsProvider>().startDownload(
                    nameController.text.trim(),
                    urlController.text.trim(),
                    sizeController.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('Start Download'),
          ),
        ],
      ),
    );
  }
}
