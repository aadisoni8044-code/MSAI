import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/call_model.dart';
import '../services/chat_service.dart';
import '../services/call_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;
  final ChatService chatService;
  final CallService callService;
  final VoidCallback onStartCall;

  const ChatDetailScreen({
    super.key,
    required this.chat,
    required this.chatService,
    required this.callService,
    required this.onStartCall,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmoji = false;
  bool _isRecordingVoice = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    widget.chatService.sendMessage(
      chatId: widget.chat.id,
      text: text,
    );

    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Share Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.image_rounded,
                    color: Colors.purpleAccent,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      widget.chatService.sendMessage(
                        chatId: widget.chat.id,
                        text: 'Shared a photo from gallery',
                        type: MessageType.image,
                      );
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.insert_drive_file_rounded,
                    color: AppColors.primaryBlue,
                    label: 'Document',
                    onTap: () {
                      Navigator.pop(context);
                      widget.chatService.sendMessage(
                        chatId: widget.chat.id,
                        text: 'Project_Specification.pdf',
                        type: MessageType.attachment,
                        attachmentName: 'Project_Specification.pdf',
                        attachmentSize: '2.4 MB',
                      );
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.mic_rounded,
                    color: Colors.amber,
                    label: 'Audio',
                    onTap: () {
                      Navigator.pop(context);
                      widget.chatService.sendMessage(
                        chatId: widget.chat.id,
                        text: 'Voice note recorded',
                        type: MessageType.voice,
                        voiceDuration: const Duration(seconds: 12),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withAlpha(40),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            UserAvatar(user: widget.chat.participant, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.participant.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.chat.participant.status == UserStatus.online
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.chat.participant.status == UserStatus.online
                          ? AppColors.onlineGreen
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.primaryBlueLight),
            onPressed: () {
              widget.callService.startCall(widget.chat.participant, CallType.audio);
              widget.onStartCall();
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.primaryBlueLight),
            onPressed: () {
              widget.callService.startCall(widget.chat.participant, CallType.video);
              widget.onStartCall();
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.chatService,
        builder: (context, _) {
          final messages = widget.chatService.getMessagesForChat(widget.chat.id);

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UserAvatar(user: widget.chat.participant, radius: 36, showStatus: false),
                            const SizedBox(height: 16),
                            Text(
                              'Say hi to ${widget.chat.participant.name}!',
                              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == 'user_current';
                          return MessageBubble(message: msg, isMe: isMe);
                        },
                      ),
              ),
              if (_isRecordingVoice)
                Container(
                  color: AppColors.primaryBlue.withAlpha(30),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: AppColors.missedCallRed),
                      const SizedBox(width: 12),
                      const Text('Recording Voice Note...', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => setState(() => _isRecordingVoice = false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                        onPressed: () {
                          setState(() => _isRecordingVoice = false);
                          widget.chatService.sendMessage(
                            chatId: widget.chat.id,
                            text: 'Voice note',
                            type: MessageType.voice,
                            voiceDuration: const Duration(seconds: 8),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: Theme.of(context).cardTheme.color,
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _showEmoji ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
                          color: AppColors.primaryBlueLight,
                        ),
                        onPressed: () => setState(() => _showEmoji = !_showEmoji),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded, color: AppColors.primaryBlueLight),
                        onPressed: _showAttachmentOptions,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onLongPress: () => setState(() => _isRecordingVoice = true),
                        child: FloatingActionButton.small(
                          onPressed: _sendMessage,
                          child: const Icon(Icons.send_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showEmoji)
                Container(
                  height: 180,
                  color: Theme.of(context).cardTheme.color,
                  child: GridView.count(
                    crossAxisCount: 7,
                    padding: const EdgeInsets.all(12),
                    children: ['👍', '❤️', '😂', '🔥', '🚀', '😍', '🎉', '😊', '🙌', '✨', '👏', '💯', '💙', '⚡']
                        .map((emoji) => InkWell(
                              onTap: () {
                                _inputController.text += emoji;
                              },
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 24)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
