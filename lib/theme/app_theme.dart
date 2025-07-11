import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBrown = Color(0xFF8A4001);
  static const Color primaryCyan = Color(0xFF46D5DC);
  static const Color accentBrown = Color(0xFFBE6E1C);
  static const Color lightCream = Color(0xFFFFDC8F);
  static const Color secondaryCyan = Color(0xFF48D5DC);

  static const Color background = Color(0xFFFFFBF5);
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF2D2D2D);
  static const Color onSurface = Color(0xFF2D2D2D);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryCyan,
        primary: AppColors.primaryCyan,
        secondary: AppColors.primaryBrown,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onBackground: AppColors.onBackground,
        onSurface: AppColors.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: AppColors.onPrimary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCream.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.accentBrown),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.accentBrown.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryCyan, width: 2),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.primaryBrown,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gabarito',
        ),
        headlineMedium: TextStyle(
          color: AppColors.primaryBrown,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gabarito',
        ),
        bodyLarge: TextStyle(
          color: AppColors.onBackground,
          fontSize: 16,
          fontFamily: 'Gabarito',
        ),
        bodyMedium: TextStyle(
          color: AppColors.onBackground,
          fontSize: 14,
          fontFamily: 'Gabarito',
        ),
      ),
      fontFamily: 'Gabarito',
    );
  }
}
