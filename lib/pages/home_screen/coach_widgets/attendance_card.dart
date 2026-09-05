import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'scanned_player_card.dart';
import 'no_player_scanned_info.dart';

class AttendanceCard extends StatelessWidget {
  final String? scannedPlayerId;
  final VoidCallback? onClearPlayer;
  final VoidCallback onMarkAttendance;

  const AttendanceCard({
    super.key,
    required this.scannedPlayerId,
    this.onClearPlayer,
    required this.onMarkAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_turned_in, color: mediumBlue, size: 30),
                SizedBox(width: 12),
                Text(
                  'Mark Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Record player attendance and track session usage',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (scannedPlayerId != null)
              ScannedPlayerCard(onClear: onClearPlayer)
            else
              const NoPlayerScannedInfo(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Mark Attendance',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: scannedPlayerId != null ? onMarkAttendance : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
