import 'package:flutter/material.dart';
import '../../../config/theme/color_scheme.dart';
import '../../../config/theme/text_styles.dart';

/// Custom button widget with responsive sizing and various styles
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? customColor;
  final Color? customTextColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final textStyle = _getTextStyle(context);
    final height = _getHeight();
    final horizontalPadding = _getHorizontalPadding();

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(context),
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    } else {
      buttonChild = Text(text, style: textStyle);
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle.copyWith(
        minimumSize: WidgetStateProperty.all(
          Size(isFullWidth ? double.infinity : 120, height),
        ),
        maximumSize: WidgetStateProperty.all(
          Size(isFullWidth ? double.infinity : 400, height),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: horizontalPadding),
        ),
      ),
      child: buttonChild,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.primary,
          foregroundColor: customTextColor ?? AppColors.textOnPrimary,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.secondary,
          foregroundColor: customTextColor ?? AppColors.textOnPrimary,
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: customTextColor ?? AppColors.primary,
          side: BorderSide(color: customColor ?? AppColors.primary),
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: customTextColor ?? AppColors.primary,
        );
      case ButtonVariant.success:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.success,
          foregroundColor: customTextColor ?? AppColors.textOnPrimary,
        );
      case ButtonVariant.error:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.error,
          foregroundColor: customTextColor ?? AppColors.textOnPrimary,
        );
      case ButtonVariant.warning:
        return ElevatedButton.styleFrom(
          backgroundColor: customColor ?? AppColors.warning,
          foregroundColor: customTextColor ?? AppColors.textOnPrimary,
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    const baseStyle = AppTextStyles.buttonLarge;

    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 14);
      case ButtonSize.medium:
        return baseStyle;
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 18);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 32;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor(BuildContext context) {
    if (variant == ButtonVariant.outline || variant == ButtonVariant.text) {
      return customTextColor ?? AppColors.primary;
    }
    return customTextColor ?? AppColors.textOnPrimary;
  }
}

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
  success,
  error,
  warning,
}

enum ButtonSize {
  small,
  medium,
  large,
}
