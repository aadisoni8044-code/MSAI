import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/glass_theme.dart';
import '../../providers/settings_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return GlassTheme.glassContainer(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title with close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(FontAwesomeIcons.sliders, color: AppColors.accent, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'SETTINGS',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(color: AppColors.glassBorder, height: 24),

              // Dark/Light Mode Switch
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.moon,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Dark Theme Mode',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Deep blue neon aesthetic',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                trailing: Switch(
                  value: settings.isDarkMode,
                  activeColor: AppColors.accent,
                  onChanged: (val) => settings.toggleDarkMode(val),
                ),
              ),

              // Private Account Toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.shieldHalved,
                    color: AppColors.neonPurple,
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Private Account',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Only approved friends view snaps',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                trailing: Switch(
                  value: settings.isPrivateAccount,
                  activeColor: AppColors.neonPurple,
                  onChanged: (val) => settings.togglePrivateAccount(val),
                ),
              ),

              // Location Geofilters Toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.locationDot,
                    color: AppColors.neonGreen,
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Location Geofilters',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Enable city-specific camera lenses',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                trailing: Switch(
                  value: settings.locationGeofiltersEnabled,
                  activeColor: AppColors.neonGreen,
                  onChanged: (val) => settings.toggleLocationGeofilters(val),
                ),
              ),

              const SizedBox(height: 12),

              // Essential Clear Cache Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardDark,
                    foregroundColor: AppColors.neonPink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.neonPink, width: 1),
                    ),
                  ),
                  icon: const Icon(FontAwesomeIcons.trashCan, size: 16),
                  label: Text('Clear Lens Cache (${settings.formattedCacheSize})'),
                  onPressed: () {
                    settings.clearCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera filter cache cleared! 🧹'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'ZIPPRO v1.0.0 • Clean & Modern UI',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
