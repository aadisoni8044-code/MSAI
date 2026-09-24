import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/browser_provider.dart';
import '../app/settings_provider.dart';
import 'home/home_screen.dart';
import 'browser/browser_screen.dart';
import 'tabs/tabs_screen.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'ai/ai_assistant_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final browserProvider = Provider.of<BrowserProvider>(context);
    final isIncognito = browserProvider.isIncognito;
    final activeTab = browserProvider.activeTab;
    final isViewingPage = activeTab != null && activeTab.url != 'msai://home' && activeTab.url.isNotEmpty;

    // Build current body depending on index
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = isViewingPage ? const BrowserScreen() : const HomeScreen();
        break;
      case 1:
        body = TabsScreen(onTabSelected: () => navigateToTab(0));
        break;
      case 2:
        body = BookmarksScreen(onNavigateUrl: (url) {
          final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
          browserProvider.loadUrlInActiveTab(url, settings.searchEngine);
          navigateToTab(0);
        });
        break;
      case 3:
        body = const AiAssistantScreen();
        break;
      case 4:
        body = const SettingsScreen();
        break;
      default:
        body = const HomeScreen();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: body,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isIncognito
              ? const Color(0xFF1E293B)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: isViewingPage ? Icons.public : Icons.home_rounded,
                  label: isViewingPage ? 'Web' : 'Home',
                  activeColor: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.tab_rounded,
                  label: 'Tabs',
                  badgeCount: browserProvider.tabs.length,
                  activeColor: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.bookmark_rounded,
                  label: 'Bookmarks',
                  activeColor: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI',
                  activeColor: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  activeColor: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
    required Color activeColor,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final unselectedColor = theme.brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[600]!;

    return InkWell(
      onTap: () => navigateToTab(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : unselectedColor,
                  size: 22,
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : unselectedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
