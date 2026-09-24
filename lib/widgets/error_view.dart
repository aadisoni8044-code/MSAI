import 'package:flutter/material.dart';

enum CustomErrorType {
  noInternet,
  pageLoadError,
  invalidUrl,
  connectionFailure,
  downloadFailure,
}

class CustomErrorView extends StatelessWidget {
  final CustomErrorType errorType;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const CustomErrorView({
    super.key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    String description;

    switch (errorType) {
      case CustomErrorType.noInternet:
        icon = Icons.wifi_off_rounded;
        title = 'No Internet Connection';
        description = 'Please check your Wi-Fi or mobile cellular network and try loading the page again.';
        break;
      case CustomErrorType.pageLoadError:
        icon = Icons.error_outline_rounded;
        title = 'Unable to Load Page';
        description = 'The server responded with an error or took too long to load.';
        break;
      case CustomErrorType.invalidUrl:
        icon = Icons.link_off_rounded;
        title = 'Invalid Web Address';
        description = 'The URL entered is not formatted correctly or could not be resolved.';
        break;
      case CustomErrorType.connectionFailure:
        icon = Icons.security_update_warning_rounded;
        title = 'Connection Refused';
        description = 'The target website refused secure connection or is currently offline.';
        break;
      case CustomErrorType.downloadFailure:
        icon = Icons.file_download_off_rounded;
        title = 'Download Failed';
        description = 'Could not fetch file content. Check storage permissions and server status.';
        break;
    }

    if (customMessage != null && customMessage!.isNotEmpty) {
      description = customMessage!;
    }

    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onGoHome != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: onGoHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Home'),
                  ),
                if (onGoHome != null && onRetry != null) const SizedBox(width: 12),
                if (onRetry != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
