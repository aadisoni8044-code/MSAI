import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassTheme {
  static BoxDecoration glassBoxDecoration({
    double borderRadius = 20,
    Color borderColor = AppColors.glassBorder,
    Color fillColor = AppColors.glassBackground,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.08),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static Widget glassContainer({
    required Widget child,
    double blur = 15.0,
    double borderRadius = 20.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color borderColor = AppColors.glassBorder,
    Color fillColor = AppColors.glassBackground,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: glassBoxDecoration(
              borderRadius: borderRadius,
              borderColor: borderColor,
              fillColor: fillColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
