import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplyTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isMe
        ? (isDark ? AppColors.darkChatBubble : AppColors.lightGreen)
        : (isDark ? AppColors.darkSurface : Colors.white);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.2) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.replyToContent != null) _buildReplyHeader(context, isDark),
                _buildMessageContent(context, textColor),
                const SizedBox(height: 4),
                _buildMessageFooter(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyHeader(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onReplyTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.grey.shade200).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
          border: const Border(
            left: BorderSide(
              color: AppColors.primaryTeal,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.replyToSenderName ?? 'Reply',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.replyToContent ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Color textColor) {
    if (message.isDeleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.block, size: 16, color: Colors.grey),
          SizedBox(width: 6),
          Text(
            'This message was deleted',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      );
    }

    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.mediaUrl ?? 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=80',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(message.content, style: TextStyle(color: textColor, fontSize: 15)),
            ],
          ],
        );

      case MessageType.voice:
      case MessageType.audio:
        return Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryTeal,
              radius: 18,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 3,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: 0.4,
                  onChanged: (v) {},
                  activeColor: AppColors.primaryTeal,
                  inactiveColor: Colors.grey.shade400,
                ),
              ),
            ),
            Text(
              DateFormatter.formatDuration(Duration(seconds: message.audioDurationSeconds ?? 12)),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        );

      case MessageType.document:
        return Row(
          children: [
            const Icon(Icons.insert_drive_file, color: AppColors.primaryTeal, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'Document.pdf',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${((message.fileSize ?? 1024000) / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        );

      case MessageType.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.location_on, size: 40, color: AppColors.error),
              ),
            ),
            const SizedBox(height: 6),
            Text('Location: ${message.latitude ?? 37.7749}, ${message.longitude ?? -122.4194}', style: TextStyle(color: textColor)),
          ],
        );

      case MessageType.contact:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.contactName ?? 'Shared Contact',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    message.contactPhone ?? '+1 555-0199',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );

      case MessageType.text:
      case MessageType.emoji:
      case MessageType.video:
      case MessageType.reply:
      default:
        return Text(
          message.content,
          style: TextStyle(fontSize: 15, color: textColor),
        );
    }
  }

  Widget _buildMessageFooter(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (message.isEdited)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              'edited',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        if (message.isStarred)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.star, size: 12, color: Colors.amber),
          ),
        Text(
          DateFormatter.formatMessageTime(message.timestamp),
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _buildStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 14, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 14, color: AppColors.checkMarkGrey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: AppColors.checkMarkGrey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: AppColors.checkMarkBlue);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 14, color: AppColors.error);
    }
  }
}
