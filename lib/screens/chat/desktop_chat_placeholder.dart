import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../chat/chat_screen.dart';

class DesktopChatPlaceholder extends StatelessWidget {
  const DesktopChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 20),
                ],
              ),
              child: Image.asset('assets/images/zipgram_logo.png', width: 140, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.chat_bubble_rounded, size: 64, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ZipGram Web & Desktop',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a conversation to start messaging',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
