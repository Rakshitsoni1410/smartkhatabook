import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data (later from backend)
    final List<Map<String, dynamic>> shops = [
      {
        'shop': 'Ramesh Kirana',
        'total': 2300.0,
        'bills': [
          {'date': '10 Aug', 'amount': 1200.0},
          {'date': '18 Aug', 'amount': 1100.0},
        ],
      },
      {
        'shop': 'Medical Store',
        'total': 850.0,
        'bills': [
          {'date': '15 Aug', 'amount': 850.0},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Spending')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          final bills =
          shop['bills'] as List<Map<String, dynamic>>; // ✅ FIX

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SHOP NAME
                  Text(
                    shop['shop'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Total Spent: ₹${shop['total']}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Divider(height: 24),

                  const Text(
                    'Bills',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bills.length,
                    itemBuilder: (context, i) {
                      final bill = bills[i];

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.receipt_long),
                        title: Text('₹${bill['amount']}'),
                        subtitle: Text('Date: ${bill['date']}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
