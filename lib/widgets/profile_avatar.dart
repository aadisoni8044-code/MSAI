import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool hasStory;
  final bool isStorySeen;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 28,
    this.hasStory = false,
    this.isStorySeen = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    LinearGradient? borderGradient;
    if (hasStory) {
      if (isStorySeen) {
        borderGradient = const LinearGradient(
          colors: [Colors.grey, Colors.grey],
        );
      } else {
        borderGradient = const LinearGradient(
          colors: [AppTheme.primaryCyan, AppTheme.accentPurple, AppTheme.accentPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(hasStory ? 3 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: borderGradient,
        ),
        child: Container(
          padding: EdgeInsets.all(hasStory ? 2 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.scaffoldBackgroundColor,
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty || !imageUrl.startsWith('http')
                ? Icon(Icons.person, size: radius, color: theme.colorScheme.onSurface)
                : null,
          ),
        ),
      ),
    );
  }
}
