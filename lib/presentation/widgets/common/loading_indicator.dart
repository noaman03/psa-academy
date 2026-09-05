import 'package:flutter/material.dart';
import '../../../config/theme/color_scheme.dart';

/// Loading indicator with customizable colors and sizes
class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorSize = _getSize();
    final indicatorColor = color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: _getStrokeWidth(),
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 24;
      case LoadingSize.medium:
        return 40;
      case LoadingSize.large:
        return 56;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? AppColors.overlay,
            child: LoadingIndicator(
              message: message,
              size: LoadingSize.large,
              color: AppColors.white,
            ),
          ),
      ],
    );
  }
}

enum LoadingSize {
  small,
  medium,
  large,
}
