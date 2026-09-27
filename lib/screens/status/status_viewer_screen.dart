import 'package:flutter/material.dart';
import '../../models/status.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/avatar_widget.dart';

class StatusViewerScreen extends StatefulWidget {
  final Status status;

  const StatusViewerScreen({
    super.key,
    required this.status,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((statusState) {
      if (statusState == AnimationStatus.completed) {
        if (_currentIndex < widget.status.mediaItems.length - 1) {
          setState(() {
            _currentIndex++;
          });
          _progressController.forward(from: 0.0);
        } else {
          Navigator.pop(context);
        }
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildStatusContent(StatusMedia media) {
    if (media.type == StatusType.text) {
      return Container(
        color: AppColors.primaryBlue,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Text(
          media.caption,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          media.url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.darkBackground,
            child: const Icon(Icons.broken_image_rounded, size: 64, color: AppColors.textMuted),
          ),
        ),
        if (media.caption.isNotEmpty)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                media.caption,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.status.mediaItems[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildStatusContent(media),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Row(
                    children: widget.status.mediaItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              double val = 0.0;
                              if (idx < _currentIndex) {
                                val = 1.0;
                              } else if (idx == _currentIndex) {
                                val = _progressController.value;
                              }
                              return LinearProgressIndicator(
                                value: val,
                                backgroundColor: Colors.white30,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 3,
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      AvatarWidget(
                        imageUrl: widget.status.userAvatar,
                        name: widget.status.userName,
                        radius: 18,
                        showOnlineIndicator: false,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.status.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white30, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Reply...',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reply sent!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
