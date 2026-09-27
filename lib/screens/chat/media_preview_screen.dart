import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MediaPreviewScreen extends StatelessWidget {
  final String mediaUrl;

  const MediaPreviewScreen({
    super.key,
    required this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Media Preview'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            mediaUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
