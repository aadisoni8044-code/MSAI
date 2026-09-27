import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;
  final VoidCallback? onMorePressed;

  static const List<String> defaultEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  const ReactionPicker({
    super.key,
    required this.onEmojiSelected,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...defaultEmojis.map(
            (emoji) => GestureDetector(
              onTap: () => onEmojiSelected(emoji),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          if (onMorePressed != null)
            GestureDetector(
              onTap: onMorePressed,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.darkSurfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
