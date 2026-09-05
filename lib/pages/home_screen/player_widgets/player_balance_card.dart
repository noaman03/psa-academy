import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:psa_academy/widgets/qr_popup.dart';

class PlayerBalanceCard extends StatelessWidget {
  final double balance;
  final String qrData;

  const PlayerBalanceCard({
    super.key,
    required this.balance,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [darkBlue, mediumBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: mediumBlue.withOpacity(0.16),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'EGP $balance',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrPopup(
                      qrData: qrData,
                      image: const AssetImage('assets/images/main_large.png'),
                    ),
                  ),
                );
              },
              child: PrettyQr(
                data: qrData,
                size: 100,
                roundEdges: true,
                errorCorrectLevel: QrErrorCorrectLevel.M,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
