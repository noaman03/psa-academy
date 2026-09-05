import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.playerId,
    super.playerName = '',
    required super.amount,
    super.status = 'paid',
    required super.date,
    super.type,
    super.paymentMethod,
    super.notes,
    required super.createdAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    final rawAmount = data['amount'] ?? 0;
    final double amount = rawAmount is num ? rawAmount.toDouble() : 0.0;

    final parsedDate = parseSafeDateTime(data['date']) ??
        parseSafeDateTime(data['dueDate']) ??
        parseSafeDateTime(data['paidDate']) ??
        DateTime.now();

    return PaymentModel(
      id: doc.id,
      playerId: data['playerId'] ?? '',
      playerName: data['playerName'] ?? '',
      amount: amount,
      status: data['status'] ?? 'paid',
      date: parsedDate,
      type: data['type'],
      paymentMethod: data['paymentMethod'] ?? 'cash',
      notes: data['notes'],
      createdAt: parseRequiredDateTime(data['createdAt'], parsedDate),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'amount': amount,
      'status': status,
      'date': Timestamp.fromDate(date),
      if (type != null) 'type': type,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
