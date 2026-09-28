import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/call.dart';
import 'avatar.dart';

class CallTile extends StatelessWidget {
  final Call call;
  final VoidCallback onTap;

  const CallTile({
    super.key,
    required this.call,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  Widget _buildDirectionIcon() {
    switch (call.direction) {
      case CallDirection.incoming:
        return const Icon(Icons.call_received_rounded, color: AppColors.success, size: 16);
      case CallDirection.outgoing:
        return const Icon(Icons.call_made_rounded, color: AppColors.primary, size: 16);
      case CallDirection.missed:
        return const Icon(Icons.call_missed_rounded, color: AppColors.error, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Avatar(
        imageUrl: call.userAvatar,
        radius: 24,
      ),
      title: Text(
        call.userName,
        style: TextStyle(
          color: call.direction == CallDirection.missed ? AppColors.error : AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          _buildDirectionIcon(),
          const SizedBox(width: 6),
          Text(
            _formatTime(call.timestamp),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (call.duration != '00:00') ...[
            const SizedBox(width: 6),
            Text('(${call.duration})', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          call.type == CallType.video ? Icons.videocam_rounded : Icons.phone_rounded,
          color: AppColors.primary,
        ),
        onPressed: onTap,
      ),
    );
  }
}
