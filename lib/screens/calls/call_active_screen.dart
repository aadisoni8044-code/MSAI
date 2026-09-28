import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/call.dart';
import '../../widgets/avatar.dart';

class CallActiveScreen extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final bool isVideo;

  const CallActiveScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              isVideo ? 'ZipGram Video Call' : 'ZipGram Voice Call',
              style: const TextStyle(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ringing...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const Spacer(),
            Avatar(imageUrl: userAvatar, radius: 64),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceHighlight,
                  child: IconButton(
                    icon: const Icon(Icons.mic_off_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceHighlight,
                  child: IconButton(
                    icon: Icon(isVideo ? Icons.videocam_off_rounded : Icons.volume_up_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.error,
                  child: IconButton(
                    icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
