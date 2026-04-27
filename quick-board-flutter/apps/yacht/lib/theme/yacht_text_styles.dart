import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'yacht_colors.dart';

abstract final class YachtTextStyles {
  static TextStyle get appTitle => GoogleFonts.rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: YachtColors.primaryBright,
        letterSpacing: 2,
      );

  static TextStyle get heading => GoogleFonts.rajdhani(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: YachtColors.text,
        letterSpacing: 1,
      );

  static TextStyle get body => GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: YachtColors.text,
      );

  static TextStyle get bodyDim => GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: YachtColors.textDim,
      );

  static TextStyle get score => GoogleFonts.rajdhani(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: YachtColors.scorePositive,
      );

  static TextStyle get categoryName => GoogleFonts.rajdhani(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: YachtColors.text,
      );

  static TextStyle get tableHeader => GoogleFonts.rajdhani(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: YachtColors.primaryBright,
        letterSpacing: 0.5,
      );

  static TextStyle get button => GoogleFonts.rajdhani(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: YachtColors.text,
        letterSpacing: 1,
      );

  static TextStyle get bonus => GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: YachtColors.bonus,
      );
}
