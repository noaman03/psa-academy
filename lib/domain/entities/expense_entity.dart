import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String
      category; // 'equipment', 'utilities', 'salary', 'maintenance', 'marketing', 'other'
  final String description;
  final double amount;
  final DateTime date;
  final String? paymentMethod;
  final String? vendor;
  final String? receiptUrl;
  final String? notes;
  final bool isRecurring;
  final String? recurringFrequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.paymentMethod,
    this.vendor,
    this.receiptUrl,
    this.notes,
    this.isRecurring = false,
    this.recurringFrequency,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        description,
        amount,
        date,
        paymentMethod,
        vendor,
        receiptUrl,
        notes,
        isRecurring,
        recurringFrequency,
        createdAt,
        createdBy,
        updatedAt,
      ];

  ExpenseEntity copyWith({
    String? id,
    String? category,
    String? description,
    double? amount,
    DateTime? date,
    String? paymentMethod,
    String? vendor,
    String? receiptUrl,
    String? notes,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vendor: vendor ?? this.vendor,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
