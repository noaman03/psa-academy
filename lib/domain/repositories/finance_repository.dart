import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../entities/expense_entity.dart';

class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netBalance;
  final int totalPaidTransactions;
  final int pendingCount;

  const FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netBalance,
    required this.totalPaidTransactions,
    required this.pendingCount,
  });
}

abstract class FinanceRepository {
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  });

  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  });

  Future<Either<Failure, ExpenseEntity>> addExpense({
    required String title,
    required String category,
    required double amount,
    String? notes,
    String? createdBy,
  });

  Future<Either<Failure, PaymentEntity>> addPayment(PaymentEntity payment);

  Future<Either<Failure, FinancialSummary>> getFinancialSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  Stream<List<PaymentEntity>> watchRecentPayments({int limit = 20});
  Stream<List<ExpenseEntity>> watchRecentExpenses({int limit = 20});
}
