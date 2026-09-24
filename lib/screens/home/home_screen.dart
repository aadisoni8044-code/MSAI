import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/browser_provider.dart';
import '../../app/settings_provider.dart';
import '../history/history_screen.dart';
import '../downloads/downloads_screen.dart';
import '../main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _frequentlyVisited = [
    {'name': 'Google', 'url': 'https://google.com', 'icon': 'G'},
    {'name': 'Wikipedia', 'url': 'https://wikipedia.org', 'icon': 'W'},
    {'name': 'YouTube', 'url': 'https://youtube.com', 'icon': 'Y'},
    {'name': 'GitHub', 'url': 'https://github.com', 'icon': 'GH'},
    {'name': 'Reddit', 'url': 'https://reddit.com', 'icon': 'R'},
    {'name': 'Flutter Dev', 'url': 'https://flutter.dev', 'icon': 'F'},
    {'name': 'BBC News', 'url': 'https://bbc.com', 'icon': 'B'},
    {'name': 'TechCrunch', 'url': 'https://techcrunch.com', 'icon': 'TC'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isEmpty) return;
    final browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    browserProvider.loadUrlInActiveTab(value, settingsProvider.settings.searchEngine);
  }

  void _showVoiceSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.mic_rounded, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Voice Search'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                size: 48,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Listening... Speak your query or URL',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _searchController.text = 'Flutter Web Development';
              _onSearchSubmitted('Flutter Web Development');
            },
            child: const Text('Simulate Voice Query'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQrScannerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF4F46E5)),
                SizedBox(width: 8),
                Text(
                  'QR Code Scanner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4F46E5), width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.04),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.center_focus_strong_rounded, size: 48, color: Color(0xFF4F46E5)),
                  SizedBox(height: 8),
                  Text('Align QR code inside frame', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _searchController.text = 'https://flutter.dev';
                _onSearchSubmitted('https://flutter.dev');
              },
              child: const Text('Scan Sample QR Code (flutter.dev)'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final browserProvider = Provider.of<BrowserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isIncognito = browserProvider.isIncognito;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // Header Logo & Private Mode Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isIncognito
                            ? [const Color(0xFF475569), const Color(0xFF1E293B)]
                            : [const Color(0xFF4F46E5), const Color(0xFF818CF8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isIncognito
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF4F46E5))
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.blur_on_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI BROWSER',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isIncognito ? const Color(0xFF94A3B8) : theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        isIncognito ? 'Incognito Mode Active' : 'Next-Gen Web Suite',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Incognito Toggle Switch
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isIncognito
                      ? const Color(0xFF334155)
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                ),
                icon: Icon(
                  isIncognito ? Icons.visibility_off_rounded : Icons.security_rounded,
                  color: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                ),
                tooltip: isIncognito ? 'Exit Incognito' : 'Enter Incognito',
                onPressed: () {
                  browserProvider.setIncognitoMode(!isIncognito);
                },
              )
            ],
          ),

          const SizedBox(height: 28),

          // Search / Address Bar Widget
          Container(
            decoration: BoxDecoration(
              color: isIncognito
                  ? const Color(0xFF1E293B)
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isIncognito
                    ? const Color(0xFF475569)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: isIncognito ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Search or enter website URL...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_rounded, size: 20),
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  onPressed: _showVoiceSearchDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  onPressed: _showQrScannerModal,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Shortcut Actions Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShortcutButton(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              _buildShortcutButton(
                icon: Icons.bookmark_rounded,
                label: 'Bookmarks',
                onTap: () {
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  navState?.navigateToTab(2);
                },
              ),
              _buildShortcutButton(
                icon: Icons.download_rounded,
                label: 'Downloads',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                  );
                },
              ),
              _buildShortcutButton(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Assistant',
                onTap: () {
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  navState?.navigateToTab(3);
                },
              ),
              _buildShortcutButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () {
                  final navState = context.findAncestorStateOfType<MainNavigationScreenState>();
                  navState?.navigateToTab(4);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Frequently Visited Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frequently Visited',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              Text(
                'Engine: ${settingsProvider.settings.searchEngine.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4x2 Grid of Frequently Visited Web Sites
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _frequentlyVisited.length,
            itemBuilder: (context, index) {
              final site = _frequentlyVisited[index];
              return InkWell(
                onTap: () {
                  browserProvider.loadUrlInActiveTab(
                    site['url']!,
                    settingsProvider.settings.searchEngine,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          site['icon']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      site['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Privacy Feature Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF818CF8).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF4F46E5), size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tracking Protection Enabled',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Blocking trackers, cookies, and fingerprinting for safe browsing.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
