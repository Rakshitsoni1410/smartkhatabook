import 'package:flutter/material.dart';

class EmployeeSalaryScreen extends StatefulWidget {
  final String name;
  final String role;

  const EmployeeSalaryScreen({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  State<EmployeeSalaryScreen> createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  int monthlySalary = 12000;
  int advancePaid = 3000;

  final List<Map<String, dynamic>> salaryHistory = [];

  int get pendingSalary => monthlySalary - advancePaid;

  void _paySalary() {
    setState(() {
      salaryHistory.add({
        "amount": pendingSalary,
        "date": DateTime.now().toString().split(" ")[0],
      });
      advancePaid = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Salary paid successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Salary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  widget.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(widget.role),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  _row("Monthly Salary", monthlySalary),
                  _row("Advance Paid", advancePaid),
                  const Divider(),
                  _row("Pending Salary", pendingSalary, color: Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text("Pay Salary"),
                onPressed: pendingSalary > 0 ? _paySalary : null,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Salary History",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: salaryHistory.isEmpty
                  ? const Center(child: Text("No payments yet"))
                  : ListView.builder(
                itemCount: salaryHistory.length,
                itemBuilder: (context, index) {
                  final h = salaryHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text("₹${h["amount"]}"),
                    subtitle: Text("Date: ${h["date"]}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "₹$value",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
