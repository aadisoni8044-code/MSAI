import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/browser_provider.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/downloads_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../views/bookmarks_screen.dart';
import '../views/history_screen.dart';
import '../views/downloads_screen.dart';
import '../views/settings_screen.dart';

class BrowserMenuDrawer extends StatelessWidget {
  const BrowserMenuDrawer({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BrowserMenuDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final browser = context.watch<BrowserProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.fireOrange, AppTheme.primaryBlue],
                  ),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Firezip Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          // Menu Options List
          _buildMenuItem(
            context: context,
            icon: Icons.add_to_photos_rounded,
            title: 'New Tab',
            subtitle: 'Open a new browsing tab',
            onTap: () {
              Navigator.pop(context);
              browser.openNewTab();
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.bookmark_rounded,
            title: 'Bookmarks',
            subtitle: 'Saved favorite websites',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.history_rounded,
            title: 'History',
            subtitle: 'View visited pages & search history',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.download_rounded,
            title: 'Downloads',
            subtitle: 'Manage downloaded files',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.devices_rounded,
            title: 'Desktop Site',
            subtitle: 'Request desktop layout',
            trailing: Switch(
              value: browser.currentTab.isDesktopSite,
              activeColor: AppTheme.primaryLightBlue,
              onChanged: (val) {
                browser.toggleDesktopSite();
                Navigator.pop(context);
              },
            ),
            onTap: () {
              browser.toggleDesktopSite();
              Navigator.pop(context);
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.delete_sweep_rounded,
            title: 'Clear Browsing Data',
            subtitle: 'Clear history and cache',
            onTap: () {
              Navigator.pop(context);
              _showClearDataConfirmation(context);
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.settings_rounded,
            title: 'Settings',
            subtitle: 'General, search, privacy & theme',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryLightBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Browsing Data?'),
        content: const Text(
          'This will clear browsing history and downloads list. Bookmarks will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<BrowserProvider>().clearHistory();
              context.read<DownloadsProvider>().clearCompleted();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Browsing data cleared successfully')),
              );
            },
            child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
