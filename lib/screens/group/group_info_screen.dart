import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';

class GroupInfoScreen extends StatelessWidget {
  final Chat chat;

  const GroupInfoScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final mockService = MockService();
    final members = mockService.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Avatar(imageUrl: chat.avatarUrl, radius: 50, isGroup: true),
            const SizedBox(height: 12),
            Text(chat.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${chat.memberIds.length > 0 ? chat.memberIds.length : members.length + 1} members',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        chat.groupDescription ?? 'No description provided.',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                    title: const Text('Mute Notifications', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: chat.isMuted,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        mockService.toggleMuteChat(chat.id);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline_rounded, color: AppColors.textPrimary),
                    title: const Text('Starred Messages', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Group Members', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: Avatar(imageUrl: member.avatarUrl, radius: 20),
                  title: Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(member.about, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: index == 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withAlpha(40), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Admin', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
