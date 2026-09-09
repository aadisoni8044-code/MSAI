import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../models/message.dart';
import 'voice_message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSelf;
  final Function(Message)? onReply;
  final Function(Message)? onForward;
  final Function(Message)? onDelete;
  final Function(Message)? onStar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSelf,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onStar,
  });

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(ctx);
                onReply?.call(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(message.isStarred ? 'Unstar' : 'Star'),
              onTap: () {
                Navigator.pop(ctx);
                onStar?.call(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shortcut),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(ctx);
                onForward?.call(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTicks(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time_rounded, size: 12, color: Colors.white70);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.lightBlueAccent);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 12, color: Colors.redAccent);
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black12,
                height: 180,
                width: double.infinity,
                child: const Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(message.content),
            ]
          ],
        );
      case MessageType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black26,
                height: 180,
                width: double.infinity,
                child: const Icon(Icons.play_circle_fill, size: 56, color: Colors.white),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(message.content),
            ]
          ],
        );
      case MessageType.audio:
        return VoiceMessageWidget(
          audioUrl: message.mediaUrl ?? '',
          durationSeconds: message.durationSeconds ?? 0,
          isSelf: isSelf,
        );
      case MessageType.document:
        return Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 36),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'Document',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${((message.fileSize ?? 0) / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        );
      case MessageType.text:
      default:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isSelf ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelf
        ? AppConstants.darkBubbleSelf
        : Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onLongPress: () => _showOptionsSheet(context),
      child: Align(
        alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isSelf ? const Radius.circular(12) : Radius.zero,
              bottomRight: isSelf ? Radius.zero : const Radius.circular(12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.replyToContent != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(6),
                    border: const Border(
                      left: BorderSide(color: AppConstants.accentColor, width: 3),
                    ),
                  ),
                  child: Text(
                    message.replyToContent!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              if (message.isForwarded) ...[
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shortcut, size: 12, color: Colors.grey),
                    SizedBox(width: 2),
                    Text(
                      'Forwarded',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
              ],
              _buildContent(context),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (message.isStarred) ...[
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelf ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  if (isSelf) ...[
                    const SizedBox(width: 4),
                    _buildStatusTicks(message.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
