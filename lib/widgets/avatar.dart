import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Avatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool isOnline;
  final bool showOnlineIndicator;
  final bool isGroup;

  const Avatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.surfaceHighlight,
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  isGroup ? Icons.groups_rounded : Icons.person_rounded,
                  size: radius * 1.1,
                  color: AppColors.primaryLight,
                );
              },
            ),
          ),
        ),
        if (showOnlineIndicator && isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
