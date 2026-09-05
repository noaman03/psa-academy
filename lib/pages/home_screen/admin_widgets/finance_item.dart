import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class FinanceEntry {
  final bool isExpense;
  final String title;
  final String playerId;
  final double amount;
  final DateTime date;
  final String status;

  FinanceEntry({
    required this.isExpense,
    required this.title,
    required this.playerId,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory FinanceEntry.fromPayment(Map<String, dynamic> payment) {
    return FinanceEntry(
      isExpense: false,
      title: '',
      playerId: payment['playerId'],
      amount: (payment['amount'] as num).toDouble(),
      date: (payment['date'] as dynamic).toDate(),
      status: payment['status'],
    );
  }

  factory FinanceEntry.fromExpense(Map<String, dynamic> expense) {
    return FinanceEntry(
      isExpense: true,
      title: expense['title'],
      playerId: '',
      amount: (expense['amount'] as num).toDouble(),
      date: (expense['date'] as dynamic).toDate(),
      status: '',
    );
  }
}

class FinanceItem extends StatelessWidget {
  final FinanceEntry entry;
  final Future<String> Function(String) fetchPlayerName;

  const FinanceItem({
    super.key,
    required this.entry,
    required this.fetchPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('h:mm a').format(entry.date);

    if (entry.isExpense) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_downward, color: Colors.red),
          ),
          title: Text(entry.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(dateFormat),
          trailing: Text(
            '-EGP ${entry.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return FutureBuilder<String>(
      future: fetchPlayerName(entry.playerId),
      builder: (context, snapshot) {
        final playerName = snapshot.data ?? 'Loading...';
        final isPaid = entry.status == 'paid';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPaid ? Icons.arrow_upward : Icons.pending,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(playerName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(dateFormat),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+EGP ${entry.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Pending',
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DateHeader extends StatelessWidget {
  final String date;

  const DateHeader({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        date,
        style: const TextStyle(
          color: darkBlue,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
