import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.category,
    required super.description,
    required super.amount,
    required super.date,
    super.paymentMethod,
    super.vendor,
    super.receiptUrl,
    super.notes,
    super.isRecurring = false,
    super.recurringFrequency,
    required super.createdAt,
    required super.createdBy,
    super.updatedAt,
  });

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      category: entity.category,
      description: entity.description,
      amount: entity.amount,
      date: entity.date,
      paymentMethod: entity.paymentMethod,
      vendor: entity.vendor,
      receiptUrl: entity.receiptUrl,
      notes: entity.notes,
      isRecurring: entity.isRecurring,
      recurringFrequency: entity.recurringFrequency,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      updatedAt: entity.updatedAt,
    );
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'],
      vendor: data['vendor'],
      receiptUrl: data['receiptUrl'],
      notes: data['notes'],
      isRecurring: data['isRecurring'] ?? false,
      recurringFrequency: data['recurringFrequency'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (vendor != null) 'vendor': vendor,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      if (notes != null) 'notes': notes,
      'isRecurring': isRecurring,
      if (recurringFrequency != null) 'recurringFrequency': recurringFrequency,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      category: category,
      description: description,
      amount: amount,
      date: date,
      paymentMethod: paymentMethod,
      vendor: vendor,
      receiptUrl: receiptUrl,
      notes: notes,
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
      createdAt: createdAt,
      createdBy: createdBy,
      updatedAt: updatedAt,
    );
  }
}
