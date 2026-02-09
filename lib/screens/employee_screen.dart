import 'package:flutter/material.dart';
import 'employee_salary_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final List<Map<String, String>> _employees = [];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _role = "Cashier";

  void _addEmployee() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _employees.add({
        "name": _nameController.text,
        "phone": _phoneController.text,
        "role": _role,
      });
    });

    _nameController.clear();
    _phoneController.clear();
    Navigator.pop(context);
  }

  /// ✅ CENTER SCREEN ADD EMPLOYEE (FIXED)
  void _showAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add Employee",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NAME
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Employee Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? "Enter name" : null,
                  ),

                  const SizedBox(height: 15),

                  // PHONE
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: Icon(Icons.phone),
                      counterText: "",
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Enter mobile number";
                      }
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                        return "Enter valid 10-digit number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // ROLE
                  DropdownButtonFormField(
                    value: _role,
                    items: const [
                      DropdownMenuItem(
                          value: "Cashier", child: Text("Cashier")),
                      DropdownMenuItem(
                          value: "Salesman", child: Text("Salesman")),
                      DropdownMenuItem(
                          value: "Delivery", child: Text("Delivery Boy")),
                      DropdownMenuItem(
                          value: "Manager", child: Text("Manager")),
                    ],
                    onChanged: (v) => setState(() => _role = v!),
                    decoration: const InputDecoration(
                      labelText: "Employee Role",
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addEmployee,
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeEmployee(int index) {
    setState(() => _employees.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),

      body: _employees.isEmpty
          ? const Center(child: Text("No Employees Added"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final emp = _employees[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child:
                const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                emp["name"]!,
                style:
                const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle:
              Text("${emp["role"]} • ${emp["phone"]}"),

              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(
                    icon: const Icon(Icons.currency_rupee,
                        color: Colors.green),
                    tooltip: "Salary",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployeeSalaryScreen(
                            name: emp["name"]!,
                            role: emp["role"]!,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () => _removeEmployee(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
