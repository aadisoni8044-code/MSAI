import 'package:flutter/material.dart';
import '../models/call_model.dart';
import '../services/call_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

class CallsTab extends StatelessWidget {
  final CallService callService;
  final VoidCallback onStartCall;

  const CallsTab({
    super.key,
    required this.callService,
    required this.onStartCall,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildDirectionIcon(CallDirection direction) {
    switch (direction) {
      case CallDirection.incoming:
        return const Icon(Icons.call_received_rounded, size: 16, color: AppColors.incomingCallGreen);
      case CallDirection.outgoing:
        return const Icon(Icons.call_made_rounded, size: 16, color: AppColors.outgoingCallBlue);
      case CallDirection.missed:
        return const Icon(Icons.call_missed_rounded, size: 16, color: AppColors.missedCallRed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: callService,
      builder: (context, _) {
        final history = callService.callHistory;

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_missed_rounded, size: 64, color: AppColors.textSecondaryDark.withAlpha(100)),
                const SizedBox(height: 16),
                const Text(
                  'No call history yet',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: history.length,
          separatorBuilder: (context, index) => const Divider(indent: 72, height: 1),
          itemBuilder: (context, index) {
            final record = history[index];
            final isVideo = record.type == CallType.video;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: UserAvatar(user: record.participant, radius: 24),
              title: Text(
                record.participant.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: record.direction == CallDirection.missed ? AppColors.missedCallRed : null,
                ),
              ),
              subtitle: Row(
                children: [
                  _buildDirectionIcon(record.direction),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(record.timestamp),
                    style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                  ),
                  if (record.duration != null) ...[
                    const Text(' • ', style: TextStyle(color: AppColors.textSecondaryDark)),
                    Text(
                      '${record.duration!.inMinutes}m ${record.duration!.inSeconds % 60}s',
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                    ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                  color: AppColors.primaryBlueLight,
                ),
                onPressed: () {
                  callService.startCall(record.participant, record.type);
                  onStartCall();
                },
              ),
            );
          },
        );
      },
    );
  }
}
