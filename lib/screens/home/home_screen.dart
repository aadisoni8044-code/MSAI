import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/zipgram_logo.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../chats/chat_list_view.dart';
import '../status/status_view.dart';
import '../calls/calls_view.dart';
import '../communities/communities_view.dart';
import '../profile/user_profile_screen.dart';
import '../chat/individual_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Chat? _selectedChat;

  void _onChatSelected(Chat chat) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    if (isDesktop) {
      setState(() {
        _selectedChat = chat;
      });
    } else {
      if (chat.type == ChatType.group) {
        Navigator.pushNamed(context, AppRoutes.groupChat, arguments: chat);
      } else {
        Navigator.pushNamed(context, AppRoutes.chat, arguments: chat);
      }
    }
  }

  Widget _buildBody(bool isDesktop) {
    if (isDesktop && _currentIndex == 0) {
      return Row(
        children: [
          SizedBox(
            width: 360,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.dividerColor, width: 0.8),
                ),
              ),
              child: ChatListView(
                selectedChatId: _selectedChat?.id ?? '',
                onChatSelected: _onChatSelected,
              ),
            ),
          ),
          Expanded(
            child: _selectedChat == null
                ? Container(
                    color: AppColors.darkBackground,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ZipgramLogo(size: 64, showText: false),
                          const SizedBox(height: 16),
                          const Text(
                            'ZIPgram for Web & Desktop',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select a conversation to start messaging.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : IndividualChatScreen(
                    chat: _selectedChat!,
                    isEmbedded: true,
                  ),
          ),
        ],
      );
    }

    switch (_currentIndex) {
      case 0:
        return ChatListView(
          selectedChatId: _selectedChat?.id ?? '',
          onChatSelected: _onChatSelected,
        );
      case 1:
        return const StatusView();
      case 2:
        return const CallsView();
      case 3:
        return const CommunitiesView();
      case 4:
        return const UserProfileScreen(isEmbedded: true);
      default:
        return const SizedBox.shrink();
    }
  }

  void _showNewChatMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_rounded, color: AppColors.primaryBlue),
              title: const Text('New Contact / Chat'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.newChat);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_rounded, color: AppColors.primaryBlue),
              title: const Text('New Group'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.newGroup);
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups_rounded, color: AppColors.primaryBlue),
              title: const Text('New Community'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Community Creation opened')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const ZipgramLogo(size: 32, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera feature opened')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            color: AppColors.darkSurface,
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, AppRoutes.settings);
              } else if (value == 'new_group') {
                Navigator.pushNamed(context, AppRoutes.newGroup);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_group',
                child: Text('New group'),
              ),
              const PopupMenuItem(
                value: 'starred',
                child: Text('Starred messages'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(isDesktop),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showNewChatMenu,
              child: const Icon(Icons.message_rounded),
            )
          : null,
    );
  }
}
