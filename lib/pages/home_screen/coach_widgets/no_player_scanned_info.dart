import 'package:flutter/material.dart';

class NoPlayerScannedInfo extends StatelessWidget {
  const NoPlayerScannedInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No player scanned yet. Go to the Check-In tab to scan a player.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
