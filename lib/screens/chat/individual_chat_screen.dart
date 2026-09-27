import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/attachment_sheet.dart';
import '../../widgets/reaction_picker.dart';

class IndividualChatScreen extends StatefulWidget {
  final Chat chat;
  final bool isEmbedded;

  const IndividualChatScreen({
    super.key,
    required this.chat,
    this.isEmbedded = false,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  Message? _replyToMessage;

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

  void _sendMessage({MessageType type = MessageType.text, String? mediaUrl, String? fileName, String? fileSize}) {
    final text = _textController.text.trim();
    if (text.isEmpty && type == MessageType.text) return;

    final service = MockService();
    service.sendMessage(
      chatId: widget.chat.id,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: _replyToMessage?.id,
      replyToText: _replyToMessage?.text,
      replyToSender: _replyToMessage?.senderName,
    );

    _textController.clear();
    setState(() {
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
      builder: (ctx) => AttachmentSheet(
        onOptionSelected: (type) {
          Navigator.pop(ctx);
          if (type == 'gallery' || type == 'camera') {
            _sendMessage(
              type: MessageType.image,
              mediaUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400',
            );
          } else if (type == 'document') {
            _sendMessage(
              type: MessageType.document,
              fileName: 'Project_Specification.pdf',
              fileSize: '2.4 MB',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Attached $type')),
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
                      setState(() {
                        _replyToMessage = msg;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded, color: AppColors.primaryBlue),
                    title: const Text('Copy'),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message copied to clipboard')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline_rounded, color: AppColors.primaryBlue),
                    title: const Text('Star Message'),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message starred')),
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

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.dividerColor, width: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyToMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: AppColors.primaryBlue, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${_replyToMessage!.senderName}',
                          style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          _replyToMessage!.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                    onPressed: () {
                      setState(() {
                        _replyToMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: AppColors.iconColor),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.attach_file_rounded, color: AppColors.iconColor),
                onPressed: _showAttachmentSheet,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: _isComposing
                    ? InkWell(
                        key: const ValueKey('send_button'),
                        onTap: () => _sendMessage(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      )
                    : InkWell(
                        key: const ValueKey('mic_button'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Voice recording started...')),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.darkSurfaceSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_rounded, color: AppColors.primaryBlue, size: 20),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = MockService();

    final bodyContent = Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=500'),
          fit: BoxFit.cover,
          opacity: 0.03,
        ),
      ),
      child: AnimatedBuilder(
        animation: service,
        builder: (context, child) {
          final messages = service.getMessagesForChat(widget.chat.id);
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet. Say hi to ${widget.chat.name}!',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == service.currentUser.id;
                          return MessageBubble(
                            message: msg,
                            isMe: isMe,
                            onLongPress: () => _showMessageActions(msg),
                            onMediaTap: (url) {
                              Navigator.pushNamed(context, AppRoutes.mediaPreview, arguments: url);
                            },
                          );
                        },
                      ),
              ),
              _buildComposer(),
            ],
          );
        },
      ),
    );

    if (widget.isEmbedded) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.darkSurface,
            child: Row(
              children: [
                AvatarWidget(
                  imageUrl: widget.chat.avatarUrl,
                  name: widget.chat.name,
                  radius: 20,
                  isOnline: widget.chat.participant?.status == UserStatus.online,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chat.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        widget.chat.participant?.status == UserStatus.online ? 'Online' : 'Offline',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_rounded, color: AppColors.primaryBlue),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.activeCall, arguments: widget.chat.name),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_rounded, color: AppColors.primaryBlue),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.activeCall, arguments: widget.chat.name),
                ),
              ],
            ),
          ),
          Expanded(child: bodyContent),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AvatarWidget(
              imageUrl: widget.chat.avatarUrl,
              name: widget.chat.name,
              radius: 18,
              isOnline: widget.chat.participant?.status == UserStatus.online,
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
                    widget.chat.participant?.status == UserStatus.online ? 'Online' : 'Last seen recently',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.activeCall, arguments: widget.chat.name),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.activeCall, arguments: widget.chat.name),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
