import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Stitch typography using Hanken Grotesk for PSA Academy V2.
class AppTypography {
  AppTypography._();

  static TextStyle get displayLg => GoogleFonts.hankenGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 56 / 48,
        letterSpacing: -0.96,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySm => GoogleFonts.hankenGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 44 / 36,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineLg => GoogleFonts.hankenGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.32,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMd => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSm => GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLg => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMd => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSm => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLg => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMd => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySm => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLg => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMd => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.6,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSm => GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        color: AppColors.textTertiary,
      );

  /// Tabular figures for aligned financial ledgers & currency numbers
  static TextStyle get currencyDisplay => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  static TextStyle get currencySmall => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );
}
