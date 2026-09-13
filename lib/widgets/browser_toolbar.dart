import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/browser_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/app_theme.dart';
import 'mobile_tab_switcher.dart';
import 'browser_menu_drawer.dart';

class BrowserToolbar extends StatefulWidget {
  const BrowserToolbar({super.key});

  @override
  State<BrowserToolbar> createState() => _BrowserToolbarState();
}

class _BrowserToolbarState extends State<BrowserToolbar> {
  late TextEditingController _urlController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncUrlText(String url) {
    if (!_focusNode.hasFocus) {
      if (url == 'firezip://home') {
        _urlController.text = '';
      } else {
        _urlController.text = url;
      }
    }
  }

  void _onSubmitted(String input) {
    if (input.trim().isEmpty) return;
    final settings = context.read<SettingsProvider>();
    context.read<BrowserProvider>().navigateCurrentTab(input, settings.searchEngine);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final browser = context.watch<BrowserProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);

    _syncUrlText(browser.currentTab.url);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          // Navigation Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: browser.currentTab.canGoBack ? browser.goBack : null,
          ),

          // Navigation Forward Button
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: 'Forward',
            onPressed:
                browser.currentTab.canGoForward ? browser.goForward : null,
          ),

          // Navigation Reload / Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: () {
              browser.navigateCurrentTab(
                browser.currentTab.url,
                context.read<SettingsProvider>().searchEngine,
              );
            },
          ),

          // Home Button
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Home',
            onPressed: browser.goHome,
          ),

          const SizedBox(width: 4),

          // URL / Search Input Bar
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppTheme.primaryLightBlue
                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  width: _focusNode.hasFocus ? 1.5 : 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    browser.currentTab.url.startsWith('https://')
                        ? Icons.lock_rounded
                        : Icons.search_rounded,
                    size: 16,
                    color: AppTheme.primaryLightBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.go,
                      onSubmitted: _onSubmitted,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search or enter website address',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.only(bottom: 6),
                        suffixIcon: _urlController.text.isNotEmpty &&
                                _focusNode.hasFocus
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () {
                                  _urlController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Tabs Button (with badge count for Mobile)
          IconButton(
            tooltip: 'Tabs (${browser.tabs.length})',
            onPressed: () {
              if (isMobile) {
                MobileTabSwitcherSheet.show(context);
              } else {
                browser.openNewTab();
              }
            },
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${browser.tabs.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Menu Button
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Firezip Menu',
            onPressed: () => BrowserMenuDrawer.show(context),
          ),
        ],
      ),
    );
  }
}
