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

  // ✅ Delete Customer
  void deleteCustomer() {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Customer Deleted Successfully")),
    );

    Navigator.pop(context, true);
  }

  // ✅ Open Transaction Sheet + Save Transaction
  void openTransactionSheet(String type) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) => AddTransactionSheet(type: type),
    );

    if (amount == null) return;

    setState(() {
      transactions.insert(0, {
        "id": DateTime.now().toString(),
        "type": type,
        "amount": amount,
        "date":
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      });

      // ✅ Shop Owner Logic
      if (type == "gave") {
        // Customer owes more
        currentBalance += amount;
      } else {
        // Customer paid you
        currentBalance -= amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.name;
    String phone = widget.phone;

    bool customerOwes = currentBalance > 0;

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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar + Name + Phone
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
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
                      const SizedBox(width: 14),
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
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
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
                      color: customerOwes
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
                              : customerOwes
                              ? "Customer will pay you"
                              : "You need to return",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency(currentBalance.abs()),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: customerOwes ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ✅ Transaction Buttons
            Row(
              children: [
                // 🔴 You Gave
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => openTransactionSheet("gave"),
                    child: const Text(
                      "You Gave",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 🟢 You Got
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => openTransactionSheet("got"),
                    child: const Text(
                      "You Got",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ✅ Transaction History Title
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

            const SizedBox(height: 12),

            // ✅ Transaction List
            transactions.isNotEmpty
                ? Column(
              children: transactions
                  .map((txn) => TransactionCard(transaction: txn))
                  .toList(),
            )
                : Padding(
              padding: const EdgeInsets.all(25),
              child: Text(
                "No transactions yet",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
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
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          isGave ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            isGave ? Icons.arrow_upward : Icons.arrow_downward,
            color: isGave ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          "₹${transaction["amount"]}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                ? "Add Udhar (You Gave)"
                : "Add Payment (You Got)",
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
              labelText: "Enter Amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                double amount =
                    double.tryParse(amountController.text.trim()) ?? 0;

                if (amount <= 0) return;

                Navigator.pop(context, amount);
              },
              child: const Text("Save Transaction"),
            ),
          ),
        ],
      ),
    );
  }
}
