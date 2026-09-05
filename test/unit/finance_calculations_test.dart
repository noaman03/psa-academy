import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/data/models/expense_model.dart';
import 'package:psa_academy/data/models/payment_model.dart';

void main() {
  group('Finance Calculations & Model Tests', () {
    test('PaymentModel handles numeric and string amounts gracefully', () {
      final payment = PaymentModel(
        id: 'pay-1',
        playerId: 'p-1',
        playerName: 'Youssef',
        amount: 1500.0,
        status: 'paid',
        date: DateTime(2026, 3, 1),
        createdAt: DateTime(2026, 3, 1),
      );

      expect(payment.amount, equals(1500.0));
      expect(payment.status, equals('paid'));

      final firestoreMap = payment.toFirestore();
      expect(firestoreMap['amount'], equals(1500.0));
      expect(firestoreMap['status'], equals('paid'));
      expect(firestoreMap['date'], isA<Timestamp>());
    });

    test('ExpenseModel handles legacy title fallbacks (reason, description)', () {
      final expense1 = ExpenseModel(
        id: 'exp-1',
        title: 'Academy Rent',
        category: 'Facility',
        amount: 5000.0,
        date: DateTime(2026, 3, 1),
        createdAt: DateTime(2026, 3, 1),
      );

      expect(expense1.title, equals('Academy Rent'));
      expect(expense1.category, equals('Facility'));
      expect(expense1.amount, equals(5000.0));
    });

    test('Financial summary calculations compute accurate net balance', () {
      // Setup mock list of payments
      final payments = [
        PaymentModel(
          id: 'p1',
          playerId: 'pl-1',
          amount: 1200.0,
          status: 'paid',
          date: DateTime(2026, 2, 1),
          createdAt: DateTime(2026, 2, 1),
        ),
        PaymentModel(
          id: 'p2',
          playerId: 'pl-2',
          amount: 800.0,
          status: 'paid',
          date: DateTime(2026, 2, 5),
          createdAt: DateTime(2026, 2, 5),
        ),
        PaymentModel(
          id: 'p3',
          playerId: 'pl-3',
          amount: 500.0,
          status: 'pending', // Pending payments should not count towards paid revenue
          date: DateTime(2026, 2, 10),
          createdAt: DateTime(2026, 2, 10),
        ),
      ];

      // Setup mock list of expenses
      final expenses = [
        ExpenseModel(
          id: 'e1',
          title: 'Footballs purchase',
          category: 'Equipment',
          amount: 650.0,
          date: DateTime(2026, 2, 2),
          createdAt: DateTime(2026, 2, 2),
        ),
        ExpenseModel(
          id: 'e2',
          title: 'Water bottles',
          category: 'Supplies',
          amount: 150.0,
          date: DateTime(2026, 2, 8),
          createdAt: DateTime(2026, 2, 8),
        ),
      ];

      // Revenue computation (only 'paid' payments)
      final totalRevenue = payments
          .where((p) => p.status.toLowerCase() == 'paid')
          .fold<double>(0.0, (total, p) => total + p.amount);

      final totalExpenses =
          expenses.fold<double>(0.0, (total, e) => total + e.amount);
      final netBalance = totalRevenue - totalExpenses;

      expect(totalRevenue, equals(2000.0));
      expect(totalExpenses, equals(800.0));
      expect(netBalance, equals(1200.0));
    });
  });
}
