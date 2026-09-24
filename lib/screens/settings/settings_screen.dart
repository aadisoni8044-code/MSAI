import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/settings_provider.dart';
import '../../models/app_settings.dart';
import '../privacy/privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAiApiKeyDialog(BuildContext context, SettingsProvider settingsProvider) {
    final controller = TextEditingController(text: settingsProvider.settings.aiApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('AI API Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input an API Key (Google Gemini / OpenAI) to connect live external LLM processing:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'AIzaSy...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsProvider.setAiApiKey(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI Key updated successfully.')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AI Web Browser',
      applicationVersion: 'v1.0.0 Pro',
      applicationIcon: const Icon(Icons.blur_on_rounded, size: 40, color: Color(0xFF4F46E5)),
      children: [
        const SizedBox(height: 12),
        const Text(
          'A modern, ultra-fast, privacy-focused web browser built using Dart & Flutter. '
          'Features active tracking protection, AI page summaries, incognito browsing, and high-performance WebViews.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browser Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('Appearance & Theme'),
          ListTile(
            leading: const Icon(Icons.palette_rounded, color: Color(0xFF4F46E5)),
            title: const Text('Theme Mode'),
            subtitle: Text(settings.themeMode.toUpperCase()),
            trailing: DropdownButton<String>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (val) {
                if (val != null) settingsProvider.setThemeMode(val);
              },
            ),
          ),

          const Divider(height: 24),

          _buildHeader('Search Engine'),
          ListTile(
            leading: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5)),
            title: const Text('Default Search Engine'),
            subtitle: Text(settings.searchEngine.name),
            trailing: DropdownButton<SearchEngineOption>(
              value: settings.searchEngine,
              underline: const SizedBox.shrink(),
              items: SearchEngineOption.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (val) {
                if (val != null) settingsProvider.setSearchEngine(val);
              },
            ),
          ),

          const Divider(height: 24),

          _buildHeader('AI Engine Configuration'),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5)),
            title: const Text('AI API Key'),
            subtitle: Text(settings.aiApiKey.isEmpty ? 'Not configured (Using local fallback engine)' : 'API Key Configured'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAiApiKeyDialog(context, settingsProvider),
          ),

          const Divider(height: 24),

          _buildHeader('Privacy & Security'),
          ListTile(
            leading: const Icon(Icons.security_rounded, color: Color(0xFF4F46E5)),
            title: const Text('Privacy, Cookies & Permissions'),
            subtitle: const Text('Manage trackers, site permissions & HTTPS preference'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          ),

          const Divider(height: 24),

          _buildHeader('About & System'),
          ListTile(
            leading: const Icon(Icons.info_rounded, color: Color(0xFF4F46E5)),
            title: const Text('About AI Browser'),
            subtitle: const Text('Version 1.0.0 Pro • Flutter & Dart'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4F46E5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
