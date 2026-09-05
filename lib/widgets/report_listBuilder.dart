import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ReportListBuilder extends ChangeNotifier {
  Widget buildFinanceReportList(
    List<Map<String, dynamic>> reportpayment,
    List<Map<String, dynamic>> reportexpenses,
    String title,
  ) {
    // Combine and sort all entries
    final allEntries = [
      ...reportpayment.map((p) => _FinanceEntry.fromPayment(p)),
      ...reportexpenses.map((e) => _FinanceEntry.fromExpense(e)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    // Group by formatted date
    final groupedEntries =
        groupBy(allEntries, (entry) => _formatDate(entry.date));

    // Get sorted dates (newest first)
    final dates = groupedEntries.keys.toList()
      ..sort((a, b) => DateFormat('MMMM d')
          .parse(b)
          .compareTo(DateFormat('MMMM d').parse(a)));

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final entries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            ...entries.map((entry) => _buildFinanceItem(entry)),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        date,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildFinanceItem(_FinanceEntry entry) {
    final dateFormat = DateFormat('jm').format(entry.date);

    if (entry.isExpense) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(entry.title),
        subtitle: Text(dateFormat),
        trailing: Text(
          '-EGP ${entry.amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return FutureBuilder<String>(
      future: loadplayername(entry.playerId),
      builder: (context, snapshot) {
        Color statusColor;
        if (entry.status == 'debit') {
          statusColor = Colors.red;
        } else if (entry.status == 'paid') {
          statusColor = Colors.green;
        } else {
          statusColor = Colors.black;
        }

        final content = snapshot.hasData ? snapshot.data! : 'Loading...';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(content),
          subtitle: Text(dateFormat),
          trailing: Text(
            '+EGP ${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(color: statusColor),
          ),
        );
      },
    );
  }

  // Attendance Report
  Widget buildAttendaceReportList(
      List<Map<String, dynamic>> reportAttendance, String title) {
    final grouped = groupBy(reportAttendance,
        (entry) => _formatDate((entry['date'] as Timestamp).toDate()));

    final dates = grouped.keys.toList()
      ..sort((a, b) => DateFormat('MMMM d')
          .parse(b)
          .compareTo(DateFormat('MMMM d').parse(a)));

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final entries = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            ...entries.map((entry) => _buildAttendanceItem(entry)),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> entry) {
    return FutureBuilder<String>(
      future: loadplayername(entry['playerId']),
      builder: (context, playerSnapshot) {
        return FutureBuilder<String>(
          future: loadCoachname(entry['coachId']),
          builder: (context, coachSnapshot) {
            final date =
                DateFormat('jm').format((entry['date'] as Timestamp).toDate());
            final playerName =
                playerSnapshot.hasData ? playerSnapshot.data! : 'Loading...';
            final coachName =
                coachSnapshot.hasData ? coachSnapshot.data! : 'Loading...';
            final workout = entry['workout'] ?? 'No workout';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(playerName),
              subtitle: Row(
                children: [
                  Text(date),
                  const SizedBox(width: 8),
                  Text(coachName),
                  const SizedBox(width: 8),
                  Text(workout),
                ],
              ),
              onTap: () => _updateWorkout(context, entry),
            );
          },
        );
      },
    );
  }

  void _updateWorkout(BuildContext context, Map<String, dynamic> entry) {
    showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('trainingTemplates')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No training templates available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              final templates = snapshot.data!.docs;

              return ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final data = template.data();
                  final trainingName =
                      data['trainingName'] ?? 'Unnamed Training';
                  final description = data['description'] ?? '';

                  return Card(
                    margin: const EdgeInsets.all(12.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        trainingName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              // Show template details in a dialog
                              // _showTemplateDetailsDialog(context, template);
                            },
                            icon: const Icon(Icons.remove_red_eye_outlined,
                                color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        });
  }

  String _formatDate(DateTime date) => DateFormat('MMMM d').format(date);

  // Existing player loading method
  final String _name = '';
  String get name => _name;

  Future<String> loadplayername(String uid) async {
    DocumentSnapshot player =
        await FirebaseFirestore.instance.collection('players').doc(uid).get();
    return player.exists ? player['name'] ?? 'Unknown' : 'Unknown';
  }

  Future<String> loadCoachname(String uid) async {
    DocumentSnapshot coach =
        await FirebaseFirestore.instance.collection('coaches').doc(uid).get();
    return coach.exists ? coach['name'] ?? 'Unknown' : 'Unknown';
  }
}

class _FinanceEntry {
  final bool isExpense;
  final String title;
  final String playerId;
  final double amount;
  final DateTime date;
  final String status;

  _FinanceEntry({
    required this.isExpense,
    required this.title,
    required this.playerId,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory _FinanceEntry.fromPayment(Map<String, dynamic> payment) {
    return _FinanceEntry(
      isExpense: false,
      title: '',
      playerId: payment['playerId'],
      amount: (payment['amount'] as num).toDouble(),
      date: (payment['date'] as Timestamp).toDate(),
      status: payment['status'],
    );
  }

  factory _FinanceEntry.fromExpense(Map<String, dynamic> expense) {
    return _FinanceEntry(
      isExpense: true,
      title: expense['title'],
      playerId: '',
      amount: (expense['amount'] as num).toDouble(),
      date: (expense['date'] as Timestamp).toDate(),
      status: '',
    );
  }
}
