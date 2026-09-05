import 'package:flutter/material.dart';

/// Centralized Stitch Design System color palette for PSA Academy V2.
class AppColors {
  AppColors._();

  // Primary Brand (Teal)
  static const Color primary = Color(0xFF00A6A6);
  static const Color primaryDark = Color(0xFF006A6A);
  static const Color primaryLight = Color(0xFF7AF5F5);
  static const Color primaryContainer = Color(0xFFE0F7F7);
  static const Color onPrimaryContainer = Color(0xFF003434);

  // Secondary Brand (Dark Navy - Structure, Sidebars & Headers)
  static const Color secondary = Color(0xFF102A43);
  static const Color secondaryDark = Color(0xFF0A1C2E);
  static const Color secondaryLight = Color(0xFF49607C);
  static const Color secondaryContainer = Color(0xFFD1E4FF);
  static const Color onSecondaryContainer = Color(0xFF314863);

  // Surfaces & Canvas
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9EFEE);
  static const Color surfaceDim = Color(0xFFD5DBDA);

  // Borders & Dividers
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFBCC9C8);
  static const Color outlineFocused = Color(0xFF00A6A6);

  // Typography & Content
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textTertiary = Color(0xFF98A2B3);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Financial Badges (Semantics)
  static const Color success = Color(0xFF12B76A);
  static const Color successBackground = Color(0xFFECFDF3);
  static const Color successContainer = Color(0xFFECFDF3);
  static const Color onSuccessContainer = Color(0xFF027A48);
  static const Color successBorder = Color(0xFFA6F4C5);

  static const Color warning = Color(0xFFF79009);
  static const Color warningBackground = Color(0xFFFEF0C7);
  static const Color warningContainer = Color(0xFFFEF0C7);
  static const Color onWarningContainer = Color(0xFFB54708);
  static const Color warningBorder = Color(0xFFFEDF89);

  static const Color error = Color(0xFFD92D20);
  static const Color errorBackground = Color(0xFFFEE4E2);
  static const Color errorContainer = Color(0xFFFEE4E2);
  static const Color onErrorContainer = Color(0xFFB42318);
  static const Color errorBorder = Color(0xFFFECDCA);

  static const Color info = Color(0xFF2E90FA);
  static const Color infoBackground = Color(0xFFEFF8FF);
  static const Color infoContainer = Color(0xFFEFF8FF);
  static const Color onInfoContainer = Color(0xFF175CD3);
  static const Color infoBorder = Color(0xFFB2DDFF);

  // Role Accent Colors
  static const Color adminAccent = Color(0xFF7C3AED); // Purple
  static const Color coachAccent = Color(0xFF00A6A6); // Teal
  static const Color playerAccent = Color(0xFF102A43); // Navy
}
