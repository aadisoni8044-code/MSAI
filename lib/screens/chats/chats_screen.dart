import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../widgets/chat_tile.dart';
import '../chat/chat_screen.dart';
import 'new_chat_screen.dart';
import '../search/global_search_screen.dart';

class ChatsScreen extends StatefulWidget {
  final Function(Chat chat)? onChatSelected;

  const ChatsScreen({super.key, this.onChatSelected});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final MockService _mockService = MockService();
  String _activeFilter = 'All'; // All, Unread, Groups

  @override
  void initState() {
    super.initState();
    _mockService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _mockService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<Chat> get _filteredChats {
    final chats = _mockService.chats;
    if (_activeFilter == 'Unread') {
      return chats.where((c) => c.unreadCount > 0).toList();
    } else if (_activeFilter == 'Groups') {
      return chats.where((c) => c.isGroup).toList();
    }
    return chats;
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filteredChats;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('ZIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.black, fontSize: 16)),
            ),
            const SizedBox(width: 6),
            const Text('gram', style: TextStyle(color: AppColors.primaryLight, fontSize: 20, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchScreen()));
            },
          ),
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Unread'),
                _buildFilterChip('Groups'),
              ],
            ),
          ),
          Expanded(
            child: chats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.forum_outlined, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          _activeFilter == 'All'
                              ? 'No conversations yet'
                              : 'No ${_activeFilter.toLowerCase()} chats',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: chats.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 70,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ChatTile(
                        chat: chat,
                        onTap: () {
                          if (widget.onChatSelected != null) {
                            widget.onChatSelected!(chat);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chat: chat),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedChat = await Navigator.push<Chat>(
            context,
            MaterialPageRoute(builder: (_) => const NewChatScreen()),
          );
          if (selectedChat != null && mounted) {
            if (widget.onChatSelected != null) {
              widget.onChatSelected!(selectedChat);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(chat: selectedChat)),
              );
            }
          }
        },
        child: const Icon(Icons.message_rounded),
      ),
    );
  }
}
