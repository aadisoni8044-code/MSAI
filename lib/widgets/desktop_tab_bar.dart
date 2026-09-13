import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';
import '../theme/app_theme.dart';

class DesktopTabBar extends StatelessWidget {
  const DesktopTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final browser = context.watch<BrowserProvider>();

    return Container(
      height: 42,
      color: isDark ? AppTheme.darkBg : AppTheme.lightCard,
      child: Row(
        children: [
          // Firezip Brand Icon on Desktop Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.fireOrange, AppTheme.primaryBlue],
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Firezip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),

          // Horizontal Scrollable Tabs List
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: browser.tabs.length,
              itemBuilder: (context, index) {
                final tab = browser.tabs[index];
                final isActive = index == browser.activeTabIndex;

                return GestureDetector(
                  onTap: () => browser.switchTab(index),
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(top: 4, right: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? AppTheme.darkSurface : AppTheme.lightSurface)
                          : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: isActive
                          ? Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        // Top active indicator line
                        if (isActive)
                          Container(
                            height: 2,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryLightBlue,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(
                                  tab.isHomePage
                                      ? Icons.home_rounded
                                      : Icons.public_rounded,
                                  size: 16,
                                  color: isActive
                                      ? AppTheme.primaryLightBlue
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tab.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          isActive ? FontWeight.w600 : FontWeight.normal,
                                      color: isActive
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => browser.closeTab(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
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

          // Add New Tab Button
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 20),
            tooltip: 'New Tab',
            onPressed: () => browser.openNewTab(),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
