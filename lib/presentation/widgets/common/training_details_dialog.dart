import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/attendance_entity.dart';
import '../../../domain/entities/training_template_entity.dart';
import 'app_button.dart';
import 'status_badge.dart';

class TrainingDetailsDialog extends StatelessWidget {
  final AttendanceEntity attendance;

  const TrainingDetailsDialog({
    super.key,
    required this.attendance,
  });

  static void show(BuildContext context, AttendanceEntity attendance) {
    showDialog(
      context: context,
      builder: (ctx) => TrainingDetailsDialog(attendance: attendance),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = attendance.workoutDetails;
    final workoutName = attendance.workoutName ?? details?['trainingName'] ?? details?['workoutName'];
    final category = details?['category'] ?? attendance.category ?? attendance.type.toUpperCase();
    final targetMuscle = details?['targetMuscle'] as String?;
    final description = details?['description'] as String?;
    final notes = details?['notes'] as String? ?? attendance.notes;

    List<ExerciseEntity> exercises = [];
    if (details != null && details['exercises'] is List) {
      final list = details['exercises'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          exercises.add(ExerciseEntity.fromMap(item));
        } else if (item is Map) {
          exercises.add(ExerciseEntity.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    final hasWorkout = (workoutName != null && workoutName.isNotEmpty) || exercises.isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.mdBorderRadius,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasWorkout ? workoutName! : 'Session Training Plan',
                  style: AppTypography.titleLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(attendance.date),
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),

              // Metadata pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(
                    label: category.toString().toUpperCase(),
                    statusType: StatusType.paid,
                  ),
                  if (targetMuscle != null && targetMuscle.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.fullBorderRadius,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text(
                        'Focus: $targetMuscle',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (attendance.coachName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: AppRadius.fullBorderRadius,
                      ),
                      child: Text(
                        'Coach: ${attendance.coachName}',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              if (description != null && description.isNotEmpty) ...[
                Text(
                  description,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              if (!hasWorkout) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.mdBorderRadius,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.sports_soccer_outlined,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'No Training Assigned to This Session',
                        style: AppTypography.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This attendance check-in has no custom drill routine attached yet.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Exercise Drills (${exercises.length})',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                ...exercises.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final ex = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.smBorderRadius,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            '$idx',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.exerciseName,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (ex.instructions.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  ex.instructions,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.smBorderRadius,
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            '${ex.sets} sets × ${ex.reps}',
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.smBorderRadius,
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Notes: $notes',
                          style: AppTypography.bodySm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          text: 'Close',
          size: AppButtonSize.small,
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
