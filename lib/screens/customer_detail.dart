import 'package:flutter/material.dart';

enum ReminderLevel { friendly, warning, finalNotice }

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
  State<CustomerDetail> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetail> {
  // ✅ Transactions List
  List<Map<String, dynamic>> transactions = [];

  // ✅ Balance Variable
  late double currentBalance;

  @override
  void initState() {
    super.initState();
    currentBalance = widget.balance;
  }

  String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }

  // ✅ 3-Level Reminder Function
  void sendReminder(ReminderLevel level, String name, double balance) {
    String message;
    Color color;

    switch (level) {
      case ReminderLevel.friendly:
        message = "Friendly reminder sent";
        color = Colors.blue;
        break;
      case ReminderLevel.warning:
        message = "Warning reminder sent";
        color = Colors.orange;
        break;
      case ReminderLevel.finalNotice:
        message = "FINAL reminder sent";
        color = Colors.red;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$message to $name for ₹$balance"),
        backgroundColor: color,
      ),
    );
  }

  // ✅ Delete Customer
  void deleteCustomer() {
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  // ✅ Add Transaction + Timestamp
  void openTransactionSheet(String type) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) => AddTransactionSheet(type: type),
    );

    if (amount == null) return;

    final now = DateTime.now();

    setState(() {
      transactions.insert(0, {
        "id": now.toString(),
        "type": type,
        "amount": amount,
        "date":
        "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
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
    final name = widget.name;
    final phone = widget.phone;
    final isPositive = currentBalance > 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Customer?"),
                  content: Text(
                    "This will permanently delete $name and all transactions.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: deleteCustomer,
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Customer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16),
                              const SizedBox(width: 6),
                              Text(phone),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✅ Balance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentBalance == 0
                              ? "Settled"
                              : isPositive
                              ? "Customer will pay you"
                              : "You need to return",
                          style: TextStyle(color: Colors.grey.shade700),
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

                  const SizedBox(height: 20),

                  // ✅ Reminder (3-Level)
                  PopupMenuButton<ReminderLevel>(
                    onSelected: (level) =>
                        sendReminder(level, name, currentBalance.abs()),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: ReminderLevel.friendly,
                        child: Text("Friendly Reminder"),
                      ),
                      PopupMenuItem(
                        value: ReminderLevel.warning,
                        child: Text("Warning"),
                      ),
                      PopupMenuItem(
                        value: ReminderLevel.finalNotice,
                        child: Text("Final Notice"),
                      ),
                    ],
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.notifications),
                      label: const Text("Send Reminder"),
                      onPressed: null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Transaction Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => openTransactionSheet("got"),
                    child: const Text("You Got"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Transaction History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            transactions.isNotEmpty
                ? Column(
              children: transactions
                  .map((txn) =>
                  TransactionCard(transaction: txn))
                  .toList(),
            )
                : const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No transactions yet"),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isGave = transaction["type"] == "gave";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          isGave ? Icons.arrow_upward : Icons.arrow_downward,
          color: isGave ? Colors.red : Colors.green,
        ),
        title: Text("₹${transaction["amount"]}"),
        subtitle: Text(transaction["date"]),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class AddTransactionSheet extends StatefulWidget {
  final String type;

  const AddTransactionSheet({super.key, required this.type});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.type == "gave"
                ? "Add You Gave (Udhar)"
                : "Add You Got (Payment)",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0;
              if (amount > 0) Navigator.pop(context, amount);
            },
            child: const Text("Save Transaction"),
          ),
        ],
      ),
    );
  }
}
