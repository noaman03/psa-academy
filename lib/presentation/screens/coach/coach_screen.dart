import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/coach_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';
import '../../routes/app_routes.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<CoachController>().initializeCoach(user.id);
      }
    });
  }

  static const List<NavDestinationItem> _destinations = [
    NavDestinationItem(
      label: 'Shift & Scan',
      icon: Icons.qr_code_scanner_outlined,
      selectedIcon: Icons.qr_code_scanner,
    ),
    NavDestinationItem(
      label: 'Sessions History',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
    ),
    NavDestinationItem(
      label: 'Training Drills',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
    ),
  ];

  static const List<String> _titles = [
    'Coach Shift & Scanner',
    'Recent Player Sessions',
    'Training Drill Catalog',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final coachController = context.watch<CoachController>();
    final userName = auth.currentUser?.name ?? 'Coach';

    final bodies = [
      _buildShiftAndScanTab(context, auth, coachController),
      _buildRecentSessionsTab(coachController),
      _buildDrillsCatalogTab(coachController),
    ];

    return AppScaffold(
      title: _titles[_selectedIndex],
      roleBadgeText: 'Coach',
      userName: userName,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: _destinations,
      body: bodies[_selectedIndex],
      onLogout: () async {
        await context.read<AuthController>().signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
    );
  }

  Widget _buildShiftAndScanTab(
    BuildContext context,
    AuthController auth,
    CoachController coachController,
  ) {
    final activeSession = coachController.activeSession;
    final coach = coachController.coach;
    final hourlyRate = coach?.hourlyRate ?? 50.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Shift Status Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: activeSession != null
                  ? AppColors.secondary
                  : AppColors.surface,
              borderRadius: AppRadius.lgBorderRadius,
              border: Border.all(
                color: activeSession != null
                    ? AppColors.primary
                    : AppColors.outline,
                width: 1.5,
              ),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          activeSession != null
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: activeSession != null
                              ? AppColors.primaryLight
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          activeSession != null
                              ? 'ACTIVE WORK SHIFT'
                              : 'OFF DUTY',
                          style: AppTypography.labelLg.copyWith(
                            color: activeSession != null
                                ? AppColors.textWhite
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rate: ${AppFormatters.formatCurrency(hourlyRate)}/hr',
                      style: AppTypography.labelMd.copyWith(
                        color: activeSession != null
                            ? AppColors.primaryLight
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (activeSession != null) ...[
                  Text(
                    'Checked in at ${DateFormat('hh:mm a').format(activeSession.checkIn)}',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Date: ${DateFormat('EEEE, dd MMMM yyyy').format(activeSession.checkIn)}',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'End Shift & Check Out',
                    variant: AppButtonVariant.danger,
                    isLoading: coachController.isCheckingInOut,
                    onPressed: () {
                      showConfirmationDialog(
                        context: context,
                        title: 'End Work Shift',
                        message:
                          'Are you sure you want to clock out? This will finalize your shift hours and salary.',
                        confirmText: 'Check Out',
                        onConfirm: () async {
                          final uid = auth.currentUser?.id;
                          if (uid != null) {
                            await coachController.checkOut(uid, hourlyRate);
                          }
                        },
                      );
                    },
                  ),
                ] else ...[
                  Text(
                    'Ready to start your coaching session?',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Clock in to track your working hours and enable player attendance logging.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'Clock In / Start Shift',
                    icon: Icons.login,
                    isLoading: coachController.isCheckingInOut,
                    onPressed: () async {
                      final uid = auth.currentUser?.id;
                      final name = auth.currentUser?.name ?? 'Coach';
                      if (uid != null) {
                        await coachController.checkIn(uid, name);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Primary Scan Player QR Action Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgBorderRadius,
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.lgBorderRadius,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 38,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Scan Player QR Code',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Verify player subscription, remaining sessions, and record attendance.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'Open Scanner',
                    icon: Icons.camera_alt_outlined,
                    size: AppButtonSize.large,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.coachScan);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsTab(CoachController coachController) {
    final list = coachController.coachAttendance;

    if (list.isEmpty) {
      return const EmptyState(
        title: 'No Check-ins Conducted Yet',
        description:
            'Sessions you check players into will appear here with time and workout details.',
        icon: Icons.event_available,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = list[index];
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
            '${DateFormat('dd MMM yyyy, hh:mm a').format(item.date)}${item.workoutName != null ? ' • ${item.workoutName}' : ''}',
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
    );
  }

  Widget _buildDrillsCatalogTab(CoachController coachController) {
    final templates = coachController.templates;

    if (templates.isEmpty) {
      return const EmptyState(
        title: 'No Training Templates',
        description:
            'Academy administrators will publish workout routines and drills here.',
        icon: Icons.fitness_center_outlined,
      );
    }

    return ListView.separated(
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
            title: Text(
              t.trainingName,
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              '${t.category} • ${t.exercises.length} Exercises',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: t.exercises
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 16, color: AppColors.primary),
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
                                '${e.sets} × ${e.reps}',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
