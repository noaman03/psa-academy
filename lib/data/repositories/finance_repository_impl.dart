import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../models/expense_model.dart';
import '../models/payment_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FirebaseFirestore _firestore;

  FinanceRepositoryImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collection('payments');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.limit(limit).get();
      final list = snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch payments: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collection('expenses');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.limit(limit).get();
      final list = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch expenses: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense({
    required String title,
    required String category,
    required double amount,
    String? notes,
    String? createdBy,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection('expenses').add({
        'title': title.trim(),
        'category': category.trim(),
        'amount': amount,
        'date': Timestamp.fromDate(now),
        if (notes != null) 'notes': notes.trim(),
        'createdAt': Timestamp.fromDate(now),
        if (createdBy != null) 'createdBy': createdBy,
      });

      return Right(
        ExpenseModel(
          id: docRef.id,
          title: title,
          category: category,
          amount: amount,
          date: now,
          notes: notes,
          createdAt: now,
          createdBy: createdBy,
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure('Failed to add expense: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> addPayment(PaymentEntity payment) async {
    try {
      final model = PaymentModel(
        id: payment.id,
        playerId: payment.playerId,
        playerName: payment.playerName,
        amount: payment.amount,
        status: payment.status,
        date: payment.date,
        type: payment.type,
        paymentMethod: payment.paymentMethod,
        notes: payment.notes,
        createdAt: payment.createdAt,
      );

      final docRef = await _firestore.collection('payments').add(model.toFirestore());
      return Right(
        PaymentModel(
          id: docRef.id,
          playerId: payment.playerId,
          playerName: payment.playerName,
          amount: payment.amount,
          status: payment.status,
          date: payment.date,
          type: payment.type,
          paymentMethod: payment.paymentMethod,
          notes: payment.notes,
          createdAt: payment.createdAt,
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure('Failed to record payment: $e'));
    }
  }

  @override
  Future<Either<Failure, FinancialSummary>> getFinancialSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final paymentsResult = await getPayments(startDate: startDate, endDate: endDate);
      final expensesResult = await getExpenses(startDate: startDate, endDate: endDate);

      return paymentsResult.fold(
        (l) => Left(l),
        (payments) => expensesResult.fold(
          (l) => Left(l),
          (expenses) {
            final double totalRevenue = payments
                .where((p) => p.status.toLowerCase() == 'paid')
                .fold(0.0, (acc, p) => acc + p.amount);

            final double totalExpenses =
                expenses.fold(0.0, (acc, e) => acc + e.amount);

            final int paidCount =
                payments.where((p) => p.status.toLowerCase() == 'paid').length;

            final int pendingCount = payments
                .where((p) =>
                    p.status.toLowerCase() == 'pending' ||
                    p.status.toLowerCase() == 'debit')
                .length;

            return Right(
              FinancialSummary(
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
                netBalance: totalRevenue - totalExpenses,
                totalPaidTransactions: paidCount,
                pendingCount: pendingCount,
              ),
            );
          },
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure('Failed to calculate financial summary: $e'));
    }
  }

  @override
  Stream<List<PaymentEntity>> watchRecentPayments({int limit = 20}) {
    return _firestore
        .collection('payments')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs
            .map((d) => PaymentModel.fromFirestore(d))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)));
  }

  @override
  Stream<List<ExpenseEntity>> watchRecentExpenses({int limit = 20}) {
    return _firestore
        .collection('expenses')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ExpenseModel.fromFirestore(d))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)));
  }
}
