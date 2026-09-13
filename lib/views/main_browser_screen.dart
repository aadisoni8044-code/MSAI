import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/browser_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/responsive_layout.dart';
import '../widgets/browser_toolbar.dart';
import '../widgets/desktop_tab_bar.dart';
import 'web_content_view.dart';

class MainBrowserScreen extends StatelessWidget {
  const MainBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<BrowserProvider>();
    final isDesktopOrTablet = !ResponsiveLayout.isMobile(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
          browser.openNewTab();
        },
        const SingleActivator(LogicalKeyboardKey.keyW, control: true): () {
          browser.closeTab(browser.activeTabIndex);
        },
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () {
          final settings = context.read<SettingsProvider>();
          browser.navigateCurrentTab(
            browser.currentTab.url,
            settings.searchEngine,
          );
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Desktop Tab Bar (Shown on Laptop/Desktop/Tablet)
                if (isDesktopOrTablet) const DesktopTabBar(),

                // Browser Navigation & Address Toolbar
                const BrowserToolbar(),

                // Main Web Page Content Engine
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: WebContentView(
                      key: ValueKey(browser.currentTab.id + browser.currentTab.url),
                      tab: browser.currentTab,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
