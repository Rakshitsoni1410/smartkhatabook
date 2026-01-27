import 'package:flutter/material.dart';
import 'bill_details_screen.dart';

class LedgerSummaryScreen extends StatefulWidget {
  const LedgerSummaryScreen({super.key});

  @override
  State<LedgerSummaryScreen> createState() => _LedgerSummaryScreenState();
}

class _LedgerSummaryScreenState extends State<LedgerSummaryScreen> {
  List<Map<String, dynamic>> bills = [
    {
      'customer': 'Rahul Patel',
      'amount': 1200.0,
      'paid': true,
      'date': '20 Aug 2025',
      'payment': 'UPI',
      'items': [
        {'name': 'Rice', 'qty': 2, 'price': 50},
        {'name': 'Oil', 'qty': 1, 'price': 150},
      ],
    },
    {
      'customer': 'Amit Shah',
      'amount': 850.0,
      'paid': false,
      'date': '22 Aug 2025',
      'payment': 'Cash',
      'items': [
        {'name': 'Sugar', 'qty': 1, 'price': 45},
        {'name': 'Tea', 'qty': 2, 'price': 80},
      ],
    },
    {
      'customer': 'Neha Mehta',
      'amount': 640.0,
      'paid': true,
      'date': '25 Aug 2025',
      'payment': 'Bank Transfer',
      'items': [
        {'name': 'Milk', 'qty': 4, 'price': 40},
      ],
    },
  ];

  double get totalCredit => bills
      .where((b) => b['paid'] == true)
      .fold(0.0, (sum, b) => sum + (b['amount'] as double));

  double get totalDebit => bills
      .where((b) => b['paid'] == false)
      .fold(0.0, (sum, b) => sum + (b['amount'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ledger Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _card('Credit', totalCredit, Colors.green),
                const SizedBox(width: 12),
                _card('Debit', totalDebit, Colors.red),
              ],
            ),

            const SizedBox(height: 16),

            _card(
              'Net Balance',
              totalCredit - totalDebit,
              Colors.blue,
              full: true,
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bills',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];

                  return Dismissible(
                    key: ValueKey(bill),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      setState(() {
                        bills.removeAt(index);
                      });
                    },
                    child: ListTile(
                      leading: Icon(
                        bill['paid']
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: bill['paid'] ? Colors.green : Colors.red,
                      ),
                      title: Text(bill['customer']),
                      subtitle: Text(
                        bill['paid'] ? 'Paid Bill' : 'Pending Bill',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${bill['amount']}'),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editBill(index),
                          ),
                        ],
                      ),

                      // 🔥 MERGED PART: OPEN BILL DETAILS
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BillDetailsScreen(
                              bill: bill,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, double amount, Color color,
      {bool full = false}) {
    return Expanded(
      flex: full ? 2 : 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editBill(int index) {
    final controller =
    TextEditingController(text: bills[index]['amount'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Bill Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                bills[index]['amount'] =
                    double.tryParse(controller.text) ??
                        bills[index]['amount'];
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
