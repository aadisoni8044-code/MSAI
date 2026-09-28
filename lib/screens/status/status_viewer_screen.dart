import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/status.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';

class StatusViewerScreen extends StatefulWidget {
  final UserStatus status;

  const StatusViewerScreen({super.key, required this.status});

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_currentIndex < widget.status.items.length - 1) {
            setState(() {
              _currentIndex++;
              _progressController.reset();
              _progressController.forward();
            });
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

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.status.items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: currentItem.type == StatusType.image
                  ? Image.network(
                      currentItem.content,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('Image failed to load', style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : Container(
                      color: AppColors.primary,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        currentItem.content,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      widget.status.items.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              double value = 0.0;
                              if (index < _currentIndex) {
                                value = 1.0;
                              } else if (index == _currentIndex) {
                                value = _progressController.value;
                              }
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white30,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 3,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Avatar(imageUrl: widget.status.userAvatar, radius: 18),
                      const SizedBox(width: 10),
                      Text(
                        widget.status.userName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
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
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Reply to status...',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
