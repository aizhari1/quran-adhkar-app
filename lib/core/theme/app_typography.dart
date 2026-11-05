import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system optimized for Arabic Quran text + multilingual UI.
class AppTypography {
  AppTypography._();

  // Quran / Arabic body – prefer Uthmani-capable fonts
  static const String quranFontFamily = 'ScheherazadeNew';
  static const String arabicUiFontFamily = 'NotoNaskhArabic';
  static const String latinFontFamily = 'Inter';
  static const String classicArabic = 'Amiri';

  static TextStyle quranVerse({
    double fontSize = 24,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.9,
  }) {
    return TextStyle(
      fontFamily: quranFontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: 0.2,
    );
  }

  static TextStyle arabicTitle({
    double fontSize = 20,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: arabicUiFontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: 1.5,
    );
  }

  static TextStyle displayLarge = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle titleLarge = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle labelLarge = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.35,
  );
}
