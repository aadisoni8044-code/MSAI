import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chat_tile.dart';
import '../chat/chat_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final MockService _mockService = MockService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase().trim();
    final matchingChats = _mockService.chats.where((c) => c.name.toLowerCase().contains(query)).toList();
    final matchingUsers = _mockService.users.where((u) => u.name.toLowerCase().contains(query) || u.username.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search chats, people, messages...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_rounded, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('Search ZipGram', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Find contacts, messages, groups and channels', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            )
          : (matchingChats.isEmpty && matchingUsers.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No results found for "$_query"', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    if (matchingChats.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Chats & Groups', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      ...matchingChats.map((chat) => ChatTile(
                            chat: chat,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
                              );
                            },
                          )),
                    ],
                    if (matchingUsers.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('People', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      ...matchingUsers.map((user) => ListTile(
                            leading: Avatar(imageUrl: user.avatarUrl, radius: 22),
                            title: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Text('@${user.username} • ${user.about}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1),
                            onTap: () {
                              final chat = _mockService.createOrGetChatWithUser(user);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
                              );
                            },
                          )),
                    ],
                  ],
                ),
    );
  }
}
