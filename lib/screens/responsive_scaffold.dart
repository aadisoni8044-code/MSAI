import 'package:flutter/material.dart';
import '../screens/camera_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/stories_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CameraScreen(),
    ChatScreen(),
    StoriesScreen(),
    DiscoverScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= AppConstants.mobileBreakpoint;

        if (isLargeScreen) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) {
                    setState(() {
                      _currentIndex = idx;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryCyan),
                  indicatorColor: AppTheme.primaryCyan.withOpacity(0.2),
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Icon(Icons.bolt, color: AppTheme.primaryCyan, size: 32),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.camera_alt_outlined),
                      selectedIcon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble),
                      label: Text('Chat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_awesome_mosaic_outlined),
                      selectedIcon: Icon(Icons.auto_awesome_mosaic),
                      label: Text('Stories'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('Discover'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
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
          bottomNavigationBar: BottomNavigation(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) {
              setState(() {
                _currentIndex = idx;
              });
            },
          ),
        );
      },
    );
  }
}
