import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class ExportButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const ExportButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.picture_as_pdf,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: mediumBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
