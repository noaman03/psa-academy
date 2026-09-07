import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/player_entity.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/player_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/training_details_dialog.dart';
import '../../routes/app_routes.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<PlayerController>().initializePlayer(user.id);
      }
    });
  }

  static const List<NavDestinationItem> _destinations = [
    NavDestinationItem(
      label: 'Pass & Balance',
      icon: Icons.qr_code_2_outlined,
      selectedIcon: Icons.qr_code_2,
    ),
    NavDestinationItem(
      label: 'My Workouts',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
    ),
    NavDestinationItem(
      label: 'Documents Vault',
      icon: Icons.folder_shared_outlined,
      selectedIcon: Icons.folder_shared,
    ),
  ];

  static const List<String> _titles = [
    'Player Membership & Pass',
    'Session History & Workouts',
    'Medical & Document Vault',
  ];

  void _showQrPassDialog(PlayerEntity player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorderRadius),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Center(
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Image(
                    image: AssetImage('assets/images/mainNOBGF.png'),
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Player Training Pass',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Show this QR code to your coach at check-in',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgBorderRadius,
                border: Border.all(color: AppColors.outline),
                boxShadow: AppShadows.cardShadow,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: PrettyQrView.data(
                  data: player.id,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              player.name,
              style: AppTypography.titleLg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${player.category} • ${player.level} (${player.ageGroup})',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: AppButton(
              text: 'Done',
              size: AppButtonSize.small,
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final playerController = context.watch<PlayerController>();
    final player = playerController.player;
    final userName = player?.name ?? auth.currentUser?.name ?? 'Player';

    final bodies = [
      _buildPassAndBalanceTab(context, player),
      _buildWorkoutsTab(playerController),
      _buildDocumentsTab(playerController, player?.id ?? auth.currentUser?.id ?? ''),
    ];

    return AppScaffold(
      title: _titles[_selectedIndex],
      roleBadgeText: 'Player',
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

  Widget _buildPassAndBalanceTab(BuildContext context, PlayerEntity? player) {
    if (player == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasPositiveSessions = player.remainingSessions > 0;
    final isAllowed = player.isAllowedPlayer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player Profile & Status Header
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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${player.category} • ${player.level} (${player.ageGroup})',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: isAllowed ? 'ACTIVE' : 'SUSPENDED',
                  statusType: isAllowed ? StatusType.active : StatusType.debit,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Digital Pass Action Card (Whole Card Clickable)
          Semantics(
            button: true,
            label: 'Digital Training Pass',
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgBorderRadius,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              child: InkWell(
                borderRadius: AppRadius.lgBorderRadius,
                onTap: () => _showQrPassDialog(player),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.mdBorderRadius,
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 36,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Training Pass',
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap anywhere on this card to open your full-screen QR check-in pass',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Balance & Sessions Metric Strip
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.mdBorderRadius,
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sessions Remaining',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${player.remainingSessions}',
                            style: AppTypography.displaySm.copyWith(
                              color: hasPositiveSessions
                                  ? AppColors.primary
                                  : AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'sessions',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: (player.remainingSessions / 12).clamp(0.0, 1.0),
                        backgroundColor: AppColors.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          hasPositiveSessions
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.mdBorderRadius,
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Balance',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppFormatters.formatCurrency(player.balance),
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: player.balance >= 0
                              ? AppColors.textPrimary
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      StatusBadge(
                        label: player.balance >= 0 ? 'CURRENT' : 'OVERDUE',
                        statusType: player.balance >= 0
                            ? StatusType.paid
                            : StatusType.debit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsTab(PlayerController playerController) {
    final state = playerController.attendanceState;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = state.data ?? [];

    if (list.isEmpty) {
      return const EmptyState(
        title: 'No Workouts Logged Yet',
        description:
            'When your coach checks you into a session, the attendance and training drills will be recorded here.',
        icon: Icons.fitness_center_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: list.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius,
            side: const BorderSide(color: AppColors.outline),
          ),
          child: InkWell(
            borderRadius: AppRadius.mdBorderRadius,
            onTap: () => TrainingDetailsDialog.show(context, item),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(item.date),
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      StatusBadge(
                        label: item.type.toUpperCase(),
                        statusType: item.type == 'recovery'
                            ? StatusType.pending
                            : StatusType.paid,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coach: ${item.coachName} • Time: ${DateFormat('hh:mm a').format(item.date)}',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(color: AppColors.outlineVariant, height: 16),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          item.workoutName != null && item.workoutName!.isNotEmpty
                              ? 'Routine: ${item.workoutName}'
                              : 'Tap to view routine plan',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(
      PlayerController playerController, String playerId) {
    final docs = playerController.documents;

    return Column(
      children: [
        // Action Bar (Read-only overview)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents & Medical (${docs.length})',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.fullBorderRadius,
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(
                  'Verified Vault',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Document List (Read-only)
        Expanded(
          child: docs.isEmpty
              ? const EmptyState(
                  title: 'No Documents on File',
                  description:
                      'Medical clearances, insurance certificates, and fitness records uploaded by academy administrators will appear here.',
                  icon: Icons.folder_open,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(
                          doc.fileType == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        doc.title,
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('dd MMM yyyy').format(doc.uploadedAt)} • ${doc.fileType.toUpperCase()}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20, color: AppColors.primary),
                        tooltip: 'View / Download Document',
                        onPressed: () async {
                          final uri = Uri.parse(doc.fileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
