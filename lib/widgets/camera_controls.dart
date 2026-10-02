import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleFlash;
  final VoidCallback onOpenGallery;
  final bool isFlashOn;
  final bool isRecording;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onToggleFlash,
    required this.onOpenGallery,
    this.isFlashOn = false,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? AppTheme.primaryCyan : Colors.white,
              size: 28,
            ),
            onPressed: onToggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
            onPressed: onOpenGallery,
          ),
          GestureDetector(
            onTap: onCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isRecording ? 84 : 76,
              height: isRecording ? 84 : 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRecording ? AppTheme.accentPink : AppTheme.primaryCyan,
                  width: 4,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isRecording ? BorderRadius.circular(12) : null,
                    color: isRecording ? AppTheme.accentPink : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white, size: 28),
            onPressed: onSwitchCamera,
          ),
        ],
      ),
    );
  }
}
