import 'package:flutter/material.dart';
import '../core/utils/responsive.dart';
import '../core/constants/app_colors.dart';
import 'zipgram_logo.dart';

class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationIndexChanged;
  final Widget body;
  final Widget? desktopSecondaryBody;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationIndexChanged,
    required this.body,
    this.desktopSecondaryBody,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.desktop) {
          return _buildDesktopLayout(context);
        } else if (deviceType == DeviceType.tablet) {
          return _buildTabletLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: title != null || actions != null
          ? AppBar(
              title: title ?? const ZipgramLogo(size: 28),
              actions: actions,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavigationIndexChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_searching),
            activeIcon: Icon(Icons.bluetooth),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            activeIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onNavigationIndexChanged,
            labelType: NavigationRailLabelType.selected,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ZipgramLogo(size: 32, style: ZipgramLogoStyle.iconOnly),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chats'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bluetooth_searching),
                selectedIcon: Icon(Icons.bluetooth),
                label: Text('Nearby'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.contacts_outlined),
                selectedIcon: Icon(Icons.contacts),
                label: Text('Contacts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Scaffold(
              appBar: title != null || actions != null
                  ? AppBar(
                      title: title,
                      actions: actions,
                    )
                  : null,
              body: body,
              floatingActionButton: floatingActionButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar Navigation
          Container(
            width: 250,
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: ZipgramLogo(size: 32, showTagline: false),
                ),
                const SizedBox(height: 32),
                _buildDesktopNavItem(
                  context,
                  index: 0,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Chats',
                ),
                _buildDesktopNavItem(
                  context,
                  index: 1,
                  icon: Icons.bluetooth_searching,
                  activeIcon: Icons.bluetooth,
                  label: 'Nearby Devices',
                ),
                _buildDesktopNavItem(
                  context,
                  index: 2,
                  icon: Icons.contacts_outlined,
                  activeIcon: Icons.contacts,
                  label: 'Contacts',
                ),
                _buildDesktopNavItem(
                  context,
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Nearby Active',
                    style: TextStyle(color: AppColors.connected, fontSize: 12),
                  ),
                  onTap: () {
                    // Quick view profile
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Area
          Expanded(
            flex: desktopSecondaryBody != null ? 2 : 3,
            child: Scaffold(
              appBar: title != null || actions != null
                  ? AppBar(
                      title: title,
                      actions: actions,
                    )
                  : null,
              body: body,
              floatingActionButton: floatingActionButton,
            ),
          ),
          if (desktopSecondaryBody != null) ...[
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              flex: 3,
              child: desktopSecondaryBody!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onNavigationIndexChanged(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.primaryLight : theme.textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryLight : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
