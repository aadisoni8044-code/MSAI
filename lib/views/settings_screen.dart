import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/browser_provider.dart';
import '../providers/downloads_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.settings_rounded, color: AppTheme.primaryLightBlue),
            SizedBox(width: 10),
            Text('Settings'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance', Icons.palette_rounded),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_medium_rounded),
                    title: const Text('Theme Mode'),
                    subtitle: Text(
                      settings.themeMode == ThemeMode.dark
                          ? 'Dark Mode (Premium Charcoal & Blue)'
                          : settings.themeMode == ThemeMode.light
                              ? 'Light Mode (Clean Slate & Blue)'
                              : 'System Default',
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: settings.themeMode,
                      underline: const SizedBox(),
                      onChanged: (mode) {
                        if (mode != null) settings.setThemeMode(mode);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Engine Section
            _buildSectionHeader('Search Engine', Icons.search_rounded),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.travel_explore_rounded),
                    title: const Text('Default Search Engine'),
                    subtitle: Text(
                      'Currently using ${settings.searchEngine.name}',
                    ),
                    trailing: DropdownButton<SearchEngine>(
                      value: settings.searchEngine,
                      underline: const SizedBox(),
                      onChanged: (engine) {
                        if (engine != null) settings.setSearchEngine(engine);
                      },
                      items: SearchEngine.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // General & Homepage Section
            _buildSectionHeader('General & Homepage', Icons.home_rounded),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: const Text('Homepage URL'),
                    subtitle: Text(settings.homepageUrl),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _showEditHomepageDialog(context, settings),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.desktop_windows_rounded),
                    title: const Text('Always Request Desktop Site'),
                    subtitle: const Text('Open websites in desktop view by default'),
                    value: settings.defaultDesktopMode,
                    activeColor: AppTheme.primaryLightBlue,
                    onChanged: (val) => settings.setDefaultDesktopMode(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Privacy & Security Section
            _buildSectionHeader('Privacy & Security', Icons.shield_rounded),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.block_rounded),
                    title: const Text('Block Annoying Popups & Ads'),
                    subtitle: const Text('Enhanced speed and tracking protection'),
                    value: settings.blockAds,
                    activeColor: AppTheme.primaryLightBlue,
                    onChanged: (val) => settings.setBlockAds(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                    title: const Text('Clear Browsing Data'),
                    subtitle: const Text('Remove browsing history and downloads'),
                    onTap: () => _showClearDataConfirmation(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Firezip Section
            _buildSectionHeader('About Firezip', Icons.info_outline_rounded),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppTheme.fireOrange, AppTheme.primaryBlue],
                            ),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Firezip Web Browser',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Version 1.0.0 • Clean Dart/Flutter Engine',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Firezip is built to deliver lighting fast, secure, and responsive web browsing across mobile, tablet, and desktop devices.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryLightBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHomepageDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.homepageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Homepage'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'firezip://home or https://...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => settings.setHomepageUrl('firezip://home'),
            child: const Text('Reset Default'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                settings.setHomepageUrl(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Browsing Data?'),
        content: const Text(
          'This action will clear your browsing history and downloaded files list.',
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
