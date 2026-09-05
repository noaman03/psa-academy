import 'package:dartz/dartz.dart';
import '../entities/payment_entity.dart';
import '../../core/errors/failures.dart';

abstract class PaymentRepository {
  /// Get payment by ID
  Future<Either<Failure, PaymentEntity>> getPaymentById(String paymentId);

  /// Create payment
  Future<Either<Failure, PaymentEntity>> createPayment(PaymentEntity payment);

  /// Update payment
  Future<Either<Failure, PaymentEntity>> updatePayment(PaymentEntity payment);

  /// Delete payment
  Future<Either<Failure, void>> deletePayment(String paymentId);

  /// Get payments by player ID
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByPlayerId(
      String playerId);

  /// Get payments by status
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByStatus(
      String status);

  /// Get payments by date range
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get overdue payments
  Future<Either<Failure, List<PaymentEntity>>> getOverduePayments();

  /// Get pending payments
  Future<Either<Failure, List<PaymentEntity>>> getPendingPayments();

  /// Get paid payments
  Future<Either<Failure, List<PaymentEntity>>> getPaidPayments();

  /// Mark payment as paid
  Future<Either<Failure, PaymentEntity>> markPaymentAsPaid(
    String paymentId,
    String paymentMethod,
    String? transactionId,
  );

  /// Get total payments amount by date range
  Future<Either<Failure, double>> getTotalPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get payment statistics
  Future<Either<Failure, Map<String, dynamic>>> getPaymentStatistics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Stream payments
  Stream<List<PaymentEntity>> watchPayments();
}
