import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/pdf/platform_pdf_export.dart';
import '../../../controllers/admin_controller.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/empty_state.dart';

class AdminFinanceTab extends StatefulWidget {
  const AdminFinanceTab({super.key});

  @override
  State<AdminFinanceTab> createState() => _AdminFinanceTabState();
}

class _AdminFinanceTabState extends State<AdminFinanceTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadFinanceData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyPresetFilter(String filter) {
    setState(() => _activeFilter = filter);
    final now = DateTime.now();
    if (filter == 'Today') {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (filter == 'This Month') {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else {
      _startDate = null;
      _endDate = null;
    }
    context.read<AdminController>().loadFinanceData(
          start: _startDate,
          end: _endDate,
        );
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String category = 'Equipment';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Record New Expense',
              style: AppTypography.headlineSm.copyWith(fontSize: 18),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: titleController,
                      labelText: 'Expense Title / Description',
                      hintText: 'e.g. New Footballs set',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: amountController,
                      labelText: 'Amount (EGP)',
                      hintText: '500',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter amount';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Equipment', child: Text('Equipment')),
                        DropdownMenuItem(value: 'Salaries', child: Text('Salaries')),
                        DropdownMenuItem(value: 'Rent', child: Text('Rent & Facility')),
                        DropdownMenuItem(value: 'Utilities', child: Text('Utilities')),
                        DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: notesController,
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional details...',
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
                text: 'Save Expense',
                size: AppButtonSize.small,
                isLoading: isSaving,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  setDialogState(() => isSaving = true);
                  final amt = double.parse(amountController.text.trim());
                  final ok = await context.read<AdminController>().addExpense(
                        title: titleController.text.trim(),
                        category: category,
                        amount: amt,
                        notes: notesController.text.trim(),
                      );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Expense recorded successfully.'
                            : 'Failed to record expense.'),
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

  Future<void> _exportPdfReport() async {
    final admin = context.read<AdminController>();
    final summary = admin.financialSummary;
    final payments = admin.paymentsState.data ?? [];
    final expenses = admin.expensesState.data ?? [];

    if (summary == null) return;

    try {
      final bytes = await PlatformPdfExport.generateFinanceSummaryPdf(
        summary: summary,
        payments: payments,
        expenses: expenses,
        dateRangeLabel: _activeFilter,
      );

      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      await PlatformPdfExport.savePdf(bytes, 'psa_finance_report_$dateStr.pdf');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Financial report exported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();
    final summary = adminController.financialSummary;
    final paymentsState = adminController.paymentsState;
    final expensesState = adminController.expensesState;

    return Column(
      children: [
        // Summary & Actions Top Bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter Chips
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: ['All', 'This Month', 'Today'].map((filter) {
                      final isSelected = _activeFilter == filter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) => _applyPresetFilter(filter),
                      );
                    }).toList(),
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Export PDF',
                        icon: Icons.picture_as_pdf_outlined,
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.small,
                        onPressed: _exportPdfReport,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppButton(
                        text: 'Record Expense',
                        icon: Icons.add,
                        size: AppButtonSize.small,
                        onPressed: _showAddExpenseDialog,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // KPI Cards Strip
              if (summary != null)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer.withValues(alpha: 0.3),
                          borderRadius: AppRadius.mdBorderRadius,
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Revenue',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatCurrency(summary.totalRevenue),
                              style: AppTypography.titleLg.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.3),
                          borderRadius: AppRadius.mdBorderRadius,
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Expenses',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatCurrency(summary.totalExpenses),
                              style: AppTypography.titleLg.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: AppRadius.mdBorderRadius,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Balance',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatCurrency(summary.netBalance),
                              style: AppTypography.titleLg.copyWith(
                                color: summary.netBalance >= 0
                                    ? AppColors.primary
                                    : AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Payments & Revenue'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Payments Tab View
              paymentsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (paymentsState.data == null || paymentsState.data!.isEmpty)
                      ? const EmptyState(
                          title: 'No Payments Recorded',
                          description:
                              'Payments added or deducted will appear here.',
                          icon: Icons.payments_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: paymentsState.data!.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = paymentsState.data![index];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.successContainer,
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                p.playerName.isNotEmpty
                                    ? p.playerName
                                    : 'Player #${p.playerId.substring(0, p.playerId.length > 5 ? 5 : p.playerId.length)}',
                                style: AppTypography.labelLg,
                              ),
                              subtitle: Text(
                                '${DateFormat('dd MMM yyyy, hh:mm a').format(p.date)} • ${p.notes ?? 'Payment'}',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: Text(
                                '+${AppFormatters.formatCurrency(p.amount)}',
                                style: AppTypography.labelLg.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          },
                        ),

              // Expenses Tab View
              expensesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (expensesState.data == null || expensesState.data!.isEmpty)
                      ? const EmptyState(
                          title: 'No Expenses Recorded',
                          description:
                              'Click "Record Expense" to register operations costs.',
                          icon: Icons.receipt_long_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: expensesState.data!.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final e = expensesState.data![index];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.errorContainer,
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                              ),
                              title: Text(e.title, style: AppTypography.labelLg),
                              subtitle: Text(
                                '${DateFormat('dd MMM yyyy').format(e.date)} • Category: ${e.category}${e.notes != null ? ' • ${e.notes}' : ''}',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: Text(
                                '-${AppFormatters.formatCurrency(e.amount)}',
                                style: AppTypography.labelLg.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
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
