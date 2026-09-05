import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'text_styles.dart';

class AppButtonStyles {
  // Elevated Button Styles
  static ButtonStyle elevatedPrimary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 0,
    shadowColor: AppColors.cardShadow,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button,
    minimumSize: const Size(120, 48),
    maximumSize: const Size(400, 64),
  );

  static ButtonStyle elevatedSecondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 0,
    shadowColor: AppColors.cardShadow,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button,
    minimumSize: const Size(120, 48),
    maximumSize: const Size(400, 64),
  );

  static ButtonStyle elevatedSuccess = ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 0,
    shadowColor: AppColors.cardShadow,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button,
    minimumSize: const Size(120, 48),
    maximumSize: const Size(400, 64),
  );

  static ButtonStyle elevatedError = ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 0,
    shadowColor: AppColors.cardShadow,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button,
    minimumSize: const Size(120, 48),
    maximumSize: const Size(400, 64),
  );

  // Outlined Button Styles
  static ButtonStyle outlinedPrimary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
    minimumSize: const Size(120, 48),
    maximumSize: const Size(400, 64),
  );

  static ButtonStyle outlinedSecondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.secondary,
    side: const BorderSide(color: AppColors.secondary, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button.copyWith(color: AppColors.secondary),
    minimumSize: const Size(120, 48),
    maximumSize: const Size(400, 64),
  );

  // Text Button Styles
  static ButtonStyle textPrimary = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
    minimumSize: const Size(80, 40),
    maximumSize: const Size(400, 56),
  );

  static ButtonStyle textSecondary = TextButton.styleFrom(
    foregroundColor: AppColors.secondary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.button.copyWith(color: AppColors.secondary),
    minimumSize: const Size(80, 40),
    maximumSize: const Size(400, 56),
  );

  // Icon Button Styles
  static ButtonStyle iconPrimary = IconButton.styleFrom(
    foregroundColor: AppColors.primary,
    backgroundColor: AppColors.primaryLight.withOpacity(0.1),
    padding: const EdgeInsets.all(12),
    minimumSize: const Size(48, 48),
    maximumSize: const Size(48, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle iconSecondary = IconButton.styleFrom(
    foregroundColor: AppColors.secondary,
    backgroundColor: AppColors.secondaryLight.withOpacity(0.1),
    padding: const EdgeInsets.all(12),
    minimumSize: const Size(48, 48),
    maximumSize: const Size(48, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Note: FloatingActionButton styling is done via FloatingActionButtonTheme
  // in the main theme configuration, not through ButtonStyle

  // Size Variants
  static ButtonStyle small(ButtonStyle baseStyle) {
    return baseStyle.copyWith(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      minimumSize: MaterialStateProperty.all(const Size(80, 36)),
      maximumSize: MaterialStateProperty.all(const Size(300, 36)),
      textStyle: MaterialStateProperty.all(AppTextStyles.buttonSmall),
    );
  }

  static ButtonStyle large(ButtonStyle baseStyle) {
    return baseStyle.copyWith(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      minimumSize: MaterialStateProperty.all(const Size(160, 56)),
      maximumSize: MaterialStateProperty.all(const Size(500, 56)),
      textStyle: MaterialStateProperty.all(AppTextStyles.buttonLarge),
    );
  }
}
