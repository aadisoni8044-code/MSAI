import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/app_settings.dart';
import '../providers/theme_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/zipgram_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final btProvider = context.watch<BluetoothProvider>();
    final settings = themeProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // APPEARANCE SECTION
          _buildSectionHeader(context, 'APPEARANCE'),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme Mode',
            subtitle: _getThemeModeName(settings.themeMode),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text('Light Mode'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text('Dark Mode'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
            ),
          ),
          const Divider(),

          // CONNECTION SECTION
          _buildSectionHeader(context, 'CONNECTION'),
          SettingsTile(
            icon: Icons.bluetooth,
            title: 'Bluetooth Capability',
            subtitle: btProvider.state != BluetoothState.off
                ? 'Bluetooth is active'
                : 'Bluetooth is turned off',
            trailing: Switch.adaptive(
              value: btProvider.state != BluetoothState.off,
              onChanged: (val) => btProvider.toggleBluetooth(val),
            ),
          ),
          SettingsTile(
            icon: Icons.visibility_outlined,
            title: 'Nearby Discovery Visibility',
            subtitle: settings.nearbyDiscoveryVisible
                ? 'Visible to nearby ZIPGRAM devices'
                : 'Hidden from scan results',
            trailing: Switch.adaptive(
              value: settings.nearbyDiscoveryVisible,
              onChanged: (val) {
                themeProvider.updateSettings(
                  settings.copyWith(nearbyDiscoveryVisible: val),
                );
              },
            ),
          ),
          SettingsTile(
            icon: Icons.autorenew,
            title: 'Auto-Connect Saved Devices',
            subtitle: 'Automatically connect when in Bluetooth range',
            trailing: Switch.adaptive(
              value: settings.autoConnectSavedDevices,
              onChanged: (val) {
                themeProvider.updateSettings(
                  settings.copyWith(autoConnectSavedDevices: val),
                );
              },
            ),
          ),
          const Divider(),

          // CHAT & NOTIFICATIONS
          _buildSectionHeader(context, 'CHAT & NOTIFICATIONS'),
          SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Message Sound',
            subtitle: 'Play sound for incoming offline messages',
            trailing: Switch.adaptive(
              value: settings.soundEnabled,
              onChanged: (val) {
                themeProvider.updateSettings(
                  settings.copyWith(soundEnabled: val),
                );
              },
            ),
          ),
          SettingsTile(
            icon: Icons.vibration,
            title: 'Vibration Feedback',
            subtitle: 'Vibrate on Bluetooth message arrival',
            trailing: Switch.adaptive(
              value: settings.vibrationEnabled,
              onChanged: (val) {
                themeProvider.updateSettings(
                  settings.copyWith(vibrationEnabled: val),
                );
              },
            ),
          ),
          const Divider(),

          // PRIVACY & SAFETY
          _buildSectionHeader(context, 'PRIVACY & SAFETY'),
          SettingsTile(
            icon: Icons.block,
            title: 'Blocked Devices',
            subtitle: '${btProvider.blockedDeviceIds.length} devices blocked',
            onTap: () => _showBlockedDevicesDialog(context, btProvider),
          ),
          const Divider(),

          // ABOUT
          _buildSectionHeader(context, 'ABOUT'),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About ZIPGRAM',
            subtitle: 'Version 1.0.0 (Offline Mesh/Bluetooth Chat)',
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 32),
          const Center(
            child: ZipgramLogo(
              size: 24,
              style: ZipgramLogoStyle.iconAndWordmark,
              showTagline: true,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  String _getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light Theme';
      case AppThemeMode.dark:
        return 'Dark Theme';
    }
  }

  void _showBlockedDevicesDialog(
      BuildContext context, BluetoothProvider btProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Blocked Devices'),
          content: btProvider.blockedDeviceIds.isEmpty
              ? const Text('No blocked devices.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: btProvider.blockedDeviceIds.length,
                    itemBuilder: (context, index) {
                      final id = btProvider.blockedDeviceIds[index];
                      return ListTile(
                        title: Text(id),
                        trailing: TextButton(
                          onPressed: () {
                            btProvider.unblockDevice(id);
                            Navigator.pop(ctx);
                          },
                          child: const Text('UNBLOCK'),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ZIPGRAM',
      applicationVersion: '1.0.0',
      applicationIcon: const ZipgramLogo(
        size: 40,
        style: ZipgramLogoStyle.iconOnly,
      ),
      children: const [
        Text(
          'ZIPGRAM is an offline messaging application enabling nearby devices to discover, connect, and chat via Bluetooth without requiring an internet connection.',
        ),
      ],
    );
  }
}
