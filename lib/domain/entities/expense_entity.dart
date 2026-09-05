import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final String category; // 'Rent', 'Utilities', 'Salaries', 'Equipment', 'Other'
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        amount,
        date,
        notes,
        createdAt,
        createdBy,
      ];
}
