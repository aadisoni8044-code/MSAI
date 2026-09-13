import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';
import '../theme/app_theme.dart';

class MobileTabSwitcherSheet extends StatelessWidget {
  const MobileTabSwitcherSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const MobileTabSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final browser = context.watch<BrowserProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tab_rounded, color: AppTheme.primaryLightBlue),
                  const SizedBox(width: 10),
                  Text(
                    'Tabs (${browser.tabs.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      browser.closeAllTabs();
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: const Text('Close All'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Tabs Grid View
          Expanded(
            child: GridView.builder(
              itemCount: browser.tabs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final tab = browser.tabs[index];
                final isActive = index == browser.activeTabIndex;

                return InkWell(
                  onTap: () {
                    browser.switchTab(index);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.primaryLightBlue
                            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header with Icon & Close
                        Row(
                          children: [
                            Icon(
                              tab.isHomePage
                                  ? Icons.home_rounded
                                  : Icons.public_rounded,
                              size: 18,
                              color: AppTheme.primaryLightBlue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                tab.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                browser.closeTab(index);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tab.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),

                        // Visual Preview Box
                        Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkBg
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              tab.isHomePage
                                  ? Icons.bolt_rounded
                                  : Icons.web_rounded,
                              size: 32,
                              color: AppTheme.primaryLightBlue.withOpacity(0.5),
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

          const SizedBox(height: 12),

          // Open New Tab Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                browser.openNewTab();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Open New Tab',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
