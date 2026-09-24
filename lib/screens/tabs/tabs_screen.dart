import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/browser_provider.dart';
import '../../models/tab_item.dart';

class TabsScreen extends StatelessWidget {
  final VoidCallback onTabSelected;

  const TabsScreen({super.key, required this.onTabSelected});

  void _showTabLongPressOptions(BuildContext context, BrowserProvider browserProvider, TabItem tab) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.tab_unselected_rounded),
              title: const Text('Open in New Tab'),
              onTap: () {
                Navigator.pop(ctx);
                browserProvider.createTab(url: tab.url, title: tab.title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_rounded),
              title: const Text('Open in Incognito Tab'),
              onTap: () {
                Navigator.pop(ctx);
                browserProvider.createTab(url: tab.url, title: tab.title, isPrivate: true);
                browserProvider.setIncognitoMode(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: Colors.red),
              title: const Text('Close Tab', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                browserProvider.closeTab(tab.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final browserProvider = Provider.of<BrowserProvider>(context);
    final visibleTabs = browserProvider.tabs;
    final isIncognito = browserProvider.isIncognito;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isIncognito ? 'Private Tabs (${visibleTabs.length})' : 'Tabs (${visibleTabs.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (browserProvider.closedTabs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore_rounded),
              tooltip: 'Restore Recently Closed Tab',
              onPressed: () {
                browserProvider.restoreLastClosedTab();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restored recently closed tab')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Tab',
            onPressed: () {
              browserProvider.createTab();
              onTabSelected();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Normal vs Private Segmented Control
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => browserProvider.setIncognitoMode(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isIncognito
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Normal (${browserProvider.allTabs.where((t) => !t.isPrivate).length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !isIncognito ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => browserProvider.setIncognitoMode(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isIncognito
                            ? const Color(0xFF475569)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off_rounded,
                            size: 16,
                            color: isIncognito ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Private (${browserProvider.allTabs.where((t) => t.isPrivate).length})',
                            style: TextStyle(
                              color: isIncognito ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Grid View of Tab Cards
          Expanded(
            child: visibleTabs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tab_unselected_rounded, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          isIncognito ? 'No Private Tabs Open' : 'No Tabs Open',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            browserProvider.createTab();
                            onTabSelected();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Open New Tab'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: visibleTabs.length,
                    itemBuilder: (context, index) {
                      final tab = visibleTabs[index];
                      final isActive = index == browserProvider.activeTabIndex;

                      return InkWell(
                        onTap: () {
                          browserProvider.selectTab(tab.id);
                          onTabSelected();
                        },
                        onLongPress: () => _showTabLongPressOptions(context, browserProvider, tab),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isIncognito
                                ? const Color(0xFF1E293B)
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? (isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: isActive ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              // Tab Card Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? (isIncognito
                                          ? const Color(0xFF334155)
                                          : theme.colorScheme.primary.withOpacity(0.1))
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      tab.isPrivate
                                          ? Icons.visibility_off_rounded
                                          : (tab.url == 'msai://home' ? Icons.home_rounded : Icons.public_rounded),
                                      size: 16,
                                      color: isIncognito ? const Color(0xFF818CF8) : theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        tab.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => browserProvider.closeTab(tab.id),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),

                              // Tab Thumbnail Preview Simulation
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        tab.url == 'msai://home' ? Icons.blur_on_rounded : Icons.web_rounded,
                                        size: 32,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        tab.url == 'msai://home' ? 'Home Dashboard' : tab.url,
                                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          browserProvider.createTab();
          onTabSelected();
        },
        backgroundColor: isIncognito ? const Color(0xFF475569) : theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Tab'),
      ),
    );
  }
}
