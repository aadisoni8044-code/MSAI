import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call_model.dart';
import '../services/call_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class CallScreen extends StatefulWidget {
  final CallService callService;

  const CallScreen({
    super.key,
    required this.callService,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final activeCall = widget.callService.activeCall;

    if (activeCall == null) {
      return const Scaffold(
        body: Center(child: Text('No active call')),
      );
    }

    final isVideo = activeCall.type == CallType.video;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Video simulated background if video call
            if (isVideo && widget.callService.isVideoEnabled)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF131D36),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_rounded, size: 80, color: AppColors.primaryBlueLight.withAlpha(80)),
                            const SizedBox(height: 12),
                            const Text(
                              'Video Stream Active',
                              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          width: 100,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryBlueLight, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  isVideo ? 'ZIPGRAM Video Call' : 'ZIPGRAM Audio Call',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                UserAvatar(user: activeCall.participant, radius: 54, showStatus: false),
                const SizedBox(height: 20),
                Text(
                  activeCall.participant.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_secondsElapsed),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlueLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),

                // Action controls container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface.withAlpha(220),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildControlButton(
                        icon: widget.callService.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        isActive: widget.callService.isMuted,
                        onTap: () => widget.callService.toggleMute(),
                      ),
                      if (isVideo)
                        _buildControlButton(
                          icon: widget.callService.isVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                          isActive: !widget.callService.isVideoEnabled,
                          onTap: () => widget.callService.toggleVideo(),
                        ),
                      _buildControlButton(
                        icon: widget.callService.isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        isActive: widget.callService.isSpeakerOn,
                        onTap: () => widget.callService.toggleSpeaker(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.callService.endCall();
                          Navigator.of(context).maybePop();
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.missedCallRed,
                          child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: isActive ? AppColors.primaryBlue : Colors.white.withAlpha(20),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
