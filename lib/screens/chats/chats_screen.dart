import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/group_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final chatRooms = chatProvider.chatRooms;
    final groups = groupProvider.groups;

    if (chatRooms.isEmpty && groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.contacts),
              child: const Text('Start a conversation'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: chatRooms.length + groups.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        if (index < chatRooms.length) {
          final room = chatRooms[index];
          return ListTile(
            leading: UserAvatar(
              avatarUrl: room.avatarUrl,
              name: room.name,
              radius: 26,
            ),
            title: Text(
              room.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              room.lastMessage?.content ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: room.unreadCount > 0 ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
                fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (room.lastMessage != null)
                  Text(
                    DateFormatter.formatTimestamp(room.lastMessage!.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: room.unreadCount > 0 ? AppColors.accentGreen : Colors.grey,
                    ),
                  ),
                const SizedBox(height: 4),
                if (room.unreadCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.accentGreen,
                    child: Text(
                      '${room.unreadCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.individualChat,
                arguments: {
                  'chatRoomId': room.id,
                  'title': room.name,
                  'avatarUrl': room.avatarUrl,
                  'receiverId': room.participantIds.firstWhere((id) => id != 'user_me', orElse: () => ''),
                },
              );
            },
          );
        } else {
          final group = groups[index - chatRooms.length];
          return ListTile(
            leading: UserAvatar(
              avatarUrl: group.avatarUrl,
              name: group.name,
              radius: 26,
            ),
            title: Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'Group • ${group.description}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.group, size: 18, color: Colors.grey),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.groupChat,
                arguments: {
                  'groupId': group.id,
                  'groupName': group.name,
                  'groupAvatarUrl': group.avatarUrl,
                },
              );
            },
          );
        }
      },
    );
  }
}
