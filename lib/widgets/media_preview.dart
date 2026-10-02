import 'dart:io';
import 'package:flutter/material.dart';

class MediaPreview extends StatelessWidget {
  final String mediaPath;
  final bool isVideo;
  final BoxFit fit;

  const MediaPreview({
    super.key,
    required this.mediaPath,
    this.isVideo = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaPath.startsWith('http')) {
      return Image.network(
        mediaPath,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    } else if (File(mediaPath).existsSync()) {
      return Image.file(
        File(mediaPath),
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    } else {
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVideo ? Icons.videocam : Icons.photo,
              size: 48,
              color: Colors.white54,
            ),
            const SizedBox(height: 8),
            const Text(
              'ZipPro Media Preview',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
