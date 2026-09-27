import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../core/theme/app_colors.dart';
import 'avatar_widget.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatTile({
    super.key,
    required this.chat,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
  });

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year.toString().substring(2)}';
    }
  }

  Widget _buildMessagePreview(Message? msg) {
    if (msg == null) {
      return const Text(
        'Tap to start chatting',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontStyle: FontStyle.italic),
      );
    }

    IconData? mediaIcon;
    String text = msg.text;

    switch (msg.type) {
      case MessageType.image:
        mediaIcon = Icons.camera_alt_rounded;
        if (text.isEmpty) text = 'Photo';
        break;
      case MessageType.video:
        mediaIcon = Icons.videocam_rounded;
        if (text.isEmpty) text = 'Video';
        break;
      case MessageType.audio:
        mediaIcon = Icons.mic_rounded;
        if (text.isEmpty) text = 'Voice message';
        break;
      case MessageType.document:
        mediaIcon = Icons.insert_drive_file_rounded;
        if (text.isEmpty) text = 'Document';
        break;
      case MessageType.location:
        mediaIcon = Icons.location_on_rounded;
        if (text.isEmpty) text = 'Location';
        break;
      default:
        mediaIcon = null;
    }

    return Row(
      children: [
        if (mediaIcon != null) ...[
          Icon(mediaIcon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = chat.participant?.status == UserStatus.online;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: AppColors.primaryBlue.withAlpha(25),
      highlightColor: AppColors.primaryBlue.withAlpha(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkSurfaceSecondary : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: AppColors.dividerColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            AvatarWidget(
              imageUrl: chat.avatarUrl,
              name: chat.name,
              radius: 26,
              isOnline: isOnline,
              showOnlineIndicator: chat.type == ChatType.individual,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (chat.lastMessage != null)
                        Text(
                          _formatTimestamp(chat.lastMessage!.timestamp),
                          style: TextStyle(
                            color: chat.unreadCount > 0 ? AppColors.primaryBlue : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: _buildMessagePreview(chat.lastMessage)),
                      if (chat.isMuted) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.volume_off_rounded, size: 16, color: AppColors.textMuted),
                      ],
                      if (chat.isPinned) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.textMuted),
                      ],
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
