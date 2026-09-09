import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'user_avatar.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return DateFormat('hh:mm a').format(dateTime);
    }
    return DateFormat('dd/MM/yy').format(dateTime);
  }

  Widget _buildStatusTicks(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 14, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: Colors.blueAccent);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 14, color: Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: UserAvatar(
        url: chat.avatarUrl,
        name: chat.name,
        radius: 26,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(
            _formatTime(chat.updatedAt),
            style: TextStyle(
              fontSize: 12,
              color: chat.unreadCount > 0
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (chat.lastMessage != null) ...[
            _buildStatusTicks(chat.lastMessage!.status),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chat.lastMessage?.content ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          if (chat.isMuted) ...[
            const SizedBox(width: 4),
            Icon(Icons.volume_off, size: 16, color: Colors.grey[500]),
          ],
          if (chat.isPinned) ...[
            const SizedBox(width: 4),
            Icon(Icons.push_pin, size: 16, color: Colors.grey[500]),
          ],
          if (chat.unreadCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
