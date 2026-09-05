import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../domain/entities/expense_entity.dart';
import '../../../../domain/entities/payment_entity.dart';
import '../../../../domain/repositories/finance_repository.dart';
import 'pdf_export_stub.dart' if (dart.library.html) 'pdf_export_web.dart';

class PlatformPdfExporter {
  PlatformPdfExporter._();

  static Future<void> exportTablePdf({
    required String title,
    required List<List<dynamic>> tableData,
    double? totalAmount,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = '$title-$dateStr.pdf';

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              if (totalAmount != null) ...[
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total: EGP ${totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await downloadPdfFile(bytes, fileName);
  }
}

class PlatformPdfExport {
  PlatformPdfExport._();

  static Future<Uint8List> generateFinanceSummaryPdf({
    required FinancialSummary summary,
    required List<PaymentEntity> payments,
    required List<ExpenseEntity> expenses,
    String? dateRangeLabel,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            text: 'PSA Academy - Financial Report (${dateRangeLabel ?? 'All'})',
          ),
          pw.Paragraph(
            text:
                'Total Revenue: EGP ${summary.totalRevenue.toStringAsFixed(2)} | Total Expenses: EGP ${summary.totalExpenses.toStringAsFixed(2)} | Net Balance: EGP ${summary.netBalance.toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, text: 'Payments & Revenue'),
          pw.TableHelper.fromTextArray(
            headers: ['Player', 'Amount', 'Date'],
            data: payments
                .map((p) => [
                      p.playerName.isNotEmpty ? p.playerName : p.playerId,
                      'EGP ${p.amount.toStringAsFixed(2)}',
                      p.date.toString().substring(0, 10),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, text: 'Expenses Log'),
          pw.TableHelper.fromTextArray(
            headers: ['Title', 'Category', 'Amount', 'Date'],
            data: expenses
                .map((e) => [
                      e.title,
                      e.category,
                      'EGP ${e.amount.toStringAsFixed(2)}',
                      e.date.toString().substring(0, 10),
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  static Future<void> savePdf(Uint8List bytes, String fileName) async {
    await downloadPdfFile(bytes, fileName);
  }
}
