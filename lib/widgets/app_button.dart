import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.primaryCyan
              : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
          foregroundColor: isPrimary ? Colors.black : theme.colorScheme.onSurface,
          elevation: isPrimary ? 4 : 0,
          shadowColor: isPrimary ? AppTheme.primaryCyan.withOpacity(0.4) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: isPrimary ? Colors.black : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
