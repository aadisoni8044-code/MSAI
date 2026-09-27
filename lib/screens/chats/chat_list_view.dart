import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/chat_tile.dart';

class ChatListView extends StatefulWidget {
  final String selectedChatId;
  final Function(Chat chat) onChatSelected;

  const ChatListView({
    super.key,
    required this.selectedChatId,
    required this.onChatSelected,
  });

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  String _selectedFilter = 'All';

  List<Chat> _filterChats(List<Chat> allChats) {
    if (_selectedFilter == 'Unread') {
      return allChats.where((c) => c.unreadCount > 0).toList();
    } else if (_selectedFilter == 'Groups') {
      return allChats.where((c) => c.type == ChatType.group).toList();
    }
    return allChats;
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.darkSurfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.darkSurfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start chatting with friends or create a new group.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.newChat),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start New Chat'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = MockService();
    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final filteredChats = _filterChats(service.chats);
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.darkBackground,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Groups'),
                ],
              ),
            ),
            Expanded(
              child: filteredChats.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        return ChatTile(
                          chat: chat,
                          isSelected: widget.selectedChatId == chat.id,
                          onTap: () {
                            service.markChatAsRead(chat.id);
                            widget.onChatSelected(chat);
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      chat.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                                      color: AppColors.primaryBlue,
                                    ),
                                    title: Text(chat.isPinned ? 'Unpin Chat' : 'Pin Chat'),
                                    onTap: () {
                                      service.togglePinChat(chat.id);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      chat.isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                      color: AppColors.primaryBlue,
                                    ),
                                    title: Text(chat.isMuted ? 'Unmute Notifications' : 'Mute Notifications'),
                                    onTap: () {
                                      service.toggleMuteChat(chat.id);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                ],
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
