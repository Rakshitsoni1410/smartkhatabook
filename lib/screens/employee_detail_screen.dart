import 'package:flutter/material.dart';

class EmployeeDetail extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetail({super.key, required this.employee});

  @override
  State<EmployeeDetail> createState() => _EmployeeDetailState();
}

class _EmployeeDetailState extends State<EmployeeDetail> {
  late List<Map<String, dynamic>> payments;

  @override
  void initState() {
    super.initState();
    payments = List<Map<String, dynamic>>.from(
      widget.employee["payments"] ?? [],
    );
  }

  // ===============================
  // CALCULATIONS
  // ===============================
  double get totalPaid {
    return payments.fold(
      0,
          (sum, p) => sum + ((p["amount"] ?? 0).toDouble()),
    );
  }

  double get monthlySalary {
    return (widget.employee["salary"] ?? 0).toDouble();
  }

  double get pendingSalary {
    return monthlySalary - totalPaid;
  }

  // ===============================
  // PAY SALARY POPUP
  // ===============================
  void paySalaryPopup() {
    TextEditingController amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pay Salary",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

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

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Confirm Payment"),
                  onPressed: () {
                    double amt =
                        double.tryParse(amountCtrl.text) ?? 0;

                    if (amt <= 0) return;

                    setState(() {
                      payments.add({
                        "amount": amt,
                        "date": DateTime.now().toString(),
                      });

                      widget.employee["payments"] = payments;
                    });

                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ===============================
  // MAIN UI
  // ===============================
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

            // ================= EMPLOYEE CARD =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                children: [

                  // Name
                  Text(
                    emp["name"],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    emp["phone"],
                    style:
                    const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Text("Salary: ₹$monthlySalary"),
                  Text(
                      "Pay Date: ${emp["salaryDate"]} every month"),

                  const SizedBox(height: 12),

                  // Pending / Paid Status
                  Text(
                    pendingSalary <= 0
                        ? "Salary Fully Paid"
                        : "Pending: ₹${pendingSalary.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: pendingSalary <= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green.shade700,
                      ),
                      onPressed: paySalaryPopup,
                      child:
                      const Text("Pay Salary"),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= PAYMENT HISTORY =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment History",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: payments.isEmpty
                  ? const Center(
                child: Text("No payments yet"),
              )
                  : ListView.builder(
                itemCount: payments.length,
                itemBuilder: (_, index) {
                  final p = payments[index];

                  return Container(
                    margin: const EdgeInsets.only(
                        bottom: 10),
                    padding:
                    const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                          color:
                          Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Text(
                            "₹${p["amount"]}"),
                        Text(
                          p["date"]
                              .toString()
                              .split(".")[0],
                          style: const TextStyle(
                              color:
                              Colors.grey),
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
