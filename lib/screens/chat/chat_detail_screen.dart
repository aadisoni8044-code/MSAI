import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../models/call.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../services/call_service.dart';
import '../../services/media_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/voice_message.dart';
import '../../widgets/user_avatar.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final MediaService _mediaService = MediaService();
  final CallService _callService = WebRtcCallService();
  Message? _replyMessage;
  bool _isRecordingVoice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false).loadMessages(widget.chat.id);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? durationSeconds,
  }) {
    if (content.trim().isEmpty && type == MessageType.text) return;
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) return;

    final msg = Message(
      id: const Uuid().v4(),
      chatId: widget.chat.id,
      senderId: currentUser.id,
      content: content.trim(),
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      durationSeconds: durationSeconds,
      replyToContent: _replyMessage?.content,
      replyToMessageId: _replyMessage?.id,
    );

    Provider.of<MessageProvider>(context, listen: false).sendMessage(msg);
    _textController.clear();
    setState(() {
      _replyMessage = null;
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.pink),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await _mediaService.pickImageFromCamera();
                if (file != null) {
                  _sendMessage(
                    content: 'Photo',
                    type: MessageType.image,
                    mediaUrl: file.path,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.purple),
              title: const Text('Gallery Image'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await _mediaService.pickImageFromGallery();
                if (file != null) {
                  _sendMessage(
                    content: 'Photo',
                    type: MessageType.image,
                    mediaUrl: file.path,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.teal),
              title: const Text('Gallery Video'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await _mediaService.pickVideoFromGallery();
                if (file != null) {
                  _sendMessage(
                    content: 'Video',
                    type: MessageType.video,
                    mediaUrl: file.path,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text('Document'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await _mediaService.pickDocument();
                if (file != null) {
                  _sendMessage(
                    content: file.path.split('/').last,
                    type: MessageType.document,
                    fileName: file.path.split('/').last,
                    fileSize: await file.length(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _initiateCall(CallType type) async {
    final call = await _callService.initiateCall(
      receiverId: widget.chat.id,
      receiverName: widget.chat.name,
      type: type,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${type.name} call with ${widget.chat.name}...'),
        action: SnackBarAction(
          label: 'CANCEL',
          onPressed: () => _callService.endCall(call.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final messageProvider = Provider.of<MessageProvider>(context);
    final messages = messageProvider.getMessages(widget.chat.id);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(name: widget.chat.name, radius: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _initiateCall(CallType.video),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _initiateCall(CallType.voice),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'block') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.chat.name} blocked')),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
              const PopupMenuItem(value: 'block', child: Text('Block user')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages in this chat yet.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      reverse: false,
                      itemCount: messages.length,
                      itemBuilder: (ctx, index) {
                        final msg = messages[index];
                        final isSelf = msg.senderId == currentUser?.id;
                        return MessageBubble(
                          message: msg,
                          isSelf: isSelf,
                          onReply: (m) => setState(() => _replyMessage = m),
                          onDelete: (m) => messageProvider.deleteMessage(widget.chat.id, m.id),
                          onStar: (m) => messageProvider.toggleStarMessage(widget.chat.id, m.id),
                        );
                      },
                    ),
            ),
            if (_replyMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to: ${_replyMessage!.content}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _replyMessage = null),
                    ),
                  ],
                ),
              ),
            if (_isRecordingVoice)
              VoiceRecordBar(
                onSendRecording: (path, duration) {
                  setState(() => _isRecordingVoice = false);
                  _sendMessage(
                    content: 'Voice Message',
                    type: MessageType.audio,
                    mediaUrl: path,
                    durationSeconds: duration,
                  );
                },
                onCancel: () => setState(() => _isRecordingVoice = false),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _showMediaPicker,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isRecordingVoice = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () => _sendMessage(content: _textController.text),
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
