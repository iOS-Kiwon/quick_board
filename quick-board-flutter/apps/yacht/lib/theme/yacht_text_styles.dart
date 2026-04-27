import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'yacht_colors.dart';

abstract final class YachtTextStyles {
  static const List<String> _koreanFallback = ['NotoSansKR'];

  static TextStyle get appTitle => GoogleFonts.rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: YachtColors.primaryBright,
        letterSpacing: 2,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get heading => GoogleFonts.rajdhani(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: YachtColors.text,
        letterSpacing: 1,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get body => GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: YachtColors.text,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get bodyDim => GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: YachtColors.textDim,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get score => GoogleFonts.rajdhani(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: YachtColors.scorePositive,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get categoryName => GoogleFonts.rajdhani(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: YachtColors.text,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get tableHeader => GoogleFonts.rajdhani(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: YachtColors.primaryBright,
        letterSpacing: 0.5,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get button => GoogleFonts.rajdhani(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: YachtColors.text,
        letterSpacing: 1,
      ).copyWith(fontFamilyFallback: _koreanFallback);

  static TextStyle get bonus => GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: YachtColors.bonus,
      ).copyWith(fontFamilyFallback: _koreanFallback);
}
