import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrPopup extends StatelessWidget {
  final String qrData;
  final ImageProvider image;

  const QrPopup({super.key, required this.qrData, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(
            context,
          );
        },
        child: Center(
          child: PrettyQrView.data(
            decoration: const PrettyQrDecoration(
              image: PrettyQrDecorationImage(
                image: AssetImage('images/main_large.png'),
              ),
            ),
            data: qrData,
            errorCorrectLevel: QrErrorCorrectLevel.M,
          ),
        ),
      ),
    );
  }
}
