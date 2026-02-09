import 'package:flutter/material.dart';

class CustomerDetail extends StatefulWidget {
  final String name;
  final String phone;
  final double balance;

  const CustomerDetail({
    super.key,
    required this.name,
    required this.phone,
    required this.balance,
  });

  @override
  State<CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
  late double currentBalance;

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    currentBalance = widget.balance;
  }

  String formatCurrency(double amount) => "₹${amount.toStringAsFixed(0)}";

  String formatDateTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // 🔔 REMINDER LEVELS
  void sendReminder(String level) {
    String msg;
    Color color;

    if (level == "friendly") {
      msg = "Friendly reminder sent 🙂";
      color = Colors.blue;
    } else if (level == "warning") {
      msg = "Warning reminder sent ⚠️";
      color = Colors.orange;
    } else {
      msg = "Final reminder sent 🔴";
      color = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  void openTransactionSheet(String type) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTransactionSheet(type: type),
    );

    if (amount == null) return;

    setState(() {
      transactions.insert(0, {
        "type": type,
        "amount": amount,
        "time": DateTime.now(),
      });

      if (type == "gave") {
        currentBalance += amount;
      } else {
        currentBalance -= amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPositive = currentBalance > 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// CUSTOMER INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      widget.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.phone),

                  const SizedBox(height: 16),

                  /// BALANCE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isPositive
                              ? "Customer will pay you"
                              : "You need to return",
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency(currentBalance.abs()),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔔 REMINDERS (3 LEVELS)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => sendReminder("friendly"),
                          child: const Text("Friendly"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => sendReminder("warning"),
                          child: const Text("Warning"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => sendReminder("final"),
                          child: const Text("Final"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TRANSACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => openTransactionSheet("gave"),
                    child: const Text("You Gave"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => openTransactionSheet("got"),
                    child: const Text("You Got"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// HISTORY
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transaction History",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),

            transactions.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No transactions yet"),
            )
                : Column(
              children: transactions
                  .map((t) => TransactionCard(
                transaction: t,
                formatTime: formatDateTime,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String Function(DateTime) formatTime;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    bool isGave = transaction["type"] == "gave";

    return Card(
      child: ListTile(
        leading: Icon(
          isGave ? Icons.arrow_upward : Icons.arrow_downward,
          color: isGave ? Colors.red : Colors.green,
        ),
        title: Text("₹${transaction["amount"]}"),
        subtitle: Text(formatTime(transaction["time"])),
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class AddTransactionSheet extends StatefulWidget {
  final String type;

  const AddTransactionSheet({super.key, required this.type});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.type == "gave"
                ? "Add You Gave"
                : "Add You Got",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount",
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(context, amount);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
