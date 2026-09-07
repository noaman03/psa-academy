import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/attendance_entity.dart';
import '../../../../domain/entities/training_template_entity.dart';
import '../../../controllers/admin_controller.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/status_badge.dart';
import '../../../widgets/common/training_details_dialog.dart';

class AdminAttendanceTab extends StatefulWidget {
  const AdminAttendanceTab({super.key});

  @override
  State<AdminAttendanceTab> createState() => _AdminAttendanceTabState();
}

class _AdminAttendanceTabState extends State<AdminAttendanceTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadTemplates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAssignWorkoutDialog(AttendanceEntity attendance) {
    final adminController = context.read<AdminController>();
    final templates = adminController.templates;

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workout templates found. Please create a template first in Workout Templates.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    TrainingTemplateEntity selectedTemplate = templates.first;
    List<ExerciseEntity> draftExercises =
        selectedTemplate.exercises.map((e) => e.copyWith()).toList();
    final notesController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
            title: Text(
              'Assign Workout to ${attendance.playerName}',
              style: AppTypography.headlineSm.copyWith(fontSize: 18),
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Date: ${DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(attendance.date)}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Template Selector
                    Text(
                      'Select Master Template to Clone:',
                      style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<TrainingTemplateEntity>(
                      initialValue: selectedTemplate,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: templates.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text('${t.trainingName} (${t.category})'),
                        );
                      }).toList(),
                      onChanged: (newT) {
                        if (newT != null) {
                          setDialogState(() {
                            selectedTemplate = newT;
                            draftExercises =
                                newT.exercises.map((e) => e.copyWith()).toList();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Snapshot Exercises (${draftExercises.length})',
                          style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Modifications won\'t affect master',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    ...draftExercises.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ex = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.smBorderRadius,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: ex.exerciseName,
                                decoration: const InputDecoration(
                                  labelText: 'Exercise',
                                  isDense: true,
                                ),
                                onChanged: (v) => draftExercises[i] =
                                    draftExercises[i].copyWith(exerciseName: v),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                initialValue: ex.sets,
                                decoration: const InputDecoration(
                                  labelText: 'Sets',
                                  isDense: true,
                                ),
                                onChanged: (v) => draftExercises[i] =
                                    draftExercises[i].copyWith(sets: v),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                initialValue: ex.reps,
                                decoration: const InputDecoration(
                                  labelText: 'Reps',
                                  isDense: true,
                                ),
                                onChanged: (v) => draftExercises[i] =
                                    draftExercises[i].copyWith(reps: v),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: notesController,
                      labelText: 'Coach / Session Notes',
                      hintText: 'e.g. Focus on sprinting technique and recovery drills',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              AppButton(
                text: 'Assign Snapshot',
                size: AppButtonSize.small,
                isLoading: isSaving,
                onPressed: () async {
                  setDialogState(() => isSaving = true);
                  final ok = await adminController.assignTrainingSnapshot(
                    attendanceId: attendance.id,
                    playerId: attendance.playerId,
                    playerName: attendance.playerName,
                    coachId: attendance.coachId,
                    coachName: attendance.coachName,
                    templateId: selectedTemplate.id,
                    trainingName: selectedTemplate.trainingName,
                    category: selectedTemplate.category,
                    targetMuscle: selectedTemplate.targetMuscle,
                    description: selectedTemplate.description,
                    exercises: draftExercises,
                    notes: notesController.text.trim(),
                  );

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Assigned workout snapshot to ${attendance.playerName}!'
                            : 'Failed to assign workout.'),
                        backgroundColor: ok ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
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
                    final hasWorkout = item.workoutName != null && item.workoutName!.isNotEmpty;

                    return ListTile(
                      onTap: () => TrainingDetailsDialog.show(context, item),
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
                        'Coach: ${item.coachName} • ${DateFormat('dd MMM yyyy, hh:mm a').format(item.date)}${hasWorkout ? ' • Routine: ${item.workoutName}' : ''}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!hasWorkout)
                            TextButton.icon(
                              icon: const Icon(Icons.add_task, size: 16),
                              label: const Text('Assign Routine'),
                              onPressed: () => _showAssignWorkoutDialog(item),
                            )
                          else
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
