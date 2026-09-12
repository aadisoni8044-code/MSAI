import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class ChatsTab extends StatefulWidget {
  final ChatService chatService;
  final Function(Chat) onChatSelected;
  final VoidCallback onNewChatPressed;

  const ChatsTab({
    super.key,
    required this.chatService,
    required this.onChatSelected,
    required this.onNewChatPressed,
  });

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.chatService,
      builder: (context, _) {
        final allChats = widget.chatService.chats;
        final filteredChats = allChats.where((chat) {
          final query = _searchQuery.toLowerCase();
          final matchesName = chat.participant.name.toLowerCase().contains(query);
          final matchesMsg = chat.lastMessage?.content.toLowerCase().contains(query) ?? false;
          return matchesName || matchesMsg;
        }).toList();

        // Sort pinned chats to top
        filteredChats.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return 0;
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search chats or messages...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlueLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: filteredChats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty ? Icons.chat_bubble_outline_rounded : Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textSecondaryDark.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No conversations yet' : 'No results found',
                            style: const TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) => const Divider(indent: 72, height: 1),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final lastMsg = chat.lastMessage;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: UserAvatar(user: chat.participant, radius: 26),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chat.participant.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (chat.isPinned) ...[
                                const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.primaryBlueLight),
                                const SizedBox(width: 4),
                              ],
                              if (lastMsg != null)
                                Text(
                                  _formatTime(lastMsg.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: chat.unreadCount > 0
                                        ? AppColors.primaryBlueLight
                                        : AppColors.textSecondaryDark,
                                    fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.isTyping
                                        ? 'typing...'
                                        : (lastMsg?.content ?? 'No messages yet'),
                                    style: TextStyle(
                                      color: chat.isTyping
                                          ? AppColors.accentCyan
                                          : (chat.unreadCount > 0
                                              ? Theme.of(context).textTheme.bodyMedium?.color
                                              : AppColors.textSecondaryDark),
                                      fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                      fontStyle: chat.isTyping ? FontStyle.italic : FontStyle.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (chat.unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${chat.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () {
                            widget.chatService.markChatAsRead(chat.id);
                            widget.onChatSelected(chat);
                          },
                          onLongPress: () {
                            widget.chatService.togglePinChat(chat.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(chat.isPinned ? 'Chat unpinned' : 'Chat pinned'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
