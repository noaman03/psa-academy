import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/admin_controller.dart';
import '../../../widgets/common/metric_card.dart';
import '../../../widgets/common/status_badge.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/skeleton_loader.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();
    final state = adminController.dashboardState;

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: SkeletonLoader(height: 120)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonLoader(height: 120)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonLoader(height: 120)),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            SkeletonLoader(height: 300),
          ],
        ),
      );
    }

    if (state.isFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('Failed to load dashboard', style: AppTypography.titleMd),
            const SizedBox(height: AppSpacing.xs),
            Text(state.errorMessage ?? '', style: AppTypography.bodySm),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => adminController.loadDashboard(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    final isDesktop =
        MediaQuery.of(context).size.width >= AppSpacing.tabletBreakpoint;

    return RefreshIndicator(
      onRefresh: () => adminController.loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF1E3A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.lgBorderRadius,
                boxShadow: AppShadows.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operations Overview',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: AppRadius.fullBorderRadius,
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'V2 Clean Core',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // KPI Grid
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                SizedBox(
                  width: isDesktop ? 220 : (MediaQuery.of(context).size.width - 48) / 2,
                  child: MetricCard(
                    title: 'Total Players',
                    value: '${data.playerCount}',
                    icon: Icons.people_alt_outlined,
                    iconColor: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 220 : (MediaQuery.of(context).size.width - 48) / 2,
                  child: MetricCard(
                    title: 'Active Coaches',
                    value: '${data.coachCount}',
                    icon: Icons.sports_outlined,
                    iconColor: AppColors.secondary,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 220 : (MediaQuery.of(context).size.width - 48) / 2,
                  child: MetricCard(
                    title: "Today's Attendance",
                    value: '${data.todayAttendanceCount}',
                    icon: Icons.fact_check_outlined,
                    iconColor: AppColors.warning,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 220 : (MediaQuery.of(context).size.width - 48) / 2,
                  child: MetricCard(
                    title: 'Total Revenue',
                    value: AppFormatters.formatCurrency(
                        data.financialSummary.totalRevenue),
                    icon: Icons.trending_up,
                    iconColor: AppColors.success,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? 220 : MediaQuery.of(context).size.width - 32,
                  child: MetricCard(
                    title: 'Net Balance',
                    value: AppFormatters.formatCurrency(
                        data.financialSummary.netBalance),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: data.financialSummary.netBalance >= 0
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Today's Recent Attendance
            Text(
              "Today's Recent Check-ins",
              style: AppTypography.titleLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (data.recentAttendance.isEmpty)
              const EmptyState(
                title: 'No Check-ins Yet Today',
                description:
                    'When coaches check players into training, records will show here in real time.',
                icon: Icons.event_available,
              )
            else
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorderRadius,
                  side: const BorderSide(color: AppColors.outline),
                ),
                color: AppColors.surface,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.recentAttendance.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.outlineVariant, height: 1),
                  itemBuilder: (context, index) {
                    final item = data.recentAttendance[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          item.playerName.isNotEmpty
                              ? item.playerName[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        item.playerName,
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Coach: ${item.coachName} • ${DateFormat('hh:mm a').format(item.date)}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: StatusBadge(
                        label: item.type.toUpperCase(),
                        statusType: item.type == 'recovery'
                            ? StatusType.pending
                            : StatusType.paid,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
