import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/firestore_expense_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirestoreExpenseDataSource dataSource;

  ExpenseRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, ExpenseEntity>> getExpenseById(
      String expenseId) async {
    try {
      final expense = await dataSource.getExpenseById(expenseId);
      return Right(expense.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> createExpense(
      ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final created = await dataSource.createExpense(expenseModel);
      return Right(created.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> updateExpense(
      ExpenseEntity expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final updated = await dataSource.updateExpense(expenseModel);
      return Right(updated.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await dataSource.deleteExpense(expenseId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getAllExpenses() async {
    try {
      final expenses = await dataSource.getAllExpenses();
      return Right(expenses.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByCategory(
    String category,
  ) async {
    try {
      final expenses = await dataSource.getExpensesByCategory(category);
      return Right(expenses.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses =
          await dataSource.getExpensesByDateRange(startDate, endDate);
      return Right(expenses.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getRecurringExpenses() async {
    try {
      final expenses = await dataSource.getRecurringExpenses();
      return Right(expenses.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final total =
          await dataSource.getTotalExpensesByDateRange(startDate, endDate);
      return Right(total);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpensesByCategory(
      String category) async {
    try {
      final total = await dataSource.getTotalExpensesByCategory(category);
      return Right(total);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses =
          await dataSource.getExpensesByDateRange(startDate, endDate);

      final total = expenses.length;
      final totalAmount = expenses.fold<double>(0, (sum, e) => sum + e.amount);

      // Group by category
      final categoryTotals = <String, double>{};
      for (var expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      // Get recurring expenses count
      final recurringCount = expenses.where((e) => e.isRecurring).length;

      return Right({
        'total': total,
        'totalAmount': totalAmount,
        'categoryBreakdown': categoryTotals,
        'recurringCount': recurringCount,
        'averageExpense': total > 0 ? totalAmount / total : 0.0,
      });
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<ExpenseEntity>> watchExpenses() {
    return dataSource.watchExpenses().map(
          (expenses) => expenses.map((e) => e.toEntity()).toList(),
        );
  }
}
