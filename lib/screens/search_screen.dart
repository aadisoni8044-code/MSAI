import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/contact_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class SearchScreen extends StatefulWidget {
  final ChatService chatService;
  final ContactService contactService;
  final Function(Chat) onChatSelected;

  const SearchScreen({
    super.key,
    required this.chatService,
    required this.contactService,
    required this.onChatSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryLower = _query.trim().toLowerCase();

    final matchingChats = queryLower.isEmpty
        ? <Chat>[]
        : widget.chatService.chats.where((c) {
            final nameMatch = c.participant.name.toLowerCase().contains(queryLower);
            final msgMatch = c.lastMessage?.content.toLowerCase().contains(queryLower) ?? false;
            return nameMatch || msgMatch;
          }).toList();

    final matchingContacts = queryLower.isEmpty
        ? <User>[]
        : widget.contactService.contacts
            .map((item) => item.user)
            .where((u) => u.name.toLowerCase().contains(queryLower) || u.username.toLowerCase().contains(queryLower))
            .toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search chats, messages & contacts...',
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlueLight),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondaryDark),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 64, color: AppColors.textSecondaryDark.withAlpha(80)),
                  const SizedBox(height: 12),
                  const Text('Type to search across ZIPGRAM', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
                ],
              ),
            )
          : (matchingChats.isEmpty && matchingContacts.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondaryDark.withAlpha(80)),
                      const SizedBox(height: 12),
                      Text('No results found for "$_query"', style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    if (matchingChats.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text('CONVERSATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight, letterSpacing: 1.0)),
                      ),
                      ...matchingChats.map((chat) => ListTile(
                            leading: UserAvatar(user: chat.participant, radius: 22),
                            title: Text(chat.participant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(chat.lastMessage?.content ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onChatSelected(chat);
                            },
                          )),
                    ],
                    if (matchingContacts.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text('CONTACTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight, letterSpacing: 1.0)),
                      ),
                      ...matchingContacts.map((user) => ListTile(
                            leading: UserAvatar(user: user, radius: 22),
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('@${user.username}'),
                            onTap: () {
                              final chat = widget.chatService.startNewChatWithUser(user);
                              Navigator.pop(context);
                              widget.onChatSelected(chat);
                            },
                          )),
                    ],
                  ],
                ),
    );
  }
}
