import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/audio_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/voice_recorder_widget.dart';
import '../../widgets/user_avatar.dart';
import '../../models/chat_message_model.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class IndividualChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String title;
  final String avatarUrl;
  final String receiverId;

  const IndividualChatScreen({
    super.key,
    required this.chatRoomId,
    required this.title,
    required this.avatarUrl,
    required this.receiverId,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final _messageController = TextEditingController();
  final MockAudioService _audioService = MockAudioService();
  bool _isRecordingVoice = false;
  ChatMessageModel? _replyingMessage;
  ChatMessageModel? _editingMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.currentUser?.id ?? 'user_me';

    if (_editingMessage != null) {
      chatProvider.editMessage(widget.chatRoomId, _editingMessage!.id, text);
      setState(() => _editingMessage = null);
    } else {
      chatProvider.sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: myId,
        receiverId: widget.receiverId,
        content: text,
        type: MessageType.text,
        replyToMessageId: _replyingMessage?.id,
        replyToContent: _replyingMessage?.content,
        replyToSenderName: _replyingMessage?.senderId == myId ? 'You' : widget.title,
      );
      setState(() => _replyingMessage = null);
    }

    _messageController.clear();
  }

  void _sendVoiceNote(String path, int durationSeconds) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.currentUser?.id ?? 'user_me';

    chatProvider.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: myId,
      receiverId: widget.receiverId,
      content: '🎤 Voice message',
      type: MessageType.voice,
      mediaUrl: path,
      audioDurationSeconds: durationSeconds,
    );

    setState(() => _isRecordingVoice = false);
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: [
              _buildAttachmentItem(Icons.insert_drive_file, Colors.indigo, 'Document', () {
                Navigator.pop(context);
                _sendMockMessage(MessageType.document, content: 'Project_Specification.pdf');
              }),
              _buildAttachmentItem(Icons.camera_alt, Colors.pink, 'Camera', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.cameraMediaPicker);
              }),
              _buildAttachmentItem(Icons.image, Colors.purple, 'Gallery', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.mediaGallery);
              }),
              _buildAttachmentItem(Icons.headset, Colors.orange, 'Audio', () {
                Navigator.pop(context);
                _sendMockMessage(MessageType.audio, content: 'Music Track');
              }),
              _buildAttachmentItem(Icons.location_on, Colors.green, 'Location', () {
                Navigator.pop(context);
                _sendMockMessage(MessageType.location, content: 'San Francisco, CA');
              }),
              _buildAttachmentItem(Icons.person, Colors.blue, 'Contact', () {
                Navigator.pop(context);
                _sendMockMessage(MessageType.contact, content: 'Contact Shared');
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem(IconData icon, Color color, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _sendMockMessage(MessageType type, {required String content}) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.currentUser?.id ?? 'user_me';

    chatProvider.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: myId,
      receiverId: widget.receiverId,
      content: content,
      type: type,
      mediaUrl: type == MessageType.image ? 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=80' : null,
      fileName: type == MessageType.document ? 'Project_Specification.pdf' : null,
      fileSize: 2048000,
      latitude: type == MessageType.location ? 37.7749 : null,
      longitude: type == MessageType.location ? -122.4194 : null,
      contactName: type == MessageType.contact ? 'Sarah Connor' : null,
      contactPhone: type == MessageType.contact ? '+1 555-0101' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final myId = authProvider.currentUser?.id ?? 'user_me';
    final messages = chatProvider.getMessagesForRoom(widget.chatRoomId);
    final isMultiSelect = chatProvider.isMultiSelecting;

    return Scaffold(
      appBar: isMultiSelect
          ? AppBar(
              backgroundColor: AppColors.primaryTealDark,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => chatProvider.clearMessageSelection(),
              ),
              title: Text('${chatProvider.selectedMessageIds.length}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () => chatProvider.toggleStarSelectedMessages(widget.chatRoomId),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => chatProvider.deleteSelectedMessages(widget.chatRoomId),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message copied to clipboard')),
                    );
                    chatProvider.clearMessageSelection();
                  },
                ),
              ],
            )
          : AppBar(
              titleSpacing: 0,
              title: Row(
                children: [
                  UserAvatar(avatarUrl: widget.avatarUrl, name: widget.title, radius: 18),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Online', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'view_contact') {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    } else if (val == 'clear_chat') {
                      chatProvider.getMessagesForRoom(widget.chatRoomId).clear();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view_contact', child: Text('View contact')),
                    const PopupMenuItem(value: 'media', child: Text('Media, links, and docs')),
                    const PopupMenuItem(value: 'search', child: Text('Search')),
                    const PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
                    const PopupMenuItem(value: 'clear_chat', child: Text('Clear chat')),
                  ],
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                reverse: false,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == myId;
                  final isSelected = chatProvider.selectedMessageIds.contains(msg.id);

                  return MessageBubble(
                    message: msg,
                    isMe: isMe,
                    isSelected: isSelected,
                    onTap: () {
                      if (isMultiSelect) {
                        chatProvider.toggleMessageSelection(msg.id);
                      }
                    },
                    onLongPress: () {
                      chatProvider.toggleMessageSelection(msg.id);
                    },
                    onReplyTap: () {
                      setState(() => _replyingMessage = msg);
                    },
                  );
                },
              ),
            ),
            if (_replyingMessage != null || _editingMessage != null) _buildActiveInputHeader(),
            if (_isRecordingVoice)
              VoiceRecorderWidget(
                audioService: _audioService,
                onRecordingComplete: _sendVoiceNote,
                onCancel: () => setState(() => _isRecordingVoice = false),
              )
            else
              _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveInputHeader() {
    final isEditing = _editingMessage != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(isEditing ? Icons.edit : Icons.reply, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editing Message' : 'Replying to Message',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryTeal),
                ),
                Text(
                  isEditing ? _editingMessage!.content : _replyingMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _replyingMessage = null;
                _editingMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: _showAttachmentOptions,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cameraMediaPicker),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          FloatingActionButton.small(
            onPressed: _messageController.text.trim().isEmpty
                ? () => setState(() => _isRecordingVoice = true)
                : _sendMessage,
            backgroundColor: AppColors.accentGreen,
            child: Icon(
              _messageController.text.trim().isEmpty ? Icons.mic : Icons.send,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
