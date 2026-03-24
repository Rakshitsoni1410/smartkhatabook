import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'employee_detail_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  String searchText = "";

  List<Map<String, dynamic>> employees = [
    {
      "name": "Rahul Sharma",
      "phone": "9876543210",
      "category": "Salesman",
      "salary": 15000.0,
      "salaryDate": 5,
      "notes": "",
      "payments": <Map<String, dynamic>>[],
    }
  ];

  List<Map<String, dynamic>> get filteredEmployees {
    return employees.where((emp) {
      final name = (emp["name"] ?? "").toString().toLowerCase();
      final phone = (emp["phone"] ?? "").toString();
      return name.contains(searchText.toLowerCase()) ||
          phone.contains(searchText);
    }).toList();
  }

  double get totalSalary {
    return employees.fold<double>(
      0,
      (sum, emp) => sum + ((emp["salary"] ?? 0) as num).toDouble(),
    );
  }

  int get totalEmployees => employees.length;

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

  String formatCurrency(double value) {
    return "₹${value.toStringAsFixed(0)}";
  }

  Future<void> openEmployeeForm({Map<String, dynamic>? employee}) async {
    final bool isEdit = employee != null;

    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF7F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EmployeeFormSheet(employee: employee),
    );

    if (!mounted || updated == null) return;

    setState(() {
      if (isEdit) {
        employee!.addAll(updated);
      } else {
        employees.add(updated);
      }
    });
  }

  Widget _summaryCard({
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(Map<String, dynamic> emp) {
    final String name = emp["name"]?.toString() ?? "";
    final String phone = emp["phone"]?.toString() ?? "";
    final String category = emp["category"]?.toString() ?? "Other";
    final double salary = (emp["salary"] as num?)?.toDouble() ?? 0;
    final int salaryDate = emp["salaryDate"] ?? 1;
    final Color categoryColor = getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeDetail(employee: emp),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  getCategoryIcon(category),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: TextStyle(
                        color: Colors.grey.shade700,
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
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Pay on $salaryDate",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _miniInfo(
                            title: "Salary",
                            value: formatCurrency(salary),
                            color: const Color(0xff1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) {
                  if (val == "edit") {
                    openEmployeeForm(employee: emp);
                  } else if (val == "delete") {
                    setState(() {
                      employees.remove(emp);
                    });
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: "edit",
                    child: Text("Edit"),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Employees"),
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: const Color(0xff2563EB),
        onPressed: () => openEmployeeForm(),
        child: const Icon(Icons.add),
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
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.groups_2_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Employee Management",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Manage staff, salary and pay dates",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
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
                  child: _summaryCard(
                    title: "Employees",
                    value: totalEmployees.toString(),
                    color: const Color(0xff6D5DF6),
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    title: "Total Salary",
                    value: formatCurrency(totalSalary),
                    color: const Color(0xff2E7D32),
                    icon: Icons.currency_rupee,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "Search employee...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => searchText = val);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredEmployees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.groups_outlined,
                            size: 44,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No employees found",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredEmployees.length,
                      itemBuilder: (_, index) {
                        final emp = filteredEmployees[index];
                        return _employeeCard(emp);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeFormSheet extends StatefulWidget {
  final Map<String, dynamic>? employee;

  const _EmployeeFormSheet({this.employee});

  @override
  State<_EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends State<_EmployeeFormSheet> {
  static const List<String> _categories = [
    "Cashier",
    "Salesman",
    "Delivery Boy",
    "Manager",
    "Other",
  ];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  late int _salaryDate;

  String? _nameError;
  String? _phoneError;
  String? _salaryError;

  bool get _isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.employee?["name"]?.toString() ?? "",
    );
    _phoneCtrl = TextEditingController(
      text: widget.employee?["phone"]?.toString() ?? "",
    );
    _salaryCtrl = TextEditingController(
      text: widget.employee?["salary"]?.toString() ?? "",
    );
    _notesCtrl = TextEditingController(
      text: widget.employee?["notes"]?.toString() ?? "",
    );
    _category = widget.employee?["category"]?.toString() ?? "Salesman";
    _salaryDate = widget.employee?["salaryDate"] ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _salaryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneCtrl.text.trim();

    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? "Name is required" : null;
      if (phone.isEmpty) {
        _phoneError = "Phone is required";
      } else if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
        _phoneError = "Phone number must be 10 digits";
      } else {
        _phoneError = null;
      }
      _salaryError =
          _salaryCtrl.text.trim().isEmpty ? "Salary is required" : null;
    });

    if (_nameError != null || _phoneError != null || _salaryError != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop({
      "name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "category": _category,
      "salary": double.tryParse(_salaryCtrl.text) ?? 0,
      "salaryDate": _salaryDate,
      "notes": _notesCtrl.text.trim(),
      "payments": widget.employee?["payments"] ?? <Map<String, dynamic>>[],
    });
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
            Text(
              _isEdit ? "Edit Employee" : "Add Employee",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: "Employee Name",
                errorText: _nameError,
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
           TextField(
  controller: _phoneCtrl,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
  onChanged: (value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = "Phone is required";
      } else if (value.length < 10) {
        _phoneError = "Enter 10 digit number";
      } else {
        _phoneError = null;
      }
    });
  },
  decoration: InputDecoration(
    labelText: "Phone Number",
    errorText: _phoneError,
    counterText: "",
    prefixIcon: const Icon(Icons.phone_outlined),
    suffixIcon: _phoneCtrl.text.length == 10
        ? const Icon(Icons.check_circle, color: Colors.green)
        : null,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _category = value!);
              },
              decoration: InputDecoration(
                labelText: "Category",
                prefixIcon: const Icon(Icons.work_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Salary",
                errorText: _salaryError,
                prefixIcon: const Icon(Icons.currency_rupee),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _salaryDate,
              items: List.generate(
                31,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text("${index + 1}"),
                ),
              ),
              onChanged: (value) {
                setState(() => _salaryDate = value!);
              },
              decoration: InputDecoration(
                labelText: "Salary Pay Date",
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Notes",
                prefixIcon: const Icon(Icons.note_alt_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(
                  _isEdit ? Icons.save_outlined : Icons.person_add_alt_1,
                ),
                label: Text(_isEdit ? "Update Employee" : "Save Employee"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6D5DF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
