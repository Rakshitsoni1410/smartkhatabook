import 'package:flutter/material.dart';

class EmployeeDetail extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetail({super.key, required this.employee});

  @override
  State<EmployeeDetail> createState() => _EmployeeDetailState();
}

class _EmployeeDetailState extends State<EmployeeDetail> {
  // ✅ REAL PAYMENT LIST STORED IN STATE
  late List<Map<String, dynamic>> payments;

  @override
  void initState() {
    super.initState();

    // ✅ Load payments safely when screen opens
    payments = List<Map<String, dynamic>>.from(
      widget.employee["payments"] ?? [],
    );
  }

  // ✅ TOTAL PAID CALCULATION
  double get totalPaid {
    return payments.fold(
      0,
          (sum, p) => sum + ((p["amount"] ?? 0).toDouble()),
    );
  }

  // ==============================
  // PAY SALARY POPUP
  // ==============================
  void paySalaryPopup() {
    TextEditingController amountCtrl = TextEditingController();
    TextEditingController noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Pay Salary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Amount Input
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount (₹)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Note Input
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: "Note (Optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Pay Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Pay Salary"),
                  onPressed: () {
                    double amt = double.tryParse(amountCtrl.text) ?? 0;
                    if (amt <= 0) return;

                    setState(() {
                      // ✅ Add Payment Properly
                      payments.add({
                        "amount": amt,
                        "note": noteCtrl.text.trim(),
                        "date": DateTime.now().toString(),
                      });

                      // ✅ Save Back Into Employee Map
                      widget.employee["payments"] = payments;
                    });

                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================
  // MAIN UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    final emp = widget.employee;

    return Scaffold(
      appBar: AppBar(
        title: Text(emp["name"]),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= INFO CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      emp["name"][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    emp["name"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    emp["phone"],
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Role: ${emp["category"]}"),
                      Text(
                        "₹${emp["salary"]}/month",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.wallet),
                          label: const Text("Pay Salary"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          onPressed: paySalaryPopup,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= TOTAL PAID SUMMARY =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Total Paid: ₹${totalPaid.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 18),

            // ================= PAYMENT HISTORY =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Salary Payment History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: payments.isEmpty
                  ? const Center(child: Text("No salary payments yet"))
                  : ListView.builder(
                itemCount: payments.length,
                itemBuilder: (_, index) {
                  final p = payments[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (p["note"] == null || p["note"].toString().isEmpty)
                              ? "Salary Paid"
                              : p["note"],
                        ),
                        Text(
                          "₹${p["amount"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
