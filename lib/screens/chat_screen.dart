import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/app_text_field.dart';
import '../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProv = context.watch<ChatProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 320,
              child: _buildFriendsList(chatProv, theme),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: chatProv.selectedFriendId != null
                  ? _buildConversationView(chatProv, theme)
                  : const Center(
                      child: Text('Select a friend to start chatting in ZipPro'),
                    ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZipPro Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildFriendsList(chatProv, theme),
    );
  }

  Widget _buildFriendsList(ChatProvider chatProv, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppTextField(
            hintText: 'Search friends...',
            prefixIcon: Icons.search,
            onChanged: chatProv.setSearchQuery,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chatProv.friends.length,
            itemBuilder: (context, index) {
              final friend = chatProv.friends[index];
              final isSelected = chatProv.selectedFriendId == friend.id;

              return ListTile(
                selected: isSelected,
                selectedTileColor: AppTheme.primaryCyan.withOpacity(0.1),
                leading: Stack(
                  children: [
                    ProfileAvatar(imageUrl: friend.avatarUrl, radius: 24),
                    if (friend.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  friend.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  friend.isTyping ? 'typing...' : '@${friend.username}',
                  style: TextStyle(
                    color: friend.isTyping ? AppTheme.primaryCyan : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: friend.isTyping ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                trailing: Text(
                  friend.lastSeen,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
                ),
                onTap: () {
                  chatProv.selectFriend(friend.id);
                  if (MediaQuery.of(context).size.width < 1000) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IndividualChatScreen(friend: friend),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationView(ChatProvider chatProv, ThemeData theme) {
    final friend = chatProv.friends.firstWhere((f) => f.id == chatProv.selectedFriendId);
    final messages = chatProv.getConversation(friend.id);

    return Column(
      children: [
        // Conversation Top Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              ProfileAvatar(imageUrl: friend.avatarUrl, radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    friend.isOnline ? 'Active Now' : friend.lastSeen,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
              IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return MessageBubble(
                message: msg,
                isMe: msg.senderId == 'usr_me',
                onReact: (r) => chatProv.addReaction(msg.id, r),
                onDelete: () => chatProv.deleteMessage(msg.id),
              );
            },
          ),
        ),

        // Bottom Input
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryCyan), onPressed: () {}),
              Expanded(
                child: AppTextField(
                  controller: _msgController,
                  hintText: 'Send a Zip message...',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                onPressed: () {
                  if (_msgController.text.trim().isNotEmpty) {
                    chatProv.sendMessage(
                      receiverId: friend.id,
                      content: _msgController.text.trim(),
                    );
                    _msgController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IndividualChatScreen extends StatefulWidget {
  final Friend friend;

  const IndividualChatScreen({super.key, required this.friend});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();
    final messages = chatProv.getConversation(widget.friend.id);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileAvatar(imageUrl: widget.friend.avatarUrl, radius: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.friend.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  widget.friend.isOnline ? 'Online' : widget.friend.lastSeen,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return MessageBubble(
                  message: msg,
                  isMe: msg.senderId == 'usr_me',
                  onReact: (r) => chatProv.addReaction(msg.id, r),
                  onDelete: () => chatProv.deleteMessage(msg.id),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryCyan), onPressed: () {}),
                Expanded(
                  child: AppTextField(
                    controller: _msgController,
                    hintText: 'Type a message...',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                  onPressed: () {
                    if (_msgController.text.trim().isNotEmpty) {
                      chatProv.sendMessage(
                        receiverId: widget.friend.id,
                        content: _msgController.text.trim(),
                      );
                      _msgController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
