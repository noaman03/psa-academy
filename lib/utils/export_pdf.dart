import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:intl/intl.dart';

Future<void> exportPDF(List<List<dynamic>> data, String title,
    {double? totalAmount}) async {
  final pdf = pw.Document();
  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final fileName = '$title-$currentDate.pdf';

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(title,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(data: data),
            if (totalAmount != null) ...[
              pw.SizedBox(height: 20),
              pw.Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ],
        );
      },
    ),
  );

  // Save the PDF as bytes
  final Uint8List bytes = await pdf.save();

  // Create a blob and trigger a download
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
