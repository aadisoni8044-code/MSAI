import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'avatar_widget.dart';

class StatusRingAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final bool isSeen;
  final bool isMyStatus;
  final VoidCallback? onAddTap;

  const StatusRingAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 28.0,
    this.isSeen = false,
    this.isMyStatus = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isMyStatus
                  ? Colors.transparent
                  : (isSeen ? AppColors.textMuted : AppColors.primaryBlue),
              width: 2.2,
            ),
          ),
          child: AvatarWidget(
            imageUrl: imageUrl,
            name: name,
            radius: radius,
            showOnlineIndicator: false,
          ),
        ),
        if (isMyStatus && onAddTap != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.darkBackground,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
