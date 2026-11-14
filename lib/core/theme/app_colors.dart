import 'package:flutter/material.dart';

/// Calm "Serenity" palette: soft teal-greens, mint surfaces, warm sand accents
/// and a touch of sky blue. Mid-tone brand colors read well on light AND dark.
class AppColors {
  AppColors._();

  // Primary palette (names kept from the previous design system)
  static const Color deepEmerald = Color(0xFF1F7A68); // calm teal-green
  static const Color deepEmeraldDark = Color(0xFF135F50);
  static const Color mutedGreen = Color(0xFF5E9C8B); // sage
  static const Color softEmerald = Color(0xFF2F8472);
  static const Color skyTeal = Color(0xFF4A9AAB); // gentle sky accent

  // Neutral / background
  static const Color warmIvory = Color(0xFFF3F9F6); // mint white
  static const Color warmIvoryDark = Color(0xFFE4F0EB);
  static const Color parchment = Color(0xFFE8F3EE);
  static const Color surfaceDark = Color(0xFF0C1B18);
  static const Color cardDark = Color(0xFF14282A);

  // Accent: warm sand-gold
  static const Color mutedGold = Color(0xFFC9A05A);
  static const Color mutedGoldLight = Color(0xFFE3C58B);
  static const Color goldGlow = Color(0x33C9A05A);

  // Text
  static const Color textPrimary = Color(0xFF10302A);
  static const Color textSecondary = Color(0xFF4A675F);
  static const Color textOnEmerald = Color(0xFFF3F9F6);
  static const Color textMuted = Color(0xFF6B8880);
  static const Color textOnDark = Color(0xFFE3F1EC);

  // Semantic
  static const Color success = Color(0xFF2E8B6A);
  static const Color warning = Color(0xFFC9A05A);
  static const Color error = Color(0xFFC0504D);
  static const Color info = Color(0xFF3F8FA6);

  // Borders & dividers
  static const Color borderLight = Color(0x331F7A68);
  static const Color borderDark = Color(0x33C9A05A);
  static const Color divider = Color(0x1A10302A);

  // Prayer / Adhkar specific
  static const Color prayerActive = mutedGold;
  static const Color adhkarProgress = mutedGold;
  static const Color ayahHighlight = Color(0x141F7A68);
}
