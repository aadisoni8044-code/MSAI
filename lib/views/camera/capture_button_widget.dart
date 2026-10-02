import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/camera_provider.dart';
import '../../providers/filter_provider.dart';

class CaptureButtonWidget extends StatelessWidget {
  const CaptureButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CameraProvider, FilterProvider>(
      builder: (context, cameraProv, filterProv, child) {
        final isRecording = cameraProv.isRecording;
        final activeFilter = filterProv.activeFilter;

        return GestureDetector(
          onTap: () {
            cameraProv.capturePhoto(activeFilterName: activeFilter.name);
          },
          onLongPressStart: (_) {
            cameraProv.startVideoRecording();
          },
          onLongPressEnd: (_) {
            cameraProv.stopVideoRecording(activeFilterName: activeFilter.name);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? 90 : 80,
            height: isRecording ? 90 : 80,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isRecording ? AppColors.neonPink : AppColors.accent,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isRecording ? AppColors.neonPink : AppColors.accent)
                      .withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? AppColors.neonPink : Colors.white,
              ),
              child: Center(
                child: isRecording
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.stop_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            '${cameraProv.recordingDurationSeconds}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeFilter.previewColor,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
