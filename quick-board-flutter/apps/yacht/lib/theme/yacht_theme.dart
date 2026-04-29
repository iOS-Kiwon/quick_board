import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'yacht_colors.dart';
import 'yacht_text_styles.dart';

abstract final class YachtTheme {
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'NotoSansKR',
    scaffoldBackgroundColor: YachtColors.background,
    colorScheme: const ColorScheme.dark(
      primary: YachtColors.primary,
      secondary: YachtColors.primaryBright,
      surface: YachtColors.card,
      onPrimary: YachtColors.text,
      onSurface: YachtColors.text,
    ),
    cardColor: YachtColors.card,
    textTheme: TextTheme(
      headlineMedium: YachtTextStyles.heading,
      titleMedium: YachtTextStyles.heading,
      bodyMedium: YachtTextStyles.body,
      bodySmall: YachtTextStyles.bodyDim,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: YachtColors.background,
      foregroundColor: YachtColors.text,
      elevation: 0,
      titleTextStyle: GoogleFonts.rajdhani(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: YachtColors.primaryBright,
        letterSpacing: 1.5,
      ).copyWith(fontFamilyFallback: const ['NotoSansKR']),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: YachtColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: YachtColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: YachtColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: YachtColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.rajdhani(
        color: YachtColors.textDim,
        fontSize: 16,
      ).copyWith(fontFamilyFallback: const ['NotoSansKR']),
      labelStyle: GoogleFonts.rajdhani(
        color: YachtColors.textDim,
        fontSize: 16,
      ).copyWith(fontFamilyFallback: const ['NotoSansKR']),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: YachtColors.primary,
        foregroundColor: YachtColors.text,
        textStyle: YachtTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    dividerColor: YachtColors.border,
    useMaterial3: true,
  );
}
