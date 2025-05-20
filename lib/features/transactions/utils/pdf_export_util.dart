import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:open_file/open_file.dart';

/// Utility class for exporting transactions to PDF
class PdfExportUtil {
  /// Export transactions to PDF and return the file path
  static Future<String> exportTransactions(
    List<Transaction> transactions,
    String title,
    String currency,
  ) async {
    // Create PDF document
    final pdf = pw.Document();

    // Load font
    final fontData = await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load logo
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    // Add page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 60, height: 60),
                  pw.Text(
                    'Golden Wallet',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Generated on: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Divider(color: PdfColors.amber),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Golden Wallet - Transaction Report',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            _buildTransactionTable(transactions, ttf, currency),
            pw.SizedBox(height: 20),
            _buildSummary(transactions, ttf, currency),
          ];
        },
      ),
    );

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File(
        '${output.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Build transaction table
  static pw.Widget _buildTransactionTable(
    List<Transaction> transactions,
    pw.Font font,
    String currency,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5), // Date
        1: const pw.FlexColumnWidth(1.5), // ID
        2: const pw.FlexColumnWidth(1), // Type
        3: const pw.FlexColumnWidth(1), // Amount
        4: const pw.FlexColumnWidth(1), // Price
        5: const pw.FlexColumnWidth(1), // Total
        6: const pw.FlexColumnWidth(1), // Status
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.amber50,
          ),
          children: [
            _buildHeaderCell('Date', font),
            _buildHeaderCell('Transaction ID', font),
            _buildHeaderCell('Type', font),
            _buildHeaderCell('Amount', font),
            _buildHeaderCell('Price', font),
            _buildHeaderCell('Total', font),
            _buildHeaderCell('Status', font),
          ],
        ),
        // Data rows
        ...transactions.map((transaction) => pw.TableRow(
              children: [
                _buildCell(
                    DateFormat('MMM dd, yyyy\nHH:mm').format(transaction.date),
                    font),
                _buildCell(transaction.id, font),
                _buildCell(transaction.type.translationKey.toUpperCase(), font),
                _buildCell(
                  transaction.goldWeight != null
                      ? '${transaction.goldWeight!.toStringAsFixed(2)} oz'
                      : transaction.amount.toStringAsFixed(2),
                  font,
                ),
                _buildCell(
                    '$currency ${transaction.price.toStringAsFixed(2)}', font),
                _buildCell(
                    '$currency ${transaction.total.toStringAsFixed(2)}', font),
                _buildCell(
                    transaction.status.translationKey.toUpperCase(), font),
              ],
            )),
      ],
    );
  }

  /// Build header cell
  static pw.Widget _buildHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build cell
  static pw.Widget _buildCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build summary
  static pw.Widget _buildSummary(
    List<Transaction> transactions,
    pw.Font font,
    String currency,
  ) {
    // Calculate totals
    double totalBuy = 0;
    double totalSell = 0;
    double totalDeposit = 0;
    double totalWithdraw = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.buy:
          totalBuy += transaction.total;
          break;
        case TransactionType.sell:
          totalSell += transaction.total;
          break;
        case TransactionType.deposit:
          totalDeposit += transaction.total;
          break;
        case TransactionType.withdraw:
          totalWithdraw += transaction.total;
          break;
        default:
          break;
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        border: pw.Border.all(color: PdfColors.amber),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Buy',
                  '$currency ${totalBuy.toStringAsFixed(2)}', font),
              _buildSummaryItem('Total Sell',
                  '$currency ${totalSell.toStringAsFixed(2)}', font),
              _buildSummaryItem('Total Deposit',
                  '$currency ${totalDeposit.toStringAsFixed(2)}', font),
              _buildSummaryItem('Total Withdraw',
                  '$currency ${totalWithdraw.toStringAsFixed(2)}', font),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.amber),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Net Balance: ',
                style: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '$currency ${(totalBuy + totalDeposit - totalSell - totalWithdraw).toStringAsFixed(2)}',
                style: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                  color:
                      (totalBuy + totalDeposit - totalSell - totalWithdraw) >= 0
                          ? PdfColors.green700
                          : PdfColors.red700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary item
  static pw.Widget _buildSummaryItem(String label, String value, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Open PDF file
  static Future<void> openPdf(String filePath) async {
    await OpenFile.open(filePath);
  }
}
