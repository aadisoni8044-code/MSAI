import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final MockService _mockService = MockService();

  @override
  Widget build(BuildContext context) {
    final users = _mockService.users;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${users.length} contacts', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.group_add_rounded, color: Colors.white),
            ),
            title: const Text('New Group', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              // Open new group dialog or screen
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_add_rounded, color: Colors.white),
            ),
            title: const Text('New Contact', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            onTap: () {},
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.groups_rounded, color: Colors.white),
            ),
            title: const Text('New Community', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Contacts on ZipGram', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ...users.map((user) {
            return ListTile(
              leading: Avatar(imageUrl: user.avatarUrl, radius: 22, isOnline: user.isOnline, showOnlineIndicator: true),
              title: Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text(user.about, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                final chat = _mockService.createOrGetChatWithUser(user);
                Navigator.pop(context, chat);
              },
            );
          }),
        ],
      ),
    );
  }
}
