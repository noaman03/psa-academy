import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/status_badge.dart';
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
        title: Center(
          child: Column(
            children: [
              Text(
                'Player Training Pass',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Show this code to your coach at check-in',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
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
            const SizedBox(height: 2),
            Text(
              'ID: ${player.id}',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy ID'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: player.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Player ID copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
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

  Future<void> _pickAndUploadDocument(String playerId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;

        if (bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not read file data. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        if (mounted) {
          final ok = await context.read<PlayerController>().uploadDocument(
                playerId,
                fileName: file.name,
                bytes: bytes,
              );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? 'Document uploaded successfully!'
                    : 'Failed to upload document.'),
                backgroundColor: ok ? AppColors.success : AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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

    final hasPositiveSessions = player.sessionsPaid > 0;
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

          // Digital Pass Action Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgBorderRadius,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.mdBorderRadius,
                        ),
                        child: const Icon(
                          Icons.qr_code,
                          size: 32,
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
                            Text(
                              'Tap to open your full-screen QR code for coach scanning',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'View QR Pass',
                    icon: Icons.qr_code_scanner,
                    size: AppButtonSize.large,
                    onPressed: () => _showQrPassDialog(player),
                  ),
                ],
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
                            '${player.sessionsPaid}',
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
                        value: (player.sessionsPaid / 12).clamp(0.0, 1.0),
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
                if (item.workoutName != null && item.workoutName!.isNotEmpty) ...[
                  const Divider(color: AppColors.outlineVariant, height: 16),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Routine: ${item.workoutName}',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(
      PlayerController playerController, String playerId) {
    final docs = playerController.documents;
    final isUploading = playerController.isUploadingDocument;

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
                'Documents & Medical (${docs.length})',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppButton(
                text: 'Upload File',
                icon: Icons.upload_file,
                size: AppButtonSize.small,
                isLoading: isUploading,
                onPressed: () => _pickAndUploadDocument(playerId),
              ),
            ],
          ),
        ),

        // Document List
        Expanded(
          child: docs.isEmpty
              ? const EmptyState(
                  title: 'No Documents Uploaded',
                  description:
                      'Upload your medical clearance certificates, athlete fitness records, or ID cards.',
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 20),
                            tooltip: 'View Document',
                            onPressed: () async {
                              final uri = Uri.parse(doc.fileUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.error),
                            tooltip: 'Delete Document',
                            onPressed: () {
                              showConfirmationDialog(
                                context: context,
                                title: 'Delete Document',
                                message:
                                    'Are you sure you want to delete "${doc.title}"?',
                                confirmText: 'Delete',
                                isDangerous: true,
                                onConfirm: () =>
                                    playerController.deleteDocument(
                                  playerId,
                                  doc.id,
                                  doc.fileUrl,
                                ),
                              );
                            },
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
