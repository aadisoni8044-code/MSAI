import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/avatar_widget.dart';

class GroupInfoScreen extends StatelessWidget {
  final Chat chat;

  const GroupInfoScreen({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: AvatarWidget(
              imageUrl: chat.avatarUrl,
              name: chat.name,
              radius: 50,
              showOnlineIndicator: false,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              chat.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Group • ${chat.groupMembers.length} participants',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Members',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ...chat.groupMembers.map(
            (user) => ListTile(
              leading: AvatarWidget(
                imageUrl: user.avatarUrl,
                name: user.name,
                radius: 20,
                showOnlineIndicator: false,
              ),
              title: Text(user.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(user.statusMessage, style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
