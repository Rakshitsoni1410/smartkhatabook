import 'package:flutter/material.dart';
import 'create_bill_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> customers = [
      {
        'name': 'Rahul Patel',
        'totalBilled': 2300.0,
        'totalPaid': 1800.0,
      },
      {
        'name': 'Amit Shah',
        'totalBilled': 1200.0,
        'totalPaid': 1200.0,
      },
      {
        'name': 'Neha Mehta',
        'totalBilled': 900.0,
        'totalPaid': 400.0,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];

          final totalBilled = customer['totalBilled'] as double;
          final totalPaid = customer['totalPaid'] as double;
          final outstanding = totalBilled - totalPaid;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(customer['name'] as String),
              subtitle: Text(
                outstanding > 0
                    ? 'Outstanding: ₹${outstanding.toStringAsFixed(2)}'
                    : 'No Dues',
                style: TextStyle(
                  color: outstanding > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.receipt_long),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateBillScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
