import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Function(String reaction)? onReact;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReact,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _showActionsMenu(context),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? AppTheme.primaryCyan
                    : (theme.brightness == Brightness.dark
                        ? AppTheme.darkSurface
                        : AppTheme.lightSurface),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image && message.mediaUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.mediaUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.black : theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: isMe ? Colors.black54 : theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isSeen ? Icons.done_all : Icons.done,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ],
                    ],
                  ),
                  if (message.reaction != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.reaction!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['❤️', '🔥', '😂', '👍', '😮'].map((emoji) {
                  return IconButton(
                    icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onReact?.call(emoji);
                    },
                  );
                }).toList(),
              ),
              const Divider(),
              if (onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onDelete?.call();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
