import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class PaymentCard extends StatelessWidget {
  final String? scannedPlayerId;
  final TextEditingController amountController;
  final VoidCallback onAssignPayment;

  const PaymentCard({
    super.key,
    required this.scannedPlayerId,
    required this.amountController,
    required this.onAssignPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: mediumBlue, size: 30),
                SizedBox(width: 12),
                Text(
                  'Assign Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                prefixIcon: const Icon(Icons.attach_money, color: mediumBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: mediumBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: mediumBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scannedPlayerId != null ? onAssignPayment : null,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Assign Payment',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mediumBlue,
                  minimumSize: const Size(0, 50),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
