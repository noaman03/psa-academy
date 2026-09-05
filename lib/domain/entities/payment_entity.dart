import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String playerId;
  final String playerName;
  final double amount;
  final String status; // 'paid', 'pending', 'debit'
  final DateTime date;
  final String? type; // 'subscription', 'session_pack', 'recovery', 'single_session'
  final String? paymentMethod; // 'cash', 'card', 'bank_transfer'
  final String? notes;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.playerId,
    this.playerName = '',
    required this.amount,
    this.status = 'paid',
    required this.date,
    this.type,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        playerId,
        playerName,
        amount,
        status,
        date,
        type,
        paymentMethod,
        notes,
        createdAt,
      ];
}
