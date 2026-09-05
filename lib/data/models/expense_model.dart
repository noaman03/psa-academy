import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.category,
    required super.amount,
    required super.date,
    super.notes,
    required super.createdAt,
    super.createdBy,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    // Backward-compatible title/description/reason parsing
    final String title = data['title'] ??
        data['reason'] ??
        data['description'] ??
        'Academy Expense';

    final String category = data['category'] ?? 'General';

    final rawAmount = data['amount'] ?? 0;
    final double amount = rawAmount is num ? rawAmount.toDouble() : 0.0;

    final parsedDate = parseRequiredDateTime(data['date']);

    return ExpenseModel(
      id: doc.id,
      title: title,
      category: category,
      amount: amount,
      date: parsedDate,
      notes: data['notes'],
      createdAt: parseRequiredDateTime(data['createdAt'], parsedDate),
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (createdBy != null) 'createdBy': createdBy,
    };
  }
}
