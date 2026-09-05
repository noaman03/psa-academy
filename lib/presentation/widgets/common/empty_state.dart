import 'package:flutter/material.dart';
import '../../../config/theme/color_scheme.dart';
import '../../../config/theme/text_styles.dart';

/// Empty state widget for when there's no data to display
class EmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionButtonText;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionButtonText,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: iconColor ?? AppColors.grey,
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
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
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionButtonText ?? 'Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty states for common scenarios
class NoDataFound extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRefresh;

  const NoDataFound({
    super.key,
    this.customMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: customMessage ?? 'No data available at the moment',
      title: 'No Data Found',
      icon: Icons.search_off,
      onAction: onRefresh,
      actionButtonText: onRefresh != null ? 'Refresh' : null,
    );
  }
}

class NoResultsFound extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const NoResultsFound({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: searchQuery != null
          ? 'No results found for "$searchQuery"'
          : 'No results match your search',
      title: 'No Results',
      icon: Icons.search_off,
      onAction: onClearSearch,
      actionButtonText: onClearSearch != null ? 'Clear Search' : null,
    );
  }
}

class NoItemsYet extends StatelessWidget {
  final String itemType;
  final VoidCallback? onAddItem;

  const NoItemsYet({
    super.key,
    required this.itemType,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: 'You don\'t have any $itemType yet',
      title: 'Nothing Here',
      icon: Icons.inventory_2_outlined,
      onAction: onAddItem,
      actionButtonText: onAddItem != null ? 'Add $itemType' : null,
    );
  }
}

class ConnectionError extends StatelessWidget {
  final VoidCallback? onRetry;

  const ConnectionError({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: 'Unable to connect. Please check your internet connection.',
      title: 'Connection Error',
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.error,
      onAction: onRetry,
      actionButtonText: onRetry != null ? 'Try Again' : null,
    );
  }
}
