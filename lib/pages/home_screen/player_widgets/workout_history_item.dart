import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class WorkoutHistoryItem extends StatelessWidget {
  final QueryDocumentSnapshot attendanceDoc;
  final int index;
  final VoidCallback onTap;

  const WorkoutHistoryItem({
    super.key,
    required this.attendanceDoc,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Timestamp timestamp = attendanceDoc['date'];
    final DateTime dateTime = timestamp.toDate();
    final formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    final workout = attendanceDoc['workout'] ?? 'No workout';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: const Icon(Icons.history, color: mediumBlue),
          title: Text(
            'Session ${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: darkBlue,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: darkBlue,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  workout,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(formattedTime),
            ],
          ),
        ),
      ),
    );
  }
}
