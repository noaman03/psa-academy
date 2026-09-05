import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../../core/constants/app_constants.dart';

class FirestorePaymentDataSource {
  final FirebaseFirestore _firestore;

  FirestorePaymentDataSource(this._firestore);

  /// Get payment by ID
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .get();

      if (!doc.exists) {
        throw Exception('Payment not found');
      }

      return PaymentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  /// Create payment
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.paymentsCollection)
          .add(payment.toFirestore());

      final doc = await docRef.get();
      return PaymentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Update payment
  Future<PaymentModel> updatePayment(PaymentModel payment) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(payment.id);

      await docRef.update(payment.toFirestore());

      final doc = await docRef.get();
      return PaymentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  /// Delete payment
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  /// Get payments by player ID
  Future<List<PaymentModel>> getPaymentsByPlayerId(String playerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('playerId', isEqualTo: playerId)
          .orderBy('dueDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  /// Get payments by status
  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('status', isEqualTo: status)
          .orderBy('dueDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  /// Get payments by date range
  Future<List<PaymentModel>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('dueDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  /// Get overdue payments
  Future<List<PaymentModel>> getOverduePayments() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('status', isEqualTo: 'pending')
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('dueDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue payments: $e');
    }
  }

  /// Get pending payments
  Future<List<PaymentModel>> getPendingPayments() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('status', isEqualTo: 'pending')
          .orderBy('dueDate')
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending payments: $e');
    }
  }

  /// Get paid payments
  Future<List<PaymentModel>> getPaidPayments() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('status', isEqualTo: 'paid')
          .orderBy('paidDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paid payments: $e');
    }
  }

  /// Mark payment as paid
  Future<PaymentModel> markPaymentAsPaid(
    String paymentId,
    String paymentMethod,
    String? transactionId,
  ) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.paymentsCollection).doc(paymentId);

      await docRef.update({
        'status': 'paid',
        'paidDate': Timestamp.fromDate(DateTime.now()),
        'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
      });

      final doc = await docRef.get();
      return PaymentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to mark payment as paid: $e');
    }
  }

  /// Get total payments amount by date range
  Future<double> getTotalPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('status', isEqualTo: 'paid')
          .where('paidDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('paidDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total payments: $e');
    }
  }

  /// Stream payments
  Stream<List<PaymentModel>> watchPayments() {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }
}
