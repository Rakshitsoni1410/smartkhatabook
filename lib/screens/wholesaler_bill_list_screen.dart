import 'package:flutter/material.dart';
import 'create_bill_screen.dart';
import 'bill_detail_screen.dart';

class WholesalerBillListScreen extends StatefulWidget {
  const WholesalerBillListScreen({super.key});

  @override
  State<WholesalerBillListScreen> createState() =>
      _WholesalerBillListScreenState();
}

class _WholesalerBillListScreenState
    extends State<WholesalerBillListScreen> {
  final List<Map<String, dynamic>> bills = [];

  Color _statusColor(String status) =>
      status == "Paid" ? Colors.green : Colors.orange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bills")),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Create Bill"),
        onPressed: () async {
          final bill = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateBillScreen()),
          );
          if (bill != null) setState(() => bills.add(bill));
        },
      ),
      body: bills.isEmpty
          ? const Center(child: Text("No bills created"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final b = bills[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.receipt_long, size: 32),
              title: Text(
                b["retailer"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Date: ${b["date"] ?? "Today"}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${b["total"]}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      b["status"],
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _statusColor(b["status"]),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BillDetailScreen(bill: b),
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
