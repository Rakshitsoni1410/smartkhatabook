import 'package:flutter/material.dart';
import '../services/ledger_service.dart';

class LedgerSummaryScreen extends StatelessWidget {
  const LedgerSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = LedgerService.ledgerEntries;

    return Scaffold(
      appBar: AppBar(title: const Text("Ledger")),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final e = entries[i];
          return ListTile(
            leading: Icon(
              e["type"] == "Credit" ? Icons.arrow_downward : Icons.arrow_upward,
              color: e["type"] == "Credit" ? Colors.green : Colors.red,
            ),
            title: Text("${e["party"]} • ${e["source"]}"),
            trailing: Text("₹${e["amount"]}"),
          );
        },
      ),
    );
  }
}
