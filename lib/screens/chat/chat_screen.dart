import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/attachment_sheet.dart';
import '../../widgets/reaction_picker.dart';
import '../group/group_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MockService _mockService = MockService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  Message? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _mockService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _mockService.removeListener(_onServiceUpdate);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    _mockService.sendMessage(
      widget.chat.id,
      _textController.text.trim(),
      replyToId: _replyToMessage?.id,
      replyToContent: _replyToMessage?.content,
      replyToSenderName: _replyToMessage?.senderName,
    );

    _textController.clear();
    setState(() {
      _isComposing = false;
      _replyToMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentSheet(
        onOptionSelected: (type) {
          if (type == 'gallery' || type == 'camera') {
            _mockService.sendMessage(
              widget.chat.id,
              'Shared an image',
              type: MessageType.image,
              mediaUrl: 'https://picsum.photos/400/300?random=${DateTime.now().second}',
            );
          } else if (type == 'document') {
            _mockService.sendMessage(
              widget.chat.id,
              'ZipGram_Document.pdf',
              type: MessageType.document,
              fileName: 'ZipGram_Document.pdf',
              fileSize: '3.8 MB',
            );
          }
        },
      ),
    );
  }

  void _showLongPressMenu(Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ReactionPicker(
                onEmojiSelected: (emoji) {
                  _mockService.addReaction(widget.chat.id, message.id, emoji);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.reply_rounded, color: Colors.white),
              title: const Text('Reply', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyToMessage = message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.white),
              title: const Text('Copy Text', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Delete Message', style: TextStyle(color: AppColors.error)),
              onTap: () {
                _mockService.deleteMessage(widget.chat.id, message.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _mockService.getMessages(widget.chat.id);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            if (widget.chat.isGroup) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupInfoScreen(chat: widget.chat)),
              );
            }
          },
          child: Row(
            children: [
              Avatar(
                imageUrl: widget.chat.avatarUrl,
                radius: 20,
                isOnline: widget.chat.isOnline,
                showOnlineIndicator: !widget.chat.isGroup,
                isGroup: widget.chat.isGroup,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.chat.isGroup
                          ? '${widget.chat.memberIds.length} members'
                          : (widget.chat.isOnline ? 'Online' : 'Last seen recently'),
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.chat.isOnline ? AppColors.online : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (val) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Text(widget.chat.isGroup ? 'Group Info' : 'View Contact'),
              ),
              const PopupMenuItem(value: 'mute', child: Text('Mute Notifications')),
              const PopupMenuItem(value: 'search', child: Text('Search Messages')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textMuted.withAlpha(100)),
                          const SizedBox(height: 12),
                          Text('No messages here yet.', style: TextStyle(color: AppColors.textSecondary.withAlpha(180))),
                          const SizedBox(height: 4),
                          const Text('Send a message to start chatting!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == _mockService.currentUser.id;
                        return MessageBubble(
                          message: msg,
                          isMe: isMe,
                          isGroup: widget.chat.isGroup,
                          onLongPress: () => _showLongPressMenu(msg),
                        );
                      },
                    ),
            ),
            if (_replyToMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.surfaceHighlight,
                child: Row(
                  children: [
                    Container(width: 4, height: 36, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_replyToMessage!.senderName, style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(_replyToMessage!.content, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
                      onPressed: () => setState(() => _replyToMessage = null),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
                    onPressed: _showAttachmentSheet,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (val) {
                        setState(() {
                          _isComposing = val.trim().isNotEmpty;
                        });
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isComposing
                        ? CircleAvatar(
                            key: const ValueKey('send_btn'),
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                              onPressed: _sendMessage,
                            ),
                          )
                        : CircleAvatar(
                            key: const ValueKey('mic_btn'),
                            backgroundColor: AppColors.surfaceHighlight,
                            child: IconButton(
                              icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                              onPressed: () {
                                _mockService.sendMessage(
                                  widget.chat.id,
                                  'Voice note (0:05)',
                                  type: MessageType.voice,
                                );
                              },
                            ),
                          ),
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
