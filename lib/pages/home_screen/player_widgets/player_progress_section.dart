import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'progress_stat_card.dart';

class PlayerProgressSection extends StatelessWidget {
  final int sessionsPaid;
  final int sessionsAttended;

  const PlayerProgressSection({
    super.key,
    required this.sessionsPaid,
    required this.sessionsAttended,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        sessionsPaid > 0 ? sessionsAttended / sessionsPaid : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProgressStatCard(
              title: 'Paid Sessions',
              value: '$sessionsPaid',
              icon: Icons.check_circle,
              color: mediumBlue,
            ),
            ProgressStatCard(
              title: 'Attended Sessions',
              value: '$sessionsAttended',
              icon: Icons.emoji_events,
              color: mediumBlue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(mediumBlue),
          minHeight: 12,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(1)}% Completed',
              style: const TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
