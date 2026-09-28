import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../widgets/custom_bottom_navigation.dart';
import '../chats/chats_screen.dart';
import '../chat/chat_screen.dart';
import '../chat/desktop_chat_placeholder.dart';
import '../status/status_screen.dart';
import '../calls/calls_screen.dart';
import '../communities/communities_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Chat? _selectedDesktopChat;

  final List<Widget> _screens = const [
    ChatsScreen(),
    StatusScreen(),
    CallsScreen(),
    CommunitiesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    if (isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            // Left sidebar navigation
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
              unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.asset('assets/images/zipgram_logo.png', width: 36, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 32),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: Text('Chats'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.circle_outlined),
                  selectedIcon: Icon(Icons.motion_photos_on_rounded),
                  label: Text('Status'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.phone_outlined),
                  selectedIcon: Icon(Icons.phone_rounded),
                  label: Text('Calls'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups_rounded),
                  label: Text('Communities'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            // Middle section (Current main tab screen)
            SizedBox(
              width: 380,
              child: _currentIndex == 0
                  ? ChatsScreen(
                      onChatSelected: (chat) {
                        setState(() {
                          _selectedDesktopChat = chat;
                        });
                      },
                    )
                  : _screens[_currentIndex],
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            // Right detail pane for split view
            Expanded(
              child: _currentIndex == 0
                  ? (_selectedDesktopChat != null
                      ? ChatScreen(
                          key: ValueKey(_selectedDesktopChat!.id),
                          chat: _selectedDesktopChat!,
                        )
                      : const DesktopChatPlaceholder())
                  : _screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
