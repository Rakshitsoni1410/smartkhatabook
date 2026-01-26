import 'package:flutter/material.dart';

enum TransactionType { credit, debit }

class AddTransactionScreen extends StatefulWidget {
  final String customerName;

  const AddTransactionScreen({super.key, required this.customerName});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.credit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customerName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            RadioListTile<TransactionType>(
              title: const Text('Credit (+)'),
              value: TransactionType.credit,
              groupValue: _type,
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),
            RadioListTile<TransactionType>(
              title: const Text('Debit (-)'),
              value: TransactionType.debit,
              groupValue: _type,
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction Saved')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
