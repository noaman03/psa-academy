import 'package:flutter/material.dart';

/// Centralized Stitch spacing, corner radii, shadows and breakpoints.
class AppSpacing {
  AppSpacing._();

  // 8px base grid
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // Layout-specific
  static const double containerMargin = 24.0;
  static const double gutterDesktop = 24.0;
  static const double gutterMobile = 16.0;
  static const double sidebarWidth = 260.0;
  static const double bottomNavHeight = 64.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 960.0;
  static const double desktopBreakpoint = 1200.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0; // Standard for cards & inputs
  static const double lg = 12.0; // Standard for modals & buttons
  static const double xl = 16.0;
  static const double full = 9999.0; // Pill badges

  static final BorderRadius smBorderRadius = BorderRadius.circular(sm);
  static final BorderRadius mdBorderRadius = BorderRadius.circular(md);
  static final BorderRadius lgBorderRadius = BorderRadius.circular(lg);
  static final BorderRadius xlBorderRadius = BorderRadius.circular(xl);
  static final BorderRadius fullBorderRadius = BorderRadius.circular(full);
}

class AppShadows {
  AppShadows._();

  /// Soft, ambient shadow (replaces harsh drop shadows from V1)
  static const List<BoxShadow> ambient = [
    BoxShadow(
      color: Color.fromRGBO(16, 42, 67, 0.08),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color.fromRGBO(16, 42, 67, 0.04),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color.fromRGBO(16, 42, 67, 0.12),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardShadow = ambient;
}
