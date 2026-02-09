
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

  // ✅ Currency Formatter
  String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }

  // ✅ Call Customer Dummy
  void callCustomer(String phone) {
    print("Calling customer: $phone");
  }

  // ✅ Reminder Dummy
  void sendReminder(String name, String phone, double balance) {
    print("Reminder sent to $name for ₹$balance");
  }

  // ✅ Delete Customer
  void deleteCustomer() {
    Navigator.pop(context); // Close dialog first

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Customer Deleted Successfully")),
    );

    // ✅ Return delete result back to Customer List
    Navigator.pop(context, true);
  }


  // ✅ Open Transaction Sheet + Save Transaction
  void openTransactionSheet(String type) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) => AddTransactionSheet(type: type),
    );

    if (amount == null) return;

    setState(() {
      // ✅ Add Transaction in History
      transactions.insert(0, {
        "id": DateTime.now().toString(),
        "type": type,
        "amount": amount,
        "date": "${DateTime.now().day}/${DateTime.now().month}",
      });

      // ✅ Correct Shop Owner Balance Logic
      if (type == "gave") {
        // 🔴 You Gave = Customer owes more
        currentBalance += amount;
      } else {
        // 🟢 You Got = Customer paid
        currentBalance -= amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.name;
    String phone = widget.phone;

    bool isPositive = currentBalance > 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ AppBar
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
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Delete"),
                      onPressed: deleteCustomer,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // ✅ Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Customer Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar + Name + Phone
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

                  // ✅ Balance Section
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
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
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

                  // ✅ Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          onPressed: () => callCustomer(phone),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.message),
                          label: const Text("Remind"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () =>
                              sendReminder(name, phone, currentBalance.abs()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Transaction Buttons (Correct Colors)
            Row(
              children: [
                // 🔴 You Gave = Udhar
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

                // 🟢 You Got = Payment Received
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

            // ✅ Transaction History
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transaction History",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Transactions List
            transactions.isNotEmpty
                ? Column(
              children: transactions
                  .map((txn) => TransactionCard(transaction: txn))
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
    bool isGave = transaction["type"] == "gave";

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
              double amount =
                  double.tryParse(amountController.text.trim()) ?? 0;

              if (amount <= 0) return;

              Navigator.pop(context, amount);
            },
            child: const Text("Save Transaction"),
          ),
        ],
      ),
    );
  }
}

