import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/firestore_payment_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirestorePaymentDataSource dataSource;

  PaymentRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentById(
      String paymentId) async {
    try {
      final payment = await dataSource.getPaymentById(paymentId);
      return Right(payment.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> createPayment(
      PaymentEntity payment) async {
    try {
      final paymentModel = PaymentModel.fromEntity(payment);
      final created = await dataSource.createPayment(paymentModel);
      return Right(created.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> updatePayment(
      PaymentEntity payment) async {
    try {
      final paymentModel = PaymentModel.fromEntity(payment);
      final updated = await dataSource.updatePayment(paymentModel);
      return Right(updated.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(String paymentId) async {
    try {
      await dataSource.deletePayment(paymentId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByPlayerId(
    String playerId,
  ) async {
    try {
      final payments = await dataSource.getPaymentsByPlayerId(playerId);
      return Right(payments.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByStatus(
      String status) async {
    try {
      final payments = await dataSource.getPaymentsByStatus(status);
      return Right(payments.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final payments =
          await dataSource.getPaymentsByDateRange(startDate, endDate);
      return Right(payments.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getOverduePayments() async {
    try {
      final payments = await dataSource.getOverduePayments();
      return Right(payments.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPendingPayments() async {
    try {
      final payments = await dataSource.getPendingPayments();
      return Right(payments.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaidPayments() async {
    try {
      final payments = await dataSource.getPaidPayments();
      return Right(payments.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> markPaymentAsPaid(
    String paymentId,
    String paymentMethod,
    String? transactionId,
  ) async {
    try {
      final payment = await dataSource.markPaymentAsPaid(
        paymentId,
        paymentMethod,
        transactionId,
      );
      return Right(payment.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final total =
          await dataSource.getTotalPaymentsByDateRange(startDate, endDate);
      return Right(total);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaymentStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final payments =
          await dataSource.getPaymentsByDateRange(startDate, endDate);

      final total = payments.length;
      final paid = payments.where((p) => p.status == 'paid').length;
      final pending = payments.where((p) => p.status == 'pending').length;
      final overdue = payments.where((p) => p.isOverdue).length;

      final totalAmount = payments.fold<double>(
        0,
        (sum, p) => sum + p.amount,
      );
      final paidAmount = payments
          .where((p) => p.status == 'paid')
          .fold<double>(0, (sum, p) => sum + p.amount);
      final pendingAmount = payments
          .where((p) => p.status == 'pending')
          .fold<double>(0, (sum, p) => sum + p.amount);

      return Right({
        'total': total,
        'paid': paid,
        'pending': pending,
        'overdue': overdue,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'pendingAmount': pendingAmount,
        'collectionRate': total > 0 ? (paid / total * 100) : 0.0,
      });
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<PaymentEntity>> watchPayments() {
    return dataSource.watchPayments().map(
          (payments) => payments.map((p) => p.toEntity()).toList(),
        );
  }
}
