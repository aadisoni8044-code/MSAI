import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final bool isOnline;
  final bool showOnlineIndicator;

  const AvatarWidget({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 24.0,
    this.isOnline = false,
    this.showOnlineIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: diameter,
            height: diameter,
            color: AppColors.darkSurfaceSecondary,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
                return Container(
                  color: AppColors.primaryBlueDark,
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: radius * 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: AppColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.darkBackground,
                  width: 2.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
