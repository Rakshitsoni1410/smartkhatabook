import 'package:flutter/material.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final List<Map<String, String>> _employees = [];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = "Cashier";

  void _addEmployee() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;

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

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Employee",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Employee Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: _role,
              items: const [
                DropdownMenuItem(value: "Cashier", child: Text("Cashier")),
                DropdownMenuItem(value: "Salesman", child: Text("Salesman")),
                DropdownMenuItem(value: "Delivery", child: Text("Delivery Boy")),
                DropdownMenuItem(value: "Manager", child: Text("Manager")),
              ],
              onChanged: (v) => setState(() => _role = v!),
              decoration: const InputDecoration(
                labelText: "Employee Role",
                prefixIcon: Icon(Icons.badge),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addEmployee,
                icon: const Icon(Icons.save),
                label: const Text("Save Employee"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeEmployee(int index) {
    setState(() => _employees.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),

      body: _employees.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 70,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              "No Employees Yet",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Tap + button to add staff",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
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
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                emp["name"]!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                "${emp["role"]} • ${emp["phone"]}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeEmployee(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
