import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String playerId;
  final String playerName;
  final double amount;
  final String
      type; // 'monthly', 'session', 'registration', 'equipment', 'other'
  final String status; // 'pending', 'paid', 'overdue', 'cancelled'
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? paymentMethod; // 'cash', 'card', 'transfer', 'check'
  final String? transactionId;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final String? createdBy;

  const PaymentEntity({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.amount,
    required this.type,
    required this.status,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        playerId,
        playerName,
        amount,
        type,
        status,
        dueDate,
        paidDate,
        paymentMethod,
        transactionId,
        notes,
        receiptUrl,
        createdAt,
        createdBy,
      ];

  PaymentEntity copyWith({
    String? id,
    String? playerId,
    String? playerName,
    double? amount,
    String? type,
    String? status,
    DateTime? dueDate,
    DateTime? paidDate,
    String? paymentMethod,
    String? transactionId,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue =>
      status == 'overdue' ||
      (status == 'pending' && DateTime.now().isAfter(dueDate));
  bool get isCancelled => status == 'cancelled';

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }
}
