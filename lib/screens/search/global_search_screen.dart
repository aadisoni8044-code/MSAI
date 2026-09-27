import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/chat_tile.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _activeCategoryIndex = 0;

  final List<String> _categories = ['All', 'People', 'Chats', 'Groups', 'Communities', 'Messages'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = MockService();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search people, chats, groups, messages...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: AppColors.iconColor),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _activeCategoryIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.darkSurfaceSecondary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _activeCategoryIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _query.isEmpty
                ? _buildSearchHistory()
                : _buildSearchResults(service),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    final recentSearches = ['Khushi', 'ZIPgram Core Engineers', 'Flutter 3.41', 'Amit'];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Searches',
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        ...recentSearches.map(
          (term) => ListTile(
            leading: const Icon(Icons.history_rounded, color: AppColors.iconColor),
            title: Text(term, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
              onPressed: () {},
            ),
            onTap: () {
              _searchController.text = term;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(MockService service) {
    final filteredChats = service.chats.where((c) {
      return c.name.toLowerCase().contains(_query) ||
          (c.lastMessage?.text.toLowerCase().contains(_query) ?? false);
    }).toList();

    if (filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_query"',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with another keyword or name.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ChatTile(
          chat: chat,
          onTap: () {
            if (chat.type == ChatType.group) {
              Navigator.pushNamed(context, AppRoutes.groupChat, arguments: chat);
            } else {
              Navigator.pushNamed(context, AppRoutes.chat, arguments: chat);
            }
          },
        );
      },
    );
  }
}
