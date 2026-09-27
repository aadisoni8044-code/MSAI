import 'package:flutter/material.dart';
import '../models/call.dart';
import '../core/theme/app_colors.dart';
import 'avatar_widget.dart';

class CallTile extends StatelessWidget {
  final Call call;
  final VoidCallback onTap;
  final VoidCallback onCallPressed;

  const CallTile({
    super.key,
    required this.call,
    required this.onTap,
    required this.onCallPressed,
  });

  Widget _buildDirectionIcon() {
    IconData icon;
    Color color;

    switch (call.direction) {
      case CallDirection.incoming:
        icon = Icons.call_received_rounded;
        color = AppColors.successGreen;
        break;
      case CallDirection.outgoing:
        icon = Icons.call_made_rounded;
        color = AppColors.primaryBlue;
        break;
      case CallDirection.missed:
        icon = Icons.call_missed_rounded;
        color = AppColors.errorRed;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  String _formatTimestamp(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${time.day}/${time.month}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.dividerColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            AvatarWidget(
              imageUrl: call.userAvatar,
              name: call.userName,
              radius: 24,
              showOnlineIndicator: false,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.userName,
                    style: TextStyle(
                      color: call.direction == CallDirection.missed ? AppColors.errorRed : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDirectionIcon(),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimestamp(call.timestamp),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (call.duration != '00:00') ...[
                        const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                        Text(
                          call.duration,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                call.type == CallType.video ? Icons.videocam_rounded : Icons.phone_rounded,
                color: AppColors.primaryBlue,
              ),
              onPressed: onCallPressed,
            ),
          ],
        ),
      ),
    );
  }
}
