import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class ScanCard extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;
  final IconData icon;

  const ScanCard({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
    this.icon = Icons.camera_alt,
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
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: mediumBlue, size: 30),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(icon, color: Colors.white),
              label: Text(
                buttonLabel,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: mediumBlue,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
