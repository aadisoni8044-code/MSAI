import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CallActiveScreen extends StatefulWidget {
  final String userName;

  const CallActiveScreen({
    super.key,
    required this.userName,
  });

  @override
  State<CallActiveScreen> createState() => _CallActiveScreenState();
}

class _CallActiveScreenState extends State<CallActiveScreen> {
  bool _isMuted = false;
  bool _isSpeaker = true;
  bool _isVideoOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkSurface, AppColors.darkBackground],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(51),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'Z',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '00:14 • Encrypted End-to-End',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceSecondary,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(76),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded),
                      color: _isMuted ? AppColors.errorRed : Colors.white,
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(_isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded),
                      color: _isVideoOn ? Colors.white : AppColors.errorRed,
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          _isVideoOn = !_isVideoOn;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(_isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded),
                      color: AppColors.primaryBlue,
                      iconSize: 28,
                      onPressed: () {
                        setState(() {
                          _isSpeaker = !_isSpeaker;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
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
