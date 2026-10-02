import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/glass_theme.dart';
import '../../providers/camera_provider.dart';
import '../../providers/story_provider.dart';

class SnapPreviewModal extends StatefulWidget {
  const SnapPreviewModal({super.key});

  @override
  State<SnapPreviewModal> createState() => _SnapPreviewModalState();
}

class _SnapPreviewModalState extends State<SnapPreviewModal> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProv, child) {
        final capturedMedia = cameraProv.lastCapturedMedia;
        if (capturedMedia == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Captured photo or video preview placeholder
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary.withValues(alpha: 0.9),
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        capturedMedia.type == CaptureType.photo
                            ? Icons.photo_camera
                            : Icons.videocam,
                        size: 80,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        capturedMedia.type == CaptureType.photo
                            ? 'SNAP PHOTO CAPTURED'
                            : 'VIDEO SNAP RECORDED',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Text(
                          'FILTER: ${capturedMedia.filterName.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top action bar (Discard / Back)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassHeader,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      onPressed: () {
                        cameraProv.clearCapturedMedia();
                      },
                    ),
                  ),
                ),
              ),

              // Bottom Caption & Send/Post overlay
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GlassTheme.glassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _captionController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a snap caption...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                              ),
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                FontAwesomeIcons.penToSquare,
                                color: AppColors.accent,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Post to Story Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(color: AppColors.accent),
                                    ),
                                  ),
                                  icon: const Icon(FontAwesomeIcons.circlePlus, size: 18),
                                  label: const Text('Add to Story'),
                                  onPressed: () {
                                    context.read<StoryProvider>().addStoryPost(
                                          mediaUrl:
                                              'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=800&q=80',
                                          filterName: capturedMedia.filterName,
                                          caption: _captionController.text.isEmpty
                                              ? 'Snap captured with ${capturedMedia.filterName} filter ✨'
                                              : _captionController.text,
                                        );
                                    cameraProv.clearCapturedMedia();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Snap posted to your story! ⚡'),
                                        backgroundColor: AppColors.secondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Send Direct Snap Button
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [AppColors.accent, AppColors.secondary],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.paperPlane,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    cameraProv.clearCapturedMedia();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Snap sent to friends! 🚀'),
                                        backgroundColor: AppColors.accent,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
