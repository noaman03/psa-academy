import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  String? qrText;
  bool _isOpeningScanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openScanner();
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _openScanner() async {
    if (_isOpeningScanner) return;

    setState(() {
      _isOpeningScanner = true;
    });

    await _requestCameraPermission();

    if (!mounted) return;

    final result = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Scan QR Code',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back),
      ),
      scanType: ScanType.qr,
      scanFormat: ScanFormat.ONLY_QR_CODE,
      cameraFace: CameraFace.back,
      isShowFlashIcon: true,
      lineColor: '#00A6A6',
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty && result != '-1') {
      Navigator.pop(context, result);
      return;
    }

    setState(() {
      qrText = result;
      _isOpeningScanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 72,
                color: Color(0xFF00A6A6),
              ),
              const SizedBox(height: 16),
              Text(
                _isOpeningScanner
                    ? 'Opening camera scanner...'
                    : 'Scanner closed without a QR result.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (qrText != null && qrText!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Last result: $qrText',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isOpeningScanner ? null : _openScanner,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Open Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
