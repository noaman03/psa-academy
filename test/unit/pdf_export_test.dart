import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/utils/pdf/platform_pdf_export.dart';
import 'package:psa_academy/domain/entities/expense_entity.dart';
import 'package:psa_academy/domain/entities/payment_entity.dart';
import 'package:psa_academy/domain/repositories/finance_repository.dart';

void main() {
  group('PDF Export Validation Tests', () {
    test('generateFinanceSummaryPdf generates valid non-empty PDF bytes', () async {
      const summary = FinancialSummary(
        totalRevenue: 2300.0,
        totalExpenses: 1050.0,
        netBalance: 1250.0,
        totalPaidTransactions: 2,
        pendingCount: 0,
      );

      final payments = [
        PaymentEntity(
          id: 'pay-1',
          playerId: 'player-1',
          playerName: 'Active Staging Player',
          amount: 1500.0,
          status: 'paid',
          date: DateTime(2026, 9, 1),
          createdAt: DateTime(2026, 9, 1),
        ),
        PaymentEntity(
          id: 'pay-2',
          playerId: 'player-2',
          playerName: 'Zero Sessions Player',
          amount: 800.0,
          status: 'paid',
          date: DateTime(2026, 9, 2),
          createdAt: DateTime(2026, 9, 2),
        ),
      ];

      final expenses = [
        ExpenseEntity(
          id: 'exp-1',
          title: 'Training Cones and Speed Ladders',
          category: 'Equipment',
          amount: 450.0,
          date: DateTime(2026, 9, 3),
          createdAt: DateTime(2026, 9, 3),
          createdBy: 'admin-1',
        ),
        ExpenseEntity(
          id: 'exp-2',
          title: 'Pitch Floodlights Maintenance',
          category: 'Facility',
          amount: 600.0,
          date: DateTime(2026, 9, 4),
          createdAt: DateTime(2026, 9, 4),
          createdBy: 'admin-1',
        ),
      ];

      final bytes = await PlatformPdfExport.generateFinanceSummaryPdf(
        summary: summary,
        payments: payments,
        expenses: expenses,
        dateRangeLabel: 'September 2026',
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(1000));

      // PDF specification magic bytes: %PDF- (0x25 0x50 0x44 0x46 0x2D)
      final headerString = String.fromCharCodes(bytes.take(5));
      expect(headerString, equals('%PDF-'));
    });
  });
}
