import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/attendance_entity.dart';
import '../../../controllers/admin_controller.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/status_badge.dart';

class AdminAttendanceTab extends StatefulWidget {
  const AdminAttendanceTab({super.key});

  @override
  State<AdminAttendanceTab> createState() => _AdminAttendanceTabState();
}

class _AdminAttendanceTabState extends State<AdminAttendanceTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showWorkoutDetailsDialog(AttendanceEntity attendance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          attendance.workoutName ?? 'Session Details',
          style: AppTypography.headlineSm.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player: ${attendance.playerName}', style: AppTypography.bodyMd),
            Text('Coach: ${attendance.coachName}', style: AppTypography.bodyMd),
            Text('Type: ${attendance.type.toUpperCase()}',
                style: AppTypography.bodyMd),
            Text(
              'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(attendance.date)}',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.md),
            if (attendance.workoutDetails != null &&
                attendance.workoutDetails!.isNotEmpty) ...[
              Text(
                'Exercises / Plan:',
                style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.smBorderRadius,
                ),
                child: Text(
                  attendance.workoutDetails.toString(),
                  style: AppTypography.bodySm,
                ),
              ),
            ] else
              const Text('No workout routine attached to this session.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();
    final data = adminController.dashboardState.data;
    final allAttendance = data?.recentAttendance ?? [];

    final filtered = allAttendance.where((a) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return a.playerName.toLowerCase().contains(q) ||
          (a.coachName?.toLowerCase().contains(q) ?? false) ||
          (a.workoutName?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.surface,
          child: AppTextField(
            controller: _searchController,
            hintText: 'Search attendance by player or coach name...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  title: 'No Attendance Records Found',
                  description:
                      'Player attendance check-ins will be logged here with timestamps and assigned coaches.',
                  icon: Icons.event_busy,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.outlineVariant),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      onTap: () => _showWorkoutDetailsDialog(item),
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
                        'Coach: ${item.coachName} • ${DateFormat('dd MMM yyyy, hh:mm a').format(item.date)}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(
                            label: item.type.toUpperCase(),
                            statusType: item.type == 'recovery'
                                ? StatusType.pending
                                : StatusType.paid,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textTertiary),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
