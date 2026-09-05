import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;

  const DateRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildDateButton(
                text: startDate != null
                    ? DateFormat('MMM dd').format(startDate!)
                    : 'Start Date',
                onPressed: onPickStartDate,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, color: mediumBlue, size: 20),
            ),
            Expanded(
              child: _buildDateButton(
                text: endDate != null
                    ? DateFormat('MMM dd').format(endDate!)
                    : 'End Date',
                onPressed: onPickEndDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(
      {required String text, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 18, color: mediumBlue),
      label: Text(
        text,
        style: const TextStyle(color: mediumBlue),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: mediumBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onPressed,
    );
  }
}
