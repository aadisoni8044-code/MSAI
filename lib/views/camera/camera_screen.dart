import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/camera_provider.dart';
import 'camera_preview_widget.dart';
import 'capture_button_widget.dart';
import 'filter_slider_widget.dart';
import 'glassmorphism_top_header.dart';
import 'snap_preview_modal.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraProvider>().initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProv, child) {
        if (cameraProv.lastCapturedMedia != null) {
          return const SnapPreviewModal();
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Live camera viewfinder with selected filter matrix overlay
              const CameraPreviewWidget(),

              // 2. Glassmorphism Top Header controls (Flash, Switch Camera, Timer, Settings)
              const GlassmorphismTopHeader(),

              // 3. Countdown timer banner overlay
              if (cameraProv.isCountingDown)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.8),
                      border: Border.all(color: AppColors.accent, width: 3),
                    ),
                    child: Text(
                      '${cameraProv.countdownValue}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // 4. Bottom controls overlay (50-Filter Slider + Capture Snap button)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        FilterSliderWidget(),
                        SizedBox(height: 16),
                        CaptureButtonWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
