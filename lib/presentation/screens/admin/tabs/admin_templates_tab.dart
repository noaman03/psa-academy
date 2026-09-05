import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/training_template_entity.dart';
import '../../../controllers/admin_controller.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/confirmation_dialog.dart';
import '../../../widgets/common/empty_state.dart';

class AdminTemplatesTab extends StatefulWidget {
  const AdminTemplatesTab({super.key});

  @override
  State<AdminTemplatesTab> createState() => _AdminTemplatesTabState();
}

class _AdminTemplatesTabState extends State<AdminTemplatesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadTemplates();
    });
  }

  void _showCreateTemplateDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: 'Fitness');
    final focusController = TextEditingController(text: 'Full Body');
    final exercises = <ExerciseItemEntity>[
      const ExerciseItemEntity(
        exerciseName: 'Warm-up & Dynamic Stretching',
        sets: '1',
        reps: '10 min',
      ),
    ];
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Create Training Template',
              style: AppTypography.headlineSm.copyWith(fontSize: 18),
            ),
            content: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: nameController,
                        labelText: 'Template Name',
                        hintText: 'e.g. Speed & Agility Session A',
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter template name'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: categoryController,
                              labelText: 'Category',
                              hintText: 'Fitness / Recovery / Agility',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              controller: focusController,
                              labelText: 'Focus Area',
                              hintText: 'Lower Body / Cardio',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Exercises (${exercises.length})',
                            style: AppTypography.labelLg
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Exercise'),
                            onPressed: () {
                              setDialogState(() {
                                exercises.add(
                                  ExerciseItemEntity(
                                    exerciseName:
                                        'Exercise ${exercises.length + 1}',
                                    sets: '3',
                                    reps: '10',
                                  ),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...exercises.asMap().entries.map((entry) {
                        final i = entry.key;
                        final ex = entry.value;
                        final nameC =
                            TextEditingController(text: ex.exerciseName);
                        final setsC = TextEditingController(text: ex.sets);
                        final repsC = TextEditingController(text: ex.reps);

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.sm),
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
                                  controller: nameC,
                                  decoration: const InputDecoration(
                                    labelText: 'Exercise',
                                    isDense: true,
                                  ),
                                  onChanged: (v) => exercises[i] =
                                      exercises[i].copyWith(exerciseName: v),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: setsC,
                                  decoration: const InputDecoration(
                                    labelText: 'Sets',
                                    isDense: true,
                                  ),
                                  onChanged: (v) => exercises[i] =
                                      exercises[i].copyWith(sets: v),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: repsC,
                                  decoration: const InputDecoration(
                                    labelText: 'Reps',
                                    isDense: true,
                                  ),
                                  onChanged: (v) => exercises[i] =
                                      exercises[i].copyWith(reps: v),
                                ),
                              ),
                              if (exercises.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.error),
                                  onPressed: () {
                                    setDialogState(() => exercises.removeAt(i));
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              AppButton(
                text: 'Save Template',
                size: AppButtonSize.small,
                isLoading: isSaving,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  setDialogState(() => isSaving = true);

                  final newTemplate = TrainingTemplateEntity(
                    id: const Uuid().v4(),
                    trainingName: nameController.text.trim(),
                    category: categoryController.text.trim(),
                    targetMuscle: focusController.text.trim(),
                    exercises: exercises,
                    createdAt: DateTime.now(),
                  );

                  final ok = await context
                      .read<AdminController>()
                      .createTemplate(newTemplate);

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Template created successfully!'
                            : 'Failed to create template.'),
                        backgroundColor:
                            ok ? AppColors.success : AppColors.error,
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
    final templates = adminController.templates;

    return Column(
      children: [
        // Action Bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catalog: ${templates.length} workout routines',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppButton(
                text: 'New Workout Template',
                icon: Icons.add,
                size: AppButtonSize.small,
                onPressed: _showCreateTemplateDialog,
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: templates.isEmpty
              ? const EmptyState(
                  title: 'No Training Templates Found',
                  description:
                      'Create structured workout templates that coaches can assign to players during check-in.',
                  icon: Icons.fitness_center_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: templates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final t = templates[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdBorderRadius,
                        side: const BorderSide(color: AppColors.outline),
                      ),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(
                            Icons.fitness_center,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          t.trainingName,
                          style: AppTypography.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${t.category} • ${t.targetMuscle ?? 'General'} • ${t.exercises.length} exercises',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () {
                            showConfirmationDialog(
                              context: context,
                              title: 'Delete Template',
                              message:
                                  'Are you sure you want to delete "${t.trainingName}"?',
                              confirmText: 'Delete',
                              isDangerous: true,
                              onConfirm: () =>
                                  adminController.deleteTemplate(t.id),
                            );
                          },
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(color: AppColors.outlineVariant),
                                ...t.exercises.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            e.exerciseName,
                                            style: AppTypography.bodyMd.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${e.sets} sets × ${e.reps} reps',
                                          style: AppTypography.bodySm.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ),
                          ),
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
