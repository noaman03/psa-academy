import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class ExportButtonsRow extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onAddExpense;

  const ExportButtonsRow({
    super.key,
    required this.onExportPdf,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text(
            'Export PDF',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: mediumBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onExportPdf,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Expense',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onAddExpense,
        ),
      ],
    );
  }
}
