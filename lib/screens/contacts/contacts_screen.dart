import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auxiliary_providers.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../routes/app_routes.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (userProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select contact')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final contacts = userProvider.contacts;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select contact', style: TextStyle(fontSize: 18)),
            Text('${contacts.length} contacts', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.pushNamed(context, AppRoutes.search)),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.group_add, color: Colors.white),
            ),
            title: const Text('New group', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select contacts to add to new group')),
              );
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            title: const Text('New contact', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.qr_code, color: Colors.grey),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Contacts on MSAI Chat',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ...contacts.map((user) {
            return ListTile(
              leading: UserAvatar(
                avatarUrl: user.avatarUrl,
                name: user.name,
                radius: 22,
                isOnline: user.isOnline,
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user.about, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () async {
                final room = await chatProvider.getOrCreateDirectChat(user.id);
                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.individualChat,
                    arguments: {
                      'chatRoomId': room.id,
                      'title': user.name,
                      'avatarUrl': user.avatarUrl,
                      'receiverId': user.id,
                    },
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
