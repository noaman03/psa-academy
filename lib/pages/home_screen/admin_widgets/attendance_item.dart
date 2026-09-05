import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class AttendanceItem extends StatelessWidget {
  final Map<String, dynamic> entry;
  final Future<String> Function(String) fetchPlayerName;
  final Future<String> Function(String) fetchCoachName;
  final void Function(BuildContext, Map<String, dynamic>) onUpdateWorkout;

  const AttendanceItem({
    super.key,
    required this.entry,
    required this.fetchPlayerName,
    required this.fetchCoachName,
    required this.onUpdateWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchPlayerName(entry['playerId']),
      builder: (context, playerSnapshot) {
        return FutureBuilder<String>(
          future: fetchCoachName(entry['coachId']),
          builder: (context, coachSnapshot) {
            final playerName = playerSnapshot.data ?? 'Loading...';
            final coachName = coachSnapshot.data ?? 'Loading...';
            final date = (entry['date'] as Timestamp).toDate();
            final dateStr = DateFormat('h:mm a').format(date);
            final workout = entry['workout'] ?? 'No workout';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mediumBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: mediumBlue),
                ),
                title: Text(
                  playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach: $coachName'),
                    Text(dateStr,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: workout == 'No workout'
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        workout == 'No workout' ? 'Pending' : 'Assigned',
                        style: TextStyle(
                          color: workout == 'No workout'
                              ? Colors.orange
                              : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => onUpdateWorkout(context, entry),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
