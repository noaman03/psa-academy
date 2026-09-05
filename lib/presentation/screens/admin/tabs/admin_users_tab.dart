import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/player_entity.dart';
import '../../../../domain/entities/coach_entity.dart';
import '../../../controllers/admin_controller.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/status_badge.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSessionsDialog(PlayerEntity player) {
    final sessionsController = TextEditingController(text: '8');
    final amountController = TextEditingController(text: '800');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Add Sessions for ${player.name}',
              style: AppTypography.headlineSm.copyWith(fontSize: 18),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Sessions: ${player.remainingSessions} | Balance: ${AppFormatters.formatCurrency(player.balance)}',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: sessionsController,
                    labelText: 'Sessions Count to Add',
                    hintText: '8',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: amountController,
                    labelText: 'Total Price / Paid (EGP)',
                    hintText: '800',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              AppButton(
                text: 'Credit Sessions',
                size: AppButtonSize.small,
                isLoading: isSaving,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  setDialogState(() => isSaving = true);
                  final sessions = int.parse(sessionsController.text.trim());
                  final amount = double.parse(amountController.text.trim());

                  final ok = await context
                      .read<AdminController>()
                      .assignPlayerSessions(
                        player.id,
                        sessions: sessions,
                        amount: amount,
                      );

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Successfully added $sessions sessions to ${player.name}!'
                            : 'Failed to update player sessions.'),
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

  void _showPlayerDetailsSheet(PlayerEntity player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
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
                          style: AppTypography.titleLg
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${player.category} • ${player.level} • ${player.ageGroup}',
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: player.isAllowedPlayer ? 'ACTIVE' : 'SUSPENDED',
                    statusType: player.isAllowedPlayer
                        ? StatusType.active
                        : StatusType.debit,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xl),

              // KPI stats row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: AppRadius.mdBorderRadius,
                      ),
                      child: Column(
                        children: [
                          Text('Remaining', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          Text(
                            '${player.remainingSessions}',
                            style: AppTypography.titleLg.copyWith(
                              color: player.remainingSessions > 0
                                  ? AppColors.primary
                                  : AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mdBorderRadius,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Text('Attended', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          Text(
                            '${player.sessionsAttended}',
                            style: AppTypography.titleLg
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mdBorderRadius,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Text('Balance', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppFormatters.formatCurrency(player.balance),
                              style: AppTypography.titleLg
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Detailed Attributes
              Text('Player Information',
                  style: AppTypography.titleMd
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              _buildDetailRow(
                  'Email', player.email.isNotEmpty ? player.email : 'None'),
              _buildDetailRow('Phone', player.phone ?? 'None'),
              _buildDetailRow(
                  'Parent Name', player.parentName ?? 'Not specified'),
              _buildDetailRow(
                  'Parent Phone', player.parentPhone ?? 'Not specified'),
              _buildDetailRow(
                  'Emergency Contact', player.emergencyContact ?? 'None'),
              _buildDetailRow(
                  'Medical Info', player.medicalInfo ?? 'None reported'),
              _buildDetailRow('Player ID', player.id),
              const SizedBox(height: AppSpacing.lg),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '+ Add Sessions',
                      icon: Icons.add,
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAddSessionsDialog(player);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoachDetailsSheet(CoachEntity coach) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: Text(
                      coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.name,
                          style: AppTypography.titleLg
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          coach.specialization.isNotEmpty
                              ? coach.specialization
                              : 'General Coaching',
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: coach.isAllowedCoach ? 'AUTHORIZED' : 'INACTIVE',
                    statusType: coach.isAllowedCoach
                        ? StatusType.active
                        : StatusType.debit,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xl),

              // Rates & Work Summary
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: AppRadius.mdBorderRadius,
                      ),
                      child: Column(
                        children: [
                          Text('Hourly Rate', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppFormatters.formatCurrency(coach.hourlyRate),
                              style: AppTypography.titleLg
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mdBorderRadius,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Text('Hours Worked', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          Text(
                            coach.totalWorkedHours.toStringAsFixed(1),
                            style: AppTypography.titleLg
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mdBorderRadius,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Text('Total Earned', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppFormatters.formatCurrency(
                                  coach.totalWorkedHours * coach.hourlyRate),
                              style: AppTypography.titleLg.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Coach Profile',
                  style: AppTypography.titleMd
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              _buildDetailRow('Email', coach.email),
              _buildDetailRow('Phone', coach.phone ?? 'None'),
              _buildDetailRow('Experience', '${coach.yearsOfExperience} years'),
              _buildDetailRow('Coach ID', coach.id),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();
    final isLoading = adminController.isLoadingUsers;
    final players = adminController.players;
    final coaches = adminController.coaches;

    final filteredPlayers = players.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.phone?.toLowerCase().contains(q) ?? false) ||
          p.email.toLowerCase().contains(q);
    }).toList();

    final filteredCoaches = coaches.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          (c.phone?.toLowerCase().contains(q) ?? false) ||
          c.email.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Tabs Header
        Container(
          color: AppColors.surface,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Players (${players.length})'),
                  Tab(text: 'Coaches (${coaches.length})'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppTextField(
                  controller: _searchController,
                  hintText: 'Search by name, phone or email...',
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
            ],
          ),
        ),

        // List Content
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Players List
                    filteredPlayers.isEmpty
                        ? const EmptyState(
                            title: 'No Players Found',
                            description:
                                'Registered academy players will appear here.',
                            icon: Icons.person_off_outlined,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: filteredPlayers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final player = filteredPlayers[index];
                              return Card(
                                elevation: 0,
                                margin:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdBorderRadius,
                                  side: const BorderSide(
                                      color: AppColors.outline),
                                ),
                                child: InkWell(
                                  onTap: () => _showPlayerDetailsSheet(player),
                                  borderRadius: AppRadius.mdBorderRadius,
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            AppColors.primaryContainer,
                                        child: Text(
                                          player.name.isNotEmpty
                                              ? player.name[0].toUpperCase()
                                              : 'P',
                                          style: const TextStyle(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    player.name,
                                                    style: AppTypography.titleMd
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: AppSpacing.xs),
                                                StatusBadge(
                                                  label: player.isAllowedPlayer
                                                      ? 'ACTIVE'
                                                      : 'SUSPENDED',
                                                  statusType:
                                                      player.isAllowedPlayer
                                                          ? StatusType.active
                                                          : StatusType.debit,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${player.phone ?? ''} • ${player.category} (${player.ageGroup})',
                                              style: AppTypography.bodySm
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: player.remainingSessions > 0
                                                        ? AppColors
                                                            .successContainer
                                                        : AppColors
                                                            .errorContainer,
                                                    borderRadius: AppRadius
                                                        .smBorderRadius,
                                                  ),
                                                  child: Text(
                                                    '${player.remainingSessions} Sessions Left',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: player.remainingSessions > 0
                                                          ? AppColors.success
                                                          : AppColors.error,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: AppSpacing.sm),
                                                Text(
                                                  'Bal: ${AppFormatters.formatCurrency(player.balance)}',
                                                  style: AppTypography.bodySm
                                                      .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Column(
                                        children: [
                                          AppButton(
                                            text: '+ Sessions',
                                            size: AppButtonSize.small,
                                            onPressed: () =>
                                                _showAddSessionsDialog(player),
                                          ),
                                          const SizedBox(height: 4),
                                            Switch(
                                              value: player.isAllowedPlayer,
                                              activeThumbColor: AppColors.primary,
                                              onChanged: (_) => adminController
                                                .togglePlayerAllowed(player),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            },
                          ),

                    // Coaches List
                    filteredCoaches.isEmpty
                        ? const EmptyState(
                            title: 'No Coaches Found',
                            description: 'Staff coaches will appear here.',
                            icon: Icons.sports,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: filteredCoaches.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final coach = filteredCoaches[index];
                              return Card(
                                elevation: 0,
                                margin:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdBorderRadius,
                                  side: const BorderSide(
                                      color: AppColors.outline),
                                ),
                                child: InkWell(
                                  onTap: () => _showCoachDetailsSheet(coach),
                                  borderRadius: AppRadius.mdBorderRadius,
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            AppColors.secondary.withValues(alpha: 0.1),
                                        child: Text(
                                          coach.name.isNotEmpty
                                              ? coach.name[0].toUpperCase()
                                              : 'C',
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  coach.name,
                                                  style: AppTypography.titleMd
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: AppSpacing.xs),
                                                StatusBadge(
                                                  label: coach.isAllowedCoach
                                                      ? 'AUTHORIZED'
                                                      : 'INACTIVE',
                                                  statusType: coach.isAllowedCoach
                                                      ? StatusType.active
                                                      : StatusType.debit,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${coach.phone ?? ''} • ${coach.email}',
                                              style: AppTypography.bodySm
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Rate: ${AppFormatters.formatCurrency(coach.hourlyRate)}/hr • Worked: ${coach.totalWorkedHours.toStringAsFixed(1)} hrs',
                                              style: AppTypography.bodySm
                                                  .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: coach.isAllowedCoach,
                                        activeThumbColor: AppColors.primary,
                                        onChanged: (_) => adminController
                                            .toggleCoachAllowed(coach),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            },
                          ),
                  ],
                ),
        ),
      ],
    );
  }
}
