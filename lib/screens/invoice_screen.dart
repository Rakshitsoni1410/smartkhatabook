import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceScreen extends StatelessWidget {
  final Map<String, dynamic> bill;

  const InvoiceScreen({super.key, required this.bill});

  String _value(dynamic value, [String fallback = 'Not available']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double? _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  String _money(dynamic value) {
    final amount = _number(value);
    return amount == null ? 'Not available' : '₹${amount.toStringAsFixed(2)}';
  }

  String _pdfMoney(dynamic value) {
    final amount = _number(value);
    return amount == null
        ? 'Not available'
        : 'INR ${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic>? _object(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _partyName(dynamic party, dynamic fallback) {
    final fields = _object(party);
    return _value(fields?['shopName'] ?? fields?['name'] ?? fallback);
  }

  DateTime? _invoiceDate() => DateTime.tryParse(
    (bill['billSentAt'] ?? bill['createdAt'] ?? '').toString(),
  );

  double? _advancePaid() {
    final history = bill['paymentHistory'];
    if (history is List) {
      final advancePayments = history.whereType<Map>().where(
        (payment) =>
            payment['paymentType']?.toString().toLowerCase() == 'advance' &&
            payment['status']?.toString().toLowerCase() == 'success',
      );
      if (advancePayments.isNotEmpty) {
        final amounts = advancePayments
            .map((payment) => _number(payment['amount']))
            .toList();
        if (amounts.any((amount) => amount == null)) return null;
        return advancePayments.fold<double>(
          0,
          (sum, payment) => sum + _number(payment['amount'])!,
        );
      }
    }
    return bill['advancePaid'] == true ? _number(bill['advanceAmount']) : 0;
  }

  Future<void> _printInvoice(BuildContext context) async {
    final date = _invoiceDate();
    final advancePaid = _advancePaid();

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SMART KHATA BOOK',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 18),
              _pdfRow('Invoice Number', _value(bill['invoiceNumber'])),
              _pdfRow(
                'Invoice Date',
                date == null
                    ? 'Not available'
                    : DateFormat('d MMM yyyy').format(date.toLocal()),
              ),
              pw.Divider(),
              _pdfRow(
                'Wholesaler / Seller',
                _partyName(bill['wholesalerId'], bill['wholesalerName']),
              ),
              _pdfRow(
                'Retailer / Buyer',
                _partyName(bill['retailerId'], bill['retailerName']),
              ),
              pw.SizedBox(height: 18),
              _pdfRow('Product', _value(bill['productName'])),
              _pdfRow(
                'Quantity',
                '${_value(bill['quantity'])} ${_value(bill['unit'], '')}'
                    .trim(),
              ),
              _pdfRow('Price Per Unit', _pdfMoney(bill['pricePerUnit'])),
              _pdfRow('Total Amount', _pdfMoney(bill['totalAmount'])),
              pw.Divider(),
              _pdfRow(
                'Advance Paid',
                advancePaid == null
                    ? 'Not available'
                    : 'INR ${advancePaid.toStringAsFixed(2)}',
              ),
              _pdfRow('Remaining Amount', _pdfMoney(bill['remainingAmount'])),
              _pdfRow('Payment Status', _value(bill['paymentStatus'])),
              _pdfRow('Order Status', _value(bill['orderStatus'])),
            ],
          ),
        ),
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (_) => document.save());
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open invoice PDF: $error')),
      );
    }
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final date = _invoiceDate();
    final advancePaid = _advancePaid();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          IconButton(
            onPressed: () => _printInvoice(context),
            tooltip: 'Print or save PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SMART KHATA BOOK',
                    style: TextStyle(
                      color: Color(0xff2563EB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailRow('Invoice Number', _value(bill['invoiceNumber'])),
                  _detailRow(
                    'Invoice Date',
                    date == null
                        ? 'Not available'
                        : DateFormat('d MMM yyyy').format(date.toLocal()),
                  ),
                  const Divider(height: 24),
                  _detailRow(
                    'Wholesaler / Seller',
                    _partyName(bill['wholesalerId'], bill['wholesalerName']),
                  ),
                  _detailRow(
                    'Retailer / Buyer',
                    _partyName(bill['retailerId'], bill['retailerName']),
                  ),
                  const Divider(height: 24),
                  _detailRow('Product', _value(bill['productName'])),
                  _detailRow(
                    'Quantity',
                    '${_value(bill['quantity'])} ${_value(bill['unit'], '')}'
                        .trim(),
                  ),
                  _detailRow('Price Per Unit', _money(bill['pricePerUnit'])),
                  _detailRow('Total Amount', _money(bill['totalAmount'])),
                  const Divider(height: 24),
                  _detailRow(
                    'Advance Paid',
                    advancePaid == null ? 'Not available' : _money(advancePaid),
                  ),
                  _detailRow(
                    'Remaining Amount',
                    _money(bill['remainingAmount']),
                  ),
                  _detailRow('Payment Status', _value(bill['paymentStatus'])),
                  _detailRow('Order Status', _value(bill['orderStatus'])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _printInvoice(context),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Print / Save Invoice PDF'),
          ),
        ],
      ),
    );
  }
}
