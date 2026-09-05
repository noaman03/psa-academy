import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/training_template_entity.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/coach_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/status_badge.dart';

class CoachScanScreen extends StatefulWidget {
  const CoachScanScreen({super.key});

  @override
  State<CoachScanScreen> createState() => _CoachScanScreenState();
}

class _CoachScanScreenState extends State<CoachScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final _manualIdController = TextEditingController();
  bool _isManualInput = false;
  String _selectedType = 'fitness'; // 'fitness' or 'recovery'
  TrainingTemplateEntity? _selectedTemplate;
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualIdController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    for (final b in barcodes) {
      final code = b.rawValue;
      if (code != null && code.isNotEmpty) {
        _handlePlayerScanned(code.trim());
        break;
      }
    }
  }

  Future<void> _handlePlayerScanned(String playerId) async {
    setState(() => _isProcessing = true);
    final coachController = context.read<CoachController>();
    await coachController.verifyPlayer(playerId);
    setState(() => _isProcessing = false);
  }

  Future<void> _confirmAttendance() async {
    final coach = context.read<CoachController>();
    final auth = context.read<AuthController>();
    final player = coach.scannedPlayer;

    if (player == null) return;

    if (!player.isAllowedPlayer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot check in: Player is currently suspended.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final ok = await coach.markAttendance(
      coachId: auth.currentUser?.id ?? '',
      coachName: auth.currentUser?.name ?? 'Coach',
      type: _selectedType,
      sessionPrice: 100,
      workoutId: _selectedTemplate?.id,
      workoutName: _selectedTemplate?.trainingName,
      workoutDetails: _selectedTemplate != null
          ? {
              'trainingName': _selectedTemplate!.trainingName,
              'category': _selectedTemplate!.category,
              'targetMuscle': _selectedTemplate!.targetMuscle,
              'exercises': _selectedTemplate!.exercises
                  .map((e) => {
                        'exerciseName': e.exerciseName,
                        'sets': e.sets,
                        'reps': e.reps,
                      })
                  .toList(),
            }
          : null,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Attendance checked in for ${player.name}! 1 session deducted.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(coach.scanError ?? 'Failed to record attendance.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coachController = context.watch<CoachController>();
    final scannedPlayer = coachController.scannedPlayer;
    final templates = coachController.templates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Player Check-in & Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isManualInput ? Icons.qr_code_scanner : Icons.keyboard),
            tooltip: _isManualInput ? 'Use Camera' : 'Manual ID Entry',
            onPressed: () {
              setState(() => _isManualInput = !_isManualInput);
            },
          ),
        ],
      ),
      body: scannedPlayer != null
          ? _buildPlayerConfirmationView(scannedPlayer, templates)
          : _isManualInput
              ? _buildManualInputView()
              : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.secondary,
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryLight, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Point your camera at the player\'s PSA QR code.',
                  style: TextStyle(color: AppColors.textWhite),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),
              // Scanner Overlay frame
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: AppRadius.lgBorderRadius,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.surface,
          child: AppButton(
            text: 'Switch to Manual ID Input',
            variant: AppButtonVariant.outline,
            onPressed: () => setState(() => _isManualInput = true),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputView() {
    final coachController = context.watch<CoachController>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Player ID',
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter the player\'s unique user ID if the QR scanner is unavailable.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: _manualIdController,
            labelText: 'Player UID',
            hintText: 'e.g. u4X8zL9...',
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          if (coachController.scanError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              coachController.scanError!,
              style: AppTypography.bodySm.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Lookup Player',
            isLoading: coachController.isVerifyingPlayer,
            onPressed: () {
              final id = _manualIdController.text.trim();
              if (id.isNotEmpty) {
                _handlePlayerScanned(id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerConfirmationView(
      dynamic player, List<TrainingTemplateEntity> templates) {
    final hasZeroSessions = player.remainingSessions <= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player Identity Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgBorderRadius,
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    player.name,
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${player.phone} • ${player.category ?? 'Academy'} (${player.ageGroup ?? 'All'})',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge(
                        label: player.isAllowedPlayer ? 'AUTHORIZED' : 'SUSPENDED',
                        statusType: player.isAllowedPlayer
                            ? StatusType.active
                            : StatusType.debit,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      StatusBadge(
                        label: '${player.remainingSessions} SESSIONS LEFT',
                        statusType: hasZeroSessions
                            ? StatusType.debit
                            : StatusType.paid,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Balance: ${AppFormatters.formatCurrency(player.balance)}',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (hasZeroSessions)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: AppRadius.mdBorderRadius,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 24),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Warning: Player has 0 remaining sessions. Checking in will debit their balance.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onWarningContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Session Configuration
          Text(
            'Session Details',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Type toggle (Fitness vs Recovery)
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Physical Fitness')),
                  selected: _selectedType == 'fitness',
                  selectedColor: AppColors.primaryContainer,
                  onSelected: (val) {
                    if (val) setState(() => _selectedType = 'fitness');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Recovery & Rehab')),
                  selected: _selectedType == 'recovery',
                  selectedColor: AppColors.primaryContainer,
                  onSelected: (val) {
                    if (val) setState(() => _selectedType = 'recovery');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Optional Workout Template Selection
          if (templates.isNotEmpty) ...[
            DropdownButtonFormField<TrainingTemplateEntity?>(
              initialValue: _selectedTemplate,
              decoration: const InputDecoration(
                labelText: 'Assign Training Template (Optional)',
                hintText: 'Select a workout routine',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None (Standard Free Session)'),
                ),
                ...templates.map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text('${t.trainingName} (${t.category})'),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedTemplate = val);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Confirmation and Cancel Buttons
          AppButton(
            text: 'Confirm Check-in & Deduct Session',
            icon: Icons.check_circle_outline,
            size: AppButtonSize.large,
            isLoading: _isProcessing,
            onPressed: _confirmAttendance,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            text: 'Cancel / Scan Another',
            variant: AppButtonVariant.outline,
            onPressed: () {
              context.read<CoachController>().clearScannedPlayer();
            },
          ),
        ],
      ),
    );
  }
}
