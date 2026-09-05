import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum StatusBadgeType { paid, pending, debit, active, inactive }

typedef StatusType = StatusBadgeType;

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    StatusBadgeType? type,
    StatusBadgeType? statusType,
  }) : type = type ?? statusType ?? StatusBadgeType.active;

  factory StatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'active':
        return StatusBadge(
          label: status.toUpperCase(),
          type: StatusBadgeType.paid,
        );
      case 'pending':
        return StatusBadge(
          label: status.toUpperCase(),
          type: StatusBadgeType.pending,
        );
      case 'debit':
      case 'blocked':
      case 'inactive':
      case 'failed':
        return StatusBadge(
          label: status.toUpperCase(),
          type: StatusBadgeType.debit,
        );
      default:
        return StatusBadge(
          label: status.toUpperCase(),
          type: StatusBadgeType.active,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    Color dotColor;

    switch (type) {
      case StatusBadgeType.paid:
      case StatusBadgeType.active:
        bgColor = AppColors.successBackground;
        fgColor = const Color(0xFF027A48);
        dotColor = AppColors.success;
        break;
      case StatusBadgeType.pending:
        bgColor = AppColors.warningBackground;
        fgColor = const Color(0xFFB54708);
        dotColor = AppColors.warning;
        break;
      case StatusBadgeType.debit:
      case StatusBadgeType.inactive:
        bgColor = AppColors.errorBackground;
        fgColor = const Color(0xFFB42318);
        dotColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.fullBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
