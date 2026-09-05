import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'text_styles.dart';

class AppInputDecorations {
  // Standard Input Decoration
  static InputDecoration standard({
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled,
      labelStyle: AppTextStyles.inputLabel,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      errorStyle: AppTextStyles.inputError,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
      filled: true,
      fillColor:
          enabled ? AppColors.white : AppColors.greyLight.withOpacity(0.35),
    );
  }

  // Rounded Input Decoration
  static InputDecoration rounded({
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled,
      labelStyle: AppTextStyles.inputLabel,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      errorStyle: AppTextStyles.inputError,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide:
            BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
      filled: true,
      fillColor:
          enabled ? AppColors.white : AppColors.greyLight.withOpacity(0.35),
    );
  }

  // Underlined Input Decoration
  static InputDecoration underlined({
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled,
      labelStyle: AppTextStyles.inputLabel,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      errorStyle: AppTextStyles.inputError,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderFocused, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide:
            BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
    );
  }

  // Search Input Decoration
  static InputDecoration search({
    String? hintText,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      hintText: hintText ?? 'Search...',
      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      enabled: enabled,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide:
            BorderSide(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
      filled: true,
      fillColor:
          enabled ? AppColors.white : AppColors.greyLight.withOpacity(0.35),
    );
  }
}
