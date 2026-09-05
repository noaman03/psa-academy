import 'package:dartz/dartz.dart';
import '../entities/expense_entity.dart';
import '../../core/errors/failures.dart';

abstract class ExpenseRepository {
  /// Get expense by ID
  Future<Either<Failure, ExpenseEntity>> getExpenseById(String expenseId);

  /// Create expense
  Future<Either<Failure, ExpenseEntity>> createExpense(ExpenseEntity expense);

  /// Update expense
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense);

  /// Delete expense
  Future<Either<Failure, void>> deleteExpense(String expenseId);

  /// Get all expenses
  Future<Either<Failure, List<ExpenseEntity>>> getAllExpenses();

  /// Get expenses by category
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByCategory(
      String category);

  /// Get expenses by date range
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get recurring expenses
  Future<Either<Failure, List<ExpenseEntity>>> getRecurringExpenses();

  /// Get total expenses by date range
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get total expenses by category
  Future<Either<Failure, double>> getTotalExpensesByCategory(String category);

  /// Get expense statistics
  Future<Either<Failure, Map<String, dynamic>>> getExpenseStatistics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Stream expenses
  Stream<List<ExpenseEntity>> watchExpenses();
}
