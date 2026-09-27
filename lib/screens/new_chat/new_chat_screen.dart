import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/avatar_widget.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockService();
    final users = service.allUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('6 contacts', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 22),
            ),
            title: const Text('New Group', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.newGroup),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22),
            ),
            title: const Text('New Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Contact dialog opened')),
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
            ),
            title: const Text('New Community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New Community opened')),
              );
            },
          ),
          const Divider(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Contacts on ZIPgram', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ...users.map(
            (user) => ListTile(
              leading: AvatarWidget(
                imageUrl: user.avatarUrl,
                name: user.name,
                radius: 22,
                showOnlineIndicator: false,
              ),
              title: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(user.statusMessage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              onTap: () {
                final chat = service.startOrCreateChatWithUser(user);
                Navigator.pushReplacementNamed(context, AppRoutes.chat, arguments: chat);
              },
            ),
          ),
        ],
      ),
    );
  }
}
