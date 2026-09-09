import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum AppThemeMode { dark, light, system }

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.accentColor,
        surface: AppConstants.darkSurfaceColor,
        background: AppConstants.darkBackgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkSurfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.darkSurfaceColor,
        selectedItemColor: AppConstants.accentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.accentColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: AppConstants.darkSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryDarkColor,
        secondary: AppConstants.primaryColor,
        surface: Colors.white,
        background: Color(0xFFF0F2F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryDarkColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryDarkColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
