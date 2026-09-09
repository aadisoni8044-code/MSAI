import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auxiliary_providers.dart';
import '../../widgets/user_avatar.dart';
import '../../routes/app_routes.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.search(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search contacts, messages...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                searchProvider.clearSearch();
              },
            ),
        ],
      ),
      body: searchProvider.isSearching
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (searchProvider.searchResultsUsers.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Contacts & Users', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ...searchProvider.searchResultsUsers.map((user) => ListTile(
                        leading: UserAvatar(avatarUrl: user.avatarUrl, name: user.name, radius: 20),
                        title: Text(user.name),
                        subtitle: Text(user.phoneNumber),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.individualChat,
                            arguments: {
                              'chatRoomId': 'chat_room_${user.id}',
                              'title': user.name,
                              'avatarUrl': user.avatarUrl,
                              'receiverId': user.id,
                            },
                          );
                        },
                      )),
                ],
                if (searchProvider.searchResultsMessages.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ...searchProvider.searchResultsMessages.map((msg) => ListTile(
                        leading: const Icon(Icons.message, color: Colors.teal),
                        title: Text(msg.content),
                        subtitle: Text('Status: ${msg.status.name}'),
                      )),
                ],
                if (_searchController.text.isNotEmpty &&
                    searchProvider.searchResultsUsers.isEmpty &&
                    searchProvider.searchResultsMessages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No results found', style: TextStyle(color: Colors.grey, fontSize: 16))),
                  ),
              ],
            ),
    );
  }
}
