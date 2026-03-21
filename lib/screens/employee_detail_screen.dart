import 'package:flutter/material.dart';

class EmployeeDetail extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetail({
    super.key,
    required this.employee,
  });

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

  double get totalPaid {
    return payments.fold<double>(
      0,
      (sum, p) => sum + ((p["amount"] ?? 0) as num).toDouble(),
    );
  }

  double get monthlySalary {
    return ((widget.employee["salary"] ?? 0) as num).toDouble();
  }

  double get pendingSalary {
    final pending = monthlySalary - totalPaid;
    return pending < 0 ? 0 : pending;
  }

  String formatCurrency(double value) {
    return "₹${value.toStringAsFixed(0)}";
  }

  IconData getCategoryIcon(String category) {
    final c = category.toLowerCase();

    if (c.contains("cashier")) return Icons.point_of_sale_outlined;
    if (c.contains("sales")) return Icons.storefront_outlined;
    if (c.contains("delivery")) return Icons.local_shipping_outlined;
    if (c.contains("manager")) return Icons.badge_outlined;
    return Icons.person_outline;
  }

  Color getCategoryColor(String category) {
    final c = category.toLowerCase();

    if (c.contains("cashier")) return const Color(0xff1E88E5);
    if (c.contains("sales")) return const Color(0xff6D5DF6);
    if (c.contains("delivery")) return const Color(0xffFB8C00);
    if (c.contains("manager")) return const Color(0xff2E7D32);
    return Colors.grey;
  }

  Future<void> paySalaryPopup() async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF7F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _PaySalarySheet(),
    );

    if (!mounted || amount == null) return;

    setState(() {
      payments.add({
        "amount": amount,
        "date": DateTime.now().toString(),
      });

      widget.employee["payments"] = payments;
    });
  }

  Widget summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emp = widget.employee;

    final String name = emp["name"]?.toString() ?? "Employee";
    final String phone = emp["phone"]?.toString() ?? "";
    final String category = emp["category"]?.toString() ?? "Other";
    final int salaryDate = emp["salaryDate"] ?? 1;
    final String notes = emp["notes"]?.toString() ?? "";
    final Color categoryColor = getCategoryColor(category);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: const Color(0xff2E7D32),
        foregroundColor: Colors.white,
        onPressed: paySalaryPopup,
        icon: const Icon(Icons.payments_outlined),
        label: const Text("Pay Salary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff2563EB),
                    Color(0xff0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      getCategoryIcon(category),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Salary date: $salaryDate",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    title: "Monthly Salary",
                    value: formatCurrency(monthlySalary),
                    color: const Color(0xff1E88E5),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: summaryCard(
                    title: "Paid",
                    value: formatCurrency(totalPaid),
                    color: const Color(0xff2E7D32),
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    title: "Pending",
                    value: formatCurrency(pendingSalary),
                    color: pendingSalary <= 0
                        ? const Color(0xff2E7D32)
                        : const Color(0xffE53935),
                    icon: pendingSalary <= 0
                        ? Icons.verified_outlined
                        : Icons.pending_actions_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: summaryCard(
                    title: "Payments",
                    value: payments.length.toString(),
                    color: categoryColor,
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Employee Details",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  detailRow("Name", name),
                  detailRow("Phone", phone.isEmpty ? "-" : phone),
                  detailRow("Category", category),
                  detailRow("Salary Date", salaryDate.toString()),
                  detailRow("Monthly Salary", formatCurrency(monthlySalary)),
                  detailRow(
                    "Pending Salary",
                    formatCurrency(pendingSalary),
                    valueColor: pendingSalary <= 0
                        ? const Color(0xff2E7D32)
                        : const Color(0xffE53935),
                  ),
                  if (notes.isNotEmpty) detailRow("Notes", notes),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment History",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: payments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.payments_outlined,
                            size: 42,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No payments yet",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (_, index) {
                        final p = payments[index];
                        final double amount =
                            ((p["amount"] ?? 0) as num).toDouble();
                        final String date =
                            p["date"]?.toString().split(".")[0] ?? "";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xff2E7D32)
                                      .withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  color: Color(0xff2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatCurrency(amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff2E7D32)
                                      .withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  "Paid",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff2E7D32),
                                  ),
                                ),
                              ),
                            ],
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
}

class _PaySalarySheet extends StatefulWidget {
  const _PaySalarySheet();

  @override
  State<_PaySalarySheet> createState() => _PaySalarySheetState();
}

class _PaySalarySheetState extends State<_PaySalarySheet> {
  final TextEditingController _amountCtrl = TextEditingController();
  String? _amountError;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;

    setState(() {
      _amountError = amount <= 0 ? "Enter valid amount" : null;
    });

    if (amount <= 0) return;

    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pay Salary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Amount (₹)",
                errorText: _amountError,
                prefixIcon: const Icon(Icons.currency_rupee),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.payments_outlined),
                label: const Text("Confirm Payment"),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
