import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import '../widgets/camera_controls.dart';
import 'photo_editor_screen.dart';
import '../core/theme/app_theme.dart';

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
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Camera Live Preview or Simulated View
              if (cameraProv.isInitialized && cameraProv.controller != null)
                GestureDetector(
                  onScaleUpdate: (details) {
                    cameraProv.setZoom(cameraProv.currentZoom * details.scale);
                  },
                  child: CameraPreview(cameraProv.controller!),
                )
              else
                _buildSimulatedCameraView(cameraProv),

              // Top Controls Header
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: AppTheme.primaryCyan, size: 28),
                            SizedBox(width: 6),
                            Text(
                              'ZipPro',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Zoom: ${cameraProv.currentZoom.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Camera Controls
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: CameraControls(
                    isFlashOn: cameraProv.isFlashOn,
                    isRecording: cameraProv.isRecording,
                    onToggleFlash: cameraProv.toggleFlash,
                    onSwitchCamera: cameraProv.switchCamera,
                    onOpenGallery: () async {
                      final path = await cameraProv.pickMediaFromGallery();
                      if (path != null && mounted) {
                        _navigateToEditor(path, false);
                      }
                    },
                    onCapture: () async {
                      final path = await cameraProv.takePhoto();
                      if (path != null && mounted) {
                        _navigateToEditor(path, cameraProv.isVideo);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulatedCameraView(CameraProvider cameraProv) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_outlined, size: 80, color: AppTheme.primaryCyan),
            const SizedBox(height: 16),
            const Text(
              'ZipPro Camera Active',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap capture button to create & edit media',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditor(String mediaPath, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoEditorScreen(mediaPath: mediaPath, isVideo: isVideo),
      ),
    );
  }
}
