import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/glass_theme.dart';
import '../../providers/camera_provider.dart';
import '../settings/settings_sheet.dart';

class GlassmorphismTopHeader extends StatelessWidget {
  const GlassmorphismTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProv, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile & App branding badge
                GlassTheme.glassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: 24,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 1.5),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ZIPPRO',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.black,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right quick action bar (Flash, Switch Camera, Timer, Settings)
                GlassTheme.glassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  borderRadius: 24,
                  child: Row(
                    children: [
                      // Flash Toggle
                      IconButton(
                        icon: Icon(
                          _getFlashIcon(cameraProv.flashMode),
                          color: cameraProv.flashMode != FlashMode.off
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => cameraProv.toggleFlash(),
                      ),

                      // Camera Flip
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.arrowsRotate,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                        onPressed: () => cameraProv.switchCamera(),
                      ),

                      // Timer Cycle
                      IconButton(
                        icon: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.clock,
                              color: AppColors.textPrimary,
                              size: 18,
                            ),
                            if (cameraProv.timerSeconds > 0)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cameraProv.timerSeconds}s',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: () => cameraProv.cycleTimer(),
                      ),

                      // Minimalist Settings Sheet
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.gear,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const SettingsSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.highlight_rounded;
    }
  }
}
