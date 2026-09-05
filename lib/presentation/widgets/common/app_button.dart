import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String? label;
  final String? text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;

  const AppButton({
    super.key,
    this.label,
    this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : assert(label != null || text != null, 'Provide either label or text');

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label ?? text ?? '';

    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = AppColors.textWhite;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.secondary;
        fgColor = AppColors.textWhite;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.secondary;
        borderSide = const BorderSide(color: AppColors.outline, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = AppColors.textWhite;
        break;
    }

    double height;
    EdgeInsets padding;
    TextStyle textStyle;

    switch (size) {
      case AppButtonSize.small:
        height = 36;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        textStyle = AppTypography.labelMd.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        );
        break;
      case AppButtonSize.medium:
        height = 44;
        padding = const EdgeInsets.symmetric(horizontal: 16);
        textStyle = AppTypography.labelLg.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        );
        break;
      case AppButtonSize.large:
        height = 50;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        textStyle = AppTypography.titleMd.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w700,
        );
        break;
    }

    final buttonChild = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: size == AppButtonSize.small ? 16 : 18, color: fgColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(effectiveLabel, style: textStyle),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius,
          ),
          padding: padding,
        ),
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}
