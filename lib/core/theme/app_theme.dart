import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Material 3 Expressive-inspired theme (large rounded shapes, tonal
/// containers, pill navigation, edge-to-edge system bars).
class AppTheme {
  AppTheme._();

  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(seedColor: AppColors.deepEmerald).copyWith(
    brightness: Brightness.light,
    primary: AppColors.deepEmerald,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCBEBE0),
    onPrimaryContainer: const Color(0xFF06302A),
    secondary: AppColors.skyTeal,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD3EBF0),
    onSecondaryContainer: const Color(0xFF0B3640),
    tertiary: const Color(0xFFA9803A),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFF6E9CC),
    onTertiaryContainer: const Color(0xFF3B2A06),
    surface: AppColors.warmIvory,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF9FCFB),
    surfaceContainer: const Color(0xFFEAF4F0),
    surfaceContainerHigh: const Color(0xFFE1EFE9),
    surfaceContainerHighest: AppColors.parchment,
    outline: const Color(0xFF6F8B83),
    outlineVariant: const Color(0xFFC7DBD3),
    error: AppColors.error,
  );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(seedColor: AppColors.deepEmerald, brightness: Brightness.dark)
          .copyWith(
    brightness: Brightness.dark,
    primary: const Color(0xFF7FD1BC),
    onPrimary: const Color(0xFF00382E),
    primaryContainer: const Color(0xFF12493E),
    onPrimaryContainer: const Color(0xFFBDF0E1),
    secondary: const Color(0xFF9CCFDB),
    onSecondary: const Color(0xFF00363F),
    secondaryContainer: const Color(0xFF1B4A55),
    onSecondaryContainer: const Color(0xFFD3EBF0),
    tertiary: AppColors.mutedGoldLight,
    onTertiary: const Color(0xFF3B2A06),
    tertiaryContainer: const Color(0xFF55401A),
    onTertiaryContainer: const Color(0xFFF6E9CC),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textOnDark,
    onSurfaceVariant: const Color(0xFFA9C4BB),
    surfaceContainerLowest: const Color(0xFF091512),
    surfaceContainerLow: const Color(0xFF101F1C),
    surfaceContainer: AppColors.cardDark,
    surfaceContainerHigh: const Color(0xFF1B3234),
    surfaceContainerHighest: const Color(0xFF223B3D),
    outline: const Color(0xFF7F9C93),
    outlineVariant: const Color(0xFF2F4A46),
    error: const Color(0xFFFFB4AB),
  );

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  static SystemUiOverlayStyle overlayFor(Brightness brightness) {
    final icons =
        brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: icons,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: icons,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData _build(ColorScheme cs) {
    final stadium = const StadiumBorder();
    return ThemeData(
      useMaterial3: true,
      brightness: cs.brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      fontFamily: AppTypography.arabicUiFontFamily,
      textTheme: _textTheme(cs),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: overlayFor(cs.brightness),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
        indicatorShape: stadium,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 26,
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.onSurface : cs.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: stadium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: stadium,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: cs.outline),
          shape: stadium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: stadium),
      ),
      chipTheme: ChipThemeData(
        shape: stadium,
        side: BorderSide(color: cs.outlineVariant),
        backgroundColor: cs.surfaceContainerLowest,
        selectedColor: cs.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 1),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: cs.onSurface),
      headlineMedium:
          AppTypography.headlineMedium.copyWith(color: cs.onSurface),
      titleLarge: AppTypography.titleLarge.copyWith(color: cs.onSurface),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: cs.onSurface),
      bodyMedium:
          AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
      labelLarge: AppTypography.labelLarge.copyWith(color: cs.onSurface),
      bodySmall: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
    ).apply(fontFamily: AppTypography.arabicUiFontFamily);
  }
}
