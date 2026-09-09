import 'package:flutter/material.dart';

class AppConstants {
  // Brand Colors
  static const Color primaryColor = Color(0xFF128C7E); // MSAI Teal
  static const Color primaryDarkColor = Color(0xFF075E54);
  static const Color accentColor = Color(0xFF25D366); // MSAI Green
  static const Color darkBackgroundColor = Color(0xFF111B21);
  static const Color darkSurfaceColor = Color(0xFF202C33);
  static const Color darkBubbleSelf = Color(0xFF005C4B);
  static const Color darkBubbleOther = Color(0xFF202C33);

  static const Color lightBackgroundColor = Color(0xFFEFEAE2);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightBubbleSelf = Color(0xFFE7FFDB);
  static const Color lightBubbleOther = Color(0xFFFFFFFF);

  // Storage Keys
  static const String keyAuthToken = 'msai_auth_token';
  static const String keyCurrentUser = 'msai_current_user';
  static const String keyThemeMode = 'msai_theme_mode';
  static const String keyPendingMessages = 'msai_pending_messages';
  static const String keyLanguage = 'msai_language';

  // Default Assets / Placeholders
  static const String defaultAvatar = 'assets/images/default_avatar.png';
}
