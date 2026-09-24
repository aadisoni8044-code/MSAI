import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/settings_provider.dart';
import '../../app/history_provider.dart';
import '../../app/bookmarks_provider.dart';
import '../../app/downloads_provider.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  void _showClearDataDialog(BuildContext context) {
    bool clearHistory = true;
    bool clearBookmarks = false;
    bool clearDownloads = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.delete_forever_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Clear Browsing Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Browsing History'),
                value: clearHistory,
                onChanged: (val) => setDialogState(() => clearHistory = val ?? false),
              ),
              CheckboxListTile(
                title: const Text('Saved Bookmarks'),
                value: clearBookmarks,
                onChanged: (val) => setDialogState(() => clearBookmarks = val ?? false),
              ),
              CheckboxListTile(
                title: const Text('Download History'),
                value: clearDownloads,
                onChanged: (val) => setDialogState(() => clearDownloads = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (clearHistory) {
                  Provider.of<HistoryProvider>(context, listen: false).clearAllHistory();
                }
                if (clearBookmarks) {
                  final bp = Provider.of<BookmarksProvider>(context, listen: false);
                  for (var item in bp.bookmarks) {
                    bp.deleteBookmark(item.id);
                  }
                }
                if (clearDownloads) {
                  Provider.of<DownloadsProvider>(context, listen: false).clearAllDownloads();
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected browsing data cleared.')),
                );
              },
              child: const Text('Clear Now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Tracking & Security Shield'),
          SwitchListTile(
            secondary: const Icon(Icons.shield_rounded, color: Color(0xFF4F46E5)),
            title: const Text('Tracking Protection'),
            subtitle: const Text('Block third-party tracking scripts & digital fingerprinting'),
            value: settings.trackingProtection,
            onChanged: (val) => settingsProvider.setTrackingProtection(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cookie_rounded, color: Color(0xFF4F46E5)),
            title: const Text('Block Third-Party Cookies'),
            subtitle: const Text('Prevent websites from storing cross-site tracking cookies'),
            value: settings.blockCookies,
            onChanged: (val) => settingsProvider.setBlockCookies(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock_rounded, color: Color(0xFF4F46E5)),
            title: const Text('HTTPS-Only Mode'),
            subtitle: const Text('Automatically upgrade HTTP requests to secure HTTPS'),
            value: settings.httpsOnly,
            onChanged: (val) => settingsProvider.setHttpsOnly(val),
          ),

          const Divider(height: 32),

          _buildSectionHeader('Website Permissions'),
          SwitchListTile(
            secondary: const Icon(Icons.videocam_rounded),
            title: const Text('Camera Access'),
            value: settings.cameraPermissionAllowed,
            onChanged: (val) => settingsProvider.setPermission('camera', val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.mic_rounded),
            title: const Text('Microphone Access'),
            value: settings.micPermissionAllowed,
            onChanged: (val) => settingsProvider.setPermission('mic', val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.location_on_rounded),
            title: const Text('Location Access'),
            value: settings.locationPermissionAllowed,
            onChanged: (val) => settingsProvider.setPermission('location', val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_rounded),
            title: const Text('Web Notifications'),
            value: settings.notificationPermissionAllowed,
            onChanged: (val) => settingsProvider.setPermission('notification', val),
          ),

          const Divider(height: 32),

          _buildSectionHeader('Platform Privacy Limitations'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF4F46E5)),
                      SizedBox(width: 8),
                      Text('WebRTC & Native Sandbox Info', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Underlying Android/iOS WebKit platforms sandbox WebRTC IP exposure at the OS system level. '
                    'Incognito mode isolated storage ensures zero persistent cookie residue upon tab exit.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _showClearDataDialog(context),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Clear Browsing Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4F46E5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
