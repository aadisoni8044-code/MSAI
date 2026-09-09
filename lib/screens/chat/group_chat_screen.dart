import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/user_avatar.dart';
import '../../models/chat_message_model.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAvatarUrl;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupAvatarUrl,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false).loadGroupMessages(widget.groupId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.currentUser?.id ?? 'user_me';

    groupProvider.sendGroupMessage(
      groupId: widget.groupId,
      senderId: myId,
      content: text,
      type: MessageType.text,
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final myId = authProvider.currentUser?.id ?? 'user_me';
    final messages = groupProvider.getMessagesForGroup(widget.groupId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.groupInfo,
              arguments: {'groupId': widget.groupId},
            );
          },
          child: Row(
            children: [
              UserAvatar(avatarUrl: widget.groupAvatarUrl, name: widget.groupName, radius: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.groupName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Tap for group info', style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ],
          ),
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
              if (val == 'group_info') {
                Navigator.pushNamed(context, AppRoutes.groupInfo, arguments: {'groupId': widget.groupId});
              } else if (val == 'mute') {
                groupProvider.toggleMuteGroup(widget.groupId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'group_info', child: Text('Group info')),
              const PopupMenuItem(value: 'group_media', child: Text('Group media')),
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
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
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == myId;

                  return MessageBubble(
                    message: msg,
                    isMe: isMe,
                  );
                },
              ),
            ),
            Container(
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
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.grey),
                            onPressed: () {},
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
                    onPressed: _sendMessage,
                    backgroundColor: AppColors.accentGreen,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
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
