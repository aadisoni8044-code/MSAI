import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/reply_preview.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().setActivePeer(widget.peerId);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    _textController.clear();
    context.read<ChatProvider>().sendMessage(
          recipientId: widget.peerId,
          text: text,
        );

    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final btProvider = context.watch<BluetoothProvider>();

    final messages = chatProvider.getMessagesForPeer(widget.peerId);
    final isDeviceConnected = btProvider.connectedDevices.any((d) => d.id == widget.peerId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.peerName.characters.first.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDeviceConnected
                              ? AppColors.connected
                              : AppColors.disconnected,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isDeviceConnected ? 'Bluetooth Connected' : 'Offline / Nearby',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDeviceConnected
                              ? AppColors.connected
                              : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPeerInfoDialog(context, isDeviceConnected),
            tooltip: 'Connection Info',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                chatProvider.clearChatHistory(widget.peerId);
              } else if (value == 'block') {
                btProvider.blockDevice(widget.peerId);
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat history'),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block device'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Bluetooth Connection Status Banner if Disconnected
          if (!isDeviceConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warning.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_disabled,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Bluetooth connection inactive. Tap to reconnect.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ),
                  TextButton(
                    onPressed: () => btProvider.connectDevice(widget.peerId),
                    child: const Text('CONNECT'),
                  ),
                ],
              ),
            ),

          // Messages Stream View
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Send a message to start offline Bluetooth chat',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      final isMe = msg.senderId == 'user_local_me';
                      return ChatBubble(
                        message: msg,
                        isMe: isMe,
                        onReply: (m) => chatProvider.setReplyTo(m),
                        onDelete: (id) =>
                            chatProvider.deleteMessage(widget.peerId, id),
                        onReact: (id, reaction) =>
                            chatProvider.addReaction(widget.peerId, id, reaction),
                      );
                    },
                  ),
          ),

          // Reply Preview if replying
          if (chatProvider.replyingToMessage != null)
            ReplyPreview(
              message: chatProvider.replyingToMessage!,
              onCancel: () => chatProvider.setReplyTo(null),
            ),

          // Message Composer Input Box
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: AppColors.primaryLight),
                    onPressed: () {
                      _textController.text += ' 😊';
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Type an offline message...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPeerInfoDialog(BuildContext context, bool isConnected) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(widget.peerName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Text('Device ID: ${widget.peerId}'),
              const SizedBox(height: 8),
              Text(
                'Status: ${isConnected ? "Connected over Bluetooth" : "Disconnected"}',
              ),
              const SizedBox(height: 8),
              const Text('Protocol: ZIPGRAM Offline Nearby Peer-to-Peer'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
