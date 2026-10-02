import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/glass_theme.dart';
import '../providers/navigation_provider.dart';
import 'camera/camera_screen.dart';
import 'chat/chat_screen.dart';
import 'stories/stories_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Landing on Camera (Page 1)
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProv, child) {
        // Sync PageController with NavigationProvider
        if (_pageController.hasClients &&
            _pageController.page?.round() != navProv.currentIndex) {
          _pageController.animateToPage(
            navProv.currentIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            children: [
              // 3-Tab Swipeable View (Chat, Camera, Stories)
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  navProv.setTab(index);
                },
                children: const [
                  ChatScreen(),
                  CameraScreen(),
                  StoriesScreen(),
                ],
              ),

              // Floating Bottom Navigation Bar
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: GlassTheme.glassContainer(
                      height: 64,
                      borderRadius: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Tab 0: Chat
                          _buildNavItem(
                            context: context,
                            index: 0,
                            icon: FontAwesomeIcons.commentDots,
                            label: 'Chat',
                            isSelected: navProv.currentIndex == 0,
                            onTap: () => navProv.goToChat(),
                          ),

                          // Tab 1: Camera
                          _buildNavItem(
                            context: context,
                            index: 1,
                            icon: FontAwesomeIcons.camera,
                            label: 'Camera',
                            isSelected: navProv.currentIndex == 1,
                            isCamera: true,
                            onTap: () => navProv.goToCamera(),
                          ),

                          // Tab 2: Stories
                          _buildNavItem(
                            context: context,
                            index: 2,
                            icon: FontAwesomeIcons.users,
                            label: 'Stories',
                            isSelected: navProv.currentIndex == 2,
                            onTap: () => navProv.goToStories(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isCamera = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppColors.accent, width: 1)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: isCamera ? 20 : 18,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
