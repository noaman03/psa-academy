import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreExpenseDataSource {
  final FirebaseFirestore _firestore;

  FirestoreExpenseDataSource(this._firestore);

  /// Get expense by ID
  Future<ExpenseModel> getExpenseById(String expenseId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(expenseId)
          .get();

      if (!doc.exists) {
        throw Exception('Expense not found');
      }

      return ExpenseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  /// Create expense
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.expensesCollection)
          .add(expense.toFirestore());

      final doc = await docRef.get();
      return ExpenseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  /// Update expense
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.expensesCollection)
          .doc(expense.id);

      await docRef.update(expense.toFirestore());

      final doc = await docRef.get();
      return ExpenseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore
          .collection(AppConstants.expensesCollection)
          .doc(expenseId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  /// Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  /// Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  /// Get recurring expenses
  Future<List<ExpenseModel>> getRecurringExpenses() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('isRecurring', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recurring expenses: $e');
    }
  }

  /// Get total expenses by date range
  Future<double> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total expenses: $e');
    }
  }

  /// Get total expenses by category
  Future<double> getTotalExpensesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('category', isEqualTo: category)
          .get();

      double total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        total += (data['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get total expenses: $e');
    }
  }

  /// Stream expenses
  Stream<List<ExpenseModel>> watchExpenses() {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromFirestore(doc))
            .toList());
  }
}
