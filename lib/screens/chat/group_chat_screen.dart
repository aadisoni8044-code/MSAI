import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/attachment_sheet.dart';
import '../../widgets/reaction_picker.dart';

class GroupChatScreen extends StatefulWidget {
  final Chat chat;

  const GroupChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isComposing = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({MessageType type = MessageType.text, String? mediaUrl}) {
    final text = _textController.text.trim();
    if (text.isEmpty && type == MessageType.text) return;

    final service = MockService();
    service.sendMessage(
      chatId: widget.chat.id,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
    );

    _textController.clear();

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
      builder: (ctx) => AttachmentSheet(
        onOptionSelected: (type) {
          Navigator.pop(ctx);
          if (type == 'gallery' || type == 'camera') {
            _sendMessage(
              type: MessageType.image,
              mediaUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Attached $type to group')),
            );
          }
        },
      ),
    );
  }

  void _showMessageActions(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReactionPicker(
            onEmojiSelected: (emoji) {
              Navigator.pop(ctx);
              MockService().addReaction(widget.chat.id, msg.id, emoji);
            },
          ),
          const SizedBox(height: 12),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.reply_rounded, color: AppColors.primaryBlue),
                    title: const Text('Reply'),
                    onTap: () {
                      Navigator.pop(ctx);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded, color: AppColors.primaryBlue),
                    title: const Text('Copy'),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message copied')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
                    title: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                    onTap: () {
                      Navigator.pop(ctx);
                      MockService().deleteMessage(widget.chat.id, msg.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = MockService();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.groupInfo, arguments: widget.chat),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: widget.chat.avatarUrl,
                name: widget.chat.name,
                radius: 18,
                showOnlineIndicator: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.chat.groupMembers.length} members',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.activeCall, arguments: widget.chat.name),
          ),
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.activeCall, arguments: widget.chat.name),
          ),
        ],
      ),
      body: Container(
        color: AppColors.darkBackground,
        child: AnimatedBuilder(
          animation: service,
          builder: (context, child) {
            final messages = service.getMessagesForChat(widget.chat.id);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == service.currentUser.id;
                      return MessageBubble(
                        message: msg,
                        isMe: isMe,
                        showSenderName: true,
                        onLongPress: () => _showMessageActions(msg),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  color: AppColors.darkSurface,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded, color: AppColors.iconColor),
                        onPressed: _showAttachmentSheet,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Group message...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(
                          _isComposing ? Icons.send_rounded : Icons.mic_rounded,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: () => _sendMessage(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
