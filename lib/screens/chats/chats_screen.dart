import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<ChatProvider>(context, listen: false).loadChats(user.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showChatOptions(Chat chat) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(chat.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(chat.isPinned ? 'Unpin chat' : 'Pin chat'),
              onTap: () {
                Navigator.pop(ctx);
                chatProvider.togglePin(chat.id);
              },
            ),
            ListTile(
              leading: Icon(chat.isMuted ? Icons.volume_up : Icons.volume_off),
              title: Text(chat.isMuted ? 'Unmute notifications' : 'Mute notifications'),
              onTap: () {
                Navigator.pop(ctx);
                chatProvider.toggleMute(chat.id);
              },
            ),
            ListTile(
              leading: Icon(chat.isArchived ? Icons.unarchive : Icons.archive),
              title: Text(chat.isArchived ? 'Unarchive chat' : 'Archive chat'),
              onTap: () {
                Navigator.pop(ctx);
                chatProvider.toggleArchive(chat.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    if (chatProvider.isLoading) {
      return const LoadingView(message: 'Loading chats...');
    }

    if (chatProvider.errorMessage != null) {
      return ErrorView(
        errorMessage: chatProvider.errorMessage!,
        onRetry: () {
          if (currentUser != null) {
            chatProvider.loadChats(currentUser.id);
          }
        },
      );
    }

    final activeChats = chatProvider.chats.where((c) => !c.isArchived).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search chats or messages...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            onChanged: (val) {
              chatProvider.setSearchQuery(val);
            },
          ),
        ),
        Expanded(
          child: activeChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the button below to start messaging',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: activeChats.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (ctx, index) {
                    final chat = activeChats[index];
                    return ChatTile(
                      chat: chat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(chat: chat),
                          ),
                        );
                      },
                      onLongPress: () => _showChatOptions(chat),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
