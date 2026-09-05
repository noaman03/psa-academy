import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.playerId,
    required super.playerName,
    required super.amount,
    required super.type,
    required super.status,
    required super.dueDate,
    super.paidDate,
    super.paymentMethod,
    super.transactionId,
    super.notes,
    super.receiptUrl,
    required super.createdAt,
    super.createdBy,
  });

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      playerId: entity.playerId,
      playerName: entity.playerName,
      amount: entity.amount,
      type: entity.type,
      status: entity.status,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      paymentMethod: entity.paymentMethod,
      transactionId: entity.transactionId,
      notes: entity.notes,
      receiptUrl: entity.receiptUrl,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      playerId: data['playerId'] ?? '',
      playerName: data['playerName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? '',
      status: data['status'] ?? 'pending',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      notes: data['notes'],
      receiptUrl: data['receiptUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'amount': amount,
      'type': type,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      if (paidDate != null) 'paidDate': Timestamp.fromDate(paidDate!),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (transactionId != null) 'transactionId': transactionId,
      if (notes != null) 'notes': notes,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      if (createdBy != null) 'createdBy': createdBy,
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      playerId: playerId,
      playerName: playerName,
      amount: amount,
      type: type,
      status: status,
      dueDate: dueDate,
      paidDate: paidDate,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      notes: notes,
      receiptUrl: receiptUrl,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
