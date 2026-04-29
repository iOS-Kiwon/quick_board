import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static final ThemeData dark = ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'NotoSansKR',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.goldBright,
          surface: AppColors.card,
          error: AppColors.scoreNegative,
        ),
        cardColor: AppColors.card,
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.heading,
          titleMedium: AppTextStyles.subheading,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.bodyDim,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          labelStyle: AppTextStyles.bodyDim,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.background,
            textStyle: AppTextStyles.subheading,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      );
}
