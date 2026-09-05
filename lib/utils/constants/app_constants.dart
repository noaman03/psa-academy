import 'package:flutter/material.dart';

/// Colors
class AppColors {
  // Primary palette
  static const Color primaryDark = Color(0xFF006D6F);
  static const Color primary = Color(0xFF00A6A6);
  static const Color primaryLight = Color(0xFF8EE8E8);

  // Secondary palette
  static const Color secondaryDark = Color(0xFFB84B22);
  static const Color secondary = Color(0xFFFF7A45);
  static const Color secondaryLight = Color(0xFFFFB199);

  // Neutrals
  static const Color darkGrey = Color(0xFF101828);
  static const Color mediumGrey = Color(0xFF667085);
  static const Color lightGrey = Color(0xFFE4E7EC);
  static const Color background = Color(0xFFF6F8FB);

  // Functional colors
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFF04438);
  static const Color info = Color(0xFF2E90FA);

  // Gradients
  static const List<Color> primaryGradient = [primaryDark, primary];
  static const List<Color> secondaryGradient = [secondary, secondaryLight];
  static const List<Color> successGradient = [success, Color(0xFF6CE9A6)];
  static const List<Color> warningGradient = [warning, Color(0xFFFDB022)];
  static const List<Color> errorGradient = [error, Color(0xFFFF6B61)];
}

/// Text Styles
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.3,
    letterSpacing: 0,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.darkGrey,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.darkGrey,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.mediumGrey,
    height: 1.5,
    letterSpacing: 0,
  );

  // Special styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.mediumGrey,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mediumGrey,
    letterSpacing: 0,
  );
}

/// Spacing and Sizing
class AppSizing {
  // Padding and margins
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 8.0;
  static const double borderRadiusXLarge = 10.0;
  static const Radius radiusSmall = Radius.circular(borderRadiusSmall);
  static const Radius radiusMedium = Radius.circular(borderRadiusMedium);
  static const Radius radiusLarge = Radius.circular(borderRadiusLarge);
  static const Radius radiusXLarge = Radius.circular(borderRadiusXLarge);

  // Card elevation
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationLarge = 4.0;

  // Button sizes
  static const Size buttonSizeSmall = Size(80, 36);
  static const Size buttonSizeMedium = Size(120, 44);
  static const Size buttonSizeLarge = Size(160, 48);
  static const double buttonMaxWidth = 300.0; // Default max width
  static const double buttonMaxWidthLarge = 400.0; // For special cases

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 960.0;
  static const double desktopBreakpoint = 1280.0;

  // Add a responsive sizing method
  static double getResponsiveButtonWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > desktopBreakpoint) {
      return buttonMaxWidth;
    } else if (width > tabletBreakpoint) {
      return buttonMaxWidth * 0.9;
    } else {
      return double.infinity; // Full width on mobile
    }
  }
}

/// Button Styles
class AppButtonStyles {
  // Primary button
  static ButtonStyle primaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.primary;
      },
    ),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    elevation: WidgetStateProperty.all<double>(0),
    overlayColor:
        WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.08)),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
          horizontal: AppSizing.m, vertical: AppSizing.s),
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      ),
    ),
    maximumSize: WidgetStateProperty.all<Size>(
      const Size(AppSizing.buttonMaxWidth, 64),
    ),
  );

  // Secondary button
  static ButtonStyle secondaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.secondary.withOpacity(0.5);
        }
        return AppColors.secondary;
      },
    ),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    elevation: WidgetStateProperty.all<double>(0),
    overlayColor:
        WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.08)),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
          horizontal: AppSizing.m, vertical: AppSizing.s),
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      ),
    ),
    maximumSize: WidgetStateProperty.all<Size>(
      const Size(AppSizing.buttonMaxWidth, 64),
    ),
  );

  // Outlined button
  static ButtonStyle outlinedButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
          horizontal: AppSizing.m, vertical: AppSizing.s),
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
        side: const BorderSide(color: AppColors.primary),
      ),
    ),
    maximumSize: WidgetStateProperty.all<Size>(
      const Size(AppSizing.buttonMaxWidth, 64),
    ),
  );

  // Text button
  static ButtonStyle textButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
          horizontal: AppSizing.s, vertical: AppSizing.xs),
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      ),
    ),
  );

  // Danger button
  static ButtonStyle dangerButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.error.withOpacity(0.5);
        }
        return AppColors.error;
      },
    ),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    elevation: WidgetStateProperty.all<double>(0),
    overlayColor:
        WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.08)),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(
          horizontal: AppSizing.m, vertical: AppSizing.s),
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      ),
    ),
    maximumSize: WidgetStateProperty.all<Size>(
      const Size(AppSizing.buttonMaxWidth, 64),
    ),
  );
}

/// Card Styles
class AppCardStyles {
  static BoxDecoration defaultCard = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppSizing.borderRadiusLarge),
    border: Border.all(color: AppColors.lightGrey),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration primaryCard = BoxDecoration(
    gradient: const LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(AppSizing.borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.18),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration secondaryCard = BoxDecoration(
    gradient: const LinearGradient(
      colors: AppColors.secondaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(AppSizing.borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.secondary.withOpacity(0.18),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration successCard = BoxDecoration(
    gradient: const LinearGradient(
      colors: AppColors.successGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(AppSizing.borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.success.withOpacity(0.18),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

/// Input Decoration Styles
class AppInputDecorations {
  static InputDecoration defaultInput = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizing.m,
      vertical: AppSizing.m,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      borderSide: const BorderSide(color: AppColors.lightGrey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    errorStyle: const TextStyle(color: AppColors.error),
    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mediumGrey),
    labelStyle: AppTextStyles.label,
  );
}

/// Animation Durations
class AppAnimations {
  static const Duration shortest = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 700);
}
