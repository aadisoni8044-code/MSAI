import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/filter_model.dart';
import '../../providers/camera_provider.dart';
import '../../providers/filter_provider.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CameraProvider, FilterProvider>(
      builder: (context, cameraProv, filterProv, child) {
        final activeFilter = filterProv.activeFilter;

        Widget content;
        if (cameraProv.isInitialized && cameraProv.controller != null) {
          content = CameraPreview(cameraProv.controller!);
        } else {
          content = _buildSimulatedViewfinder(context, activeFilter);
        }

        return ColorFiltered(
          colorFilter: ColorFilter.matrix(activeFilter.colorMatrix),
          child: Stack(
            fit: StackFit.expand,
            children: [
              content,
              if (activeFilter.arEffect != null)
                _buildArEffectOverlay(context, activeFilter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulatedViewfinder(BuildContext context, FilterModel filter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.backgroundDark,
            AppColors.secondary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient cyber grid graphic
          Opacity(
            opacity: 0.15,
            child: GridPaper(
              color: AppColors.accent,
              divisions: 2,
              subDivisions: 4,
            ),
          ),
          // Center camera lens preview avatar graphic
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  border: Border.all(
                    color: filter.previewColor.withValues(alpha: 0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: filter.previewColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  filter.iconData,
                  size: 64,
                  color: filter.previewColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'LIVE CAMERA STREAM',
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  filter.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArEffectOverlay(BuildContext context, FilterModel filter) {
    switch (filter.arEffect) {
      case 'cyber_grid':
      case 'cyber_mask':
      case 'hud_visor':
        return Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.blur_on,
                  size: 180,
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
                Positioned(
                  top: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: const Text(
                      'ZIPPRO AR FACE LOCK',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'neon_halo':
      case 'glow_crown':
      case 'aura_glow':
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.18,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 180,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.8),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
