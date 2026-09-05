import 'package:flutter/material.dart';
import '../../../config/theme/color_scheme.dart';
import '../../../config/theme/text_styles.dart';

/// Error message widget with icon and optional retry button
class ErrorMessage extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final ErrorSeverity severity;

  const ErrorMessage({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryButtonText,
    this.severity = ErrorSeverity.error,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = _getColor();
    final errorIcon = icon ?? _getDefaultIcon();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              errorIcon,
              size: 64,
              color: errorColor,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.titleLarge.copyWith(color: errorColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (severity) {
      case ErrorSeverity.error:
        return AppColors.error;
      case ErrorSeverity.warning:
        return AppColors.warning;
      case ErrorSeverity.info:
        return AppColors.info;
    }
  }

  IconData _getDefaultIcon() {
    switch (severity) {
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_rounded;
      case ErrorSeverity.info:
        return Icons.info_outline;
    }
  }
}

/// Inline error message widget (for forms)
class InlineErrorMessage extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineErrorMessage({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ErrorSeverity {
  error,
  warning,
  info,
}
