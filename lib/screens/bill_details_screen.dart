import 'package:flutter/material.dart';

class BillDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items =
    bill['items'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Customer', bill['customer']),
            _infoRow('Date', bill['date']),
            _infoRow('Payment', bill['payment']),
            _infoRow(
              'Status',
              bill['paid'] ? 'Paid' : 'Pending',
              color: bill['paid'] ? Colors.green : Colors.red,
            ),

            const Divider(height: 32),

            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final total = item['qty'] * item['price'];

                  return ListTile(
                    title: Text(item['name']),
                    subtitle:
                    Text('Qty: ${item['qty']}  ×  ₹${item['price']}'),
                    trailing: Text(
                      '₹$total',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ₹${bill['amount']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
