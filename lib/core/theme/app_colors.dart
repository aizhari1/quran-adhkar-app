import 'package:flutter/material.dart';

/// Sanctuary Editorial Design System – Color Tokens
/// Deep Emerald, Warm Ivory, Muted Gold
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color deepEmerald = Color(0xFF0F2C24);
  static const Color deepEmeraldDark = Color(0xFF0A1F1A);
  static const Color mutedGreen = Color(0xFF557B64);
  static const Color softEmerald = Color(0xFF2A4A3F);

  // Neutral / Background
  static const Color warmIvory = Color(0xFFF7F4EC);
  static const Color warmIvoryDark = Color(0xFFEDE8DC);
  static const Color parchment = Color(0xFFF9F6F0);
  static const Color surfaceDark = Color(0xFF121C19);
  static const Color cardDark = Color(0xFF1A2A25);

  // Accent
  static const Color mutedGold = Color(0xFFC5A46D);
  static const Color mutedGoldLight = Color(0xFFD4BC8E);
  static const Color goldGlow = Color(0x33C5A46D);

  // Text
  static const Color textPrimary = Color(0xFF101B18);
  static const Color textSecondary = Color(0xFF4A5C55);
  static const Color textOnEmerald = Color(0xFFF7F4EC);
  static const Color textMuted = Color(0xFF77796F);
  static const Color textOnDark = Color(0xFFE8E4D9);

  // Semantic
  static const Color success = Color(0xFF3D7A5A);
  static const Color warning = Color(0xFFC5A46D);
  static const Color error = Color(0xFFB54A4A);
  static const Color info = Color(0xFF4A7B9D);

  // Borders & Dividers
  static const Color borderLight = Color(0x3377796F);
  static const Color borderDark = Color(0x33C5A46D);
  static const Color divider = Color(0x1A101B18);

  // Prayer / Adhkar specific
  static const Color prayerActive = mutedGold;
  static const Color adhkarProgress = mutedGold;
  static const Color ayahHighlight = Color(0x0A0F2C24); // 4% Deep Emerald
}
