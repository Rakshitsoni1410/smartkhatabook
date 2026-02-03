import 'package:flutter/material.dart';
import '../services/ledger_service.dart';

class BillDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bill;

  const BillDetailScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bill Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Retailer: ${bill["retailer"]}"),
            Text("Total: ₹${bill["total"]}"),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Mark as Paid"),
              onPressed: () {
                LedgerService.addEntry(
                  party: bill["retailer"],
                  type: "Credit",
                  amount: bill["total"],
                  source: "Bill",
                );
                LedgerService.addEntry(
                  party: "Wholesaler",
                  type: "Debit",
                  amount: bill["total"],
                  source: "Bill",
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
