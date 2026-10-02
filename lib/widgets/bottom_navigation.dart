import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: theme.brightness == Brightness.dark
          ? AppTheme.darkCard
          : AppTheme.lightCard,
      indicatorColor: AppTheme.primaryCyan.withOpacity(0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.camera_alt_outlined),
          selectedIcon: Icon(Icons.camera_alt, color: AppTheme.primaryCyan),
          label: 'Camera',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.primaryCyan),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_mosaic_outlined),
          selectedIcon: Icon(Icons.auto_awesome_mosaic, color: AppTheme.primaryCyan),
          label: 'Stories',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore, color: AppTheme.primaryCyan),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppTheme.primaryCyan),
          label: 'Profile',
        ),
      ],
    );
  }
}
