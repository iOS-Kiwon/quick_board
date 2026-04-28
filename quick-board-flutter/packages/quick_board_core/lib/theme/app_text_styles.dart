import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const List<String> _koreanFallback = ['NotoSansKR'];

  static TextStyle get heading => GoogleFonts.cinzel(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.goldBright,
        letterSpacing: 1.5,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get subheading => GoogleFonts.cinzel(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get body => GoogleFonts.cinzel(
        fontSize: 14,
        color: AppColors.text,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get bodyDim => GoogleFonts.cinzel(
        fontSize: 13,
        color: AppColors.textDim,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get scorePositive => GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.scorePositive,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get scoreNegative => GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.scoreNegative,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get scoreZero => GoogleFonts.cinzel(
        fontSize: 14,
        color: AppColors.textDim,
      ).copyWith(fontFamilyFallback: _koreanFallback);
}
