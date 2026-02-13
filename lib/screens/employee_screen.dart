import 'package:flutter/material.dart';
import 'employee_detail_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List<Map<String, dynamic>> employees = [];

  String searchText = "";

  // ✅ Filter employees
  List<Map<String, dynamic>> get filteredEmployees {
    return employees.where((emp) {
      return emp["name"]
          .toLowerCase()
          .contains(searchText.toLowerCase()) ||
          emp["phone"].contains(searchText);
    }).toList();
  }

  // ✅ Total Salary
  double get totalSalary {
    return employees.fold(
        0, (sum, emp) => sum + (emp["salary"] ?? 0));
  }

  // ==============================
  // ADD EMPLOYEE FORM
  // ==============================
  void openAddEmployeeForm() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController phoneCtrl = TextEditingController();
    TextEditingController salaryCtrl = TextEditingController();
    TextEditingController notesCtrl = TextEditingController();

    String category = "Salesman";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ✅ Important
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,

              // ✅ Keyboard Padding Fix
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),

                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ✅ Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Add Employee",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),

                        const SizedBox(height: 15),

                        // ✅ Name
                        const Text("Employee Name *"),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nameCtrl,
                          decoration: inputStyle("Enter name"),
                        ),

                        const SizedBox(height: 12),

                        // ✅ Phone
                        const Text("Phone Number *"),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: inputStyle("Enter phone number"),
                        ),

                        const SizedBox(height: 10),

                        // ✅ Category Dropdown
                        const Text("Employee Category"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField(
                          value: category,
                          decoration: inputStyle("Select category"),
                          items: [
                            "Cashier",
                            "Salesman",
                            "Delivery Boy",
                            "Manager",
                            "Other"
                          ]
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setModalState(() {
                              category = val!;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // ✅ Salary
                        const Text("Monthly Salary (₹)"),
                        const SizedBox(height: 6),
                        TextField(
                          controller: salaryCtrl,
                          keyboardType: TextInputType.number,
                          decoration: inputStyle("Enter salary"),
                        ),

                        const SizedBox(height: 12),

                        // ✅ Notes
                        const Text("Notes (Optional)"),
                        const SizedBox(height: 6),
                        TextField(
                          controller: notesCtrl,
                          maxLines: 2,
                          decoration: inputStyle("Extra details"),
                        ),

                        const SizedBox(height: 20),

                        // ✅ Save Button (Always Visible)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Save Employee",
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              if (nameCtrl.text.trim().isEmpty) return;

                              setState(() {
                                employees.add({
                                  "date": DateTime.now().toString(),
                                  "name": nameCtrl.text.trim(),
                                  "phone": phoneCtrl.text.trim(),
                                  "category": category,
                                  "salary":
                                  double.tryParse(salaryCtrl.text) ?? 0,
                                  "notes": notesCtrl.text.trim(),
                                  "payments": <Map<String, dynamic>>[],
                                });
                              });

                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==============================
  // UI INPUT STYLE
  // ==============================
  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ==============================
  // MAIN UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
        backgroundColor: Colors.green.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Center(
              child: Text("${employees.length} employees"),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        onPressed: openAddEmployeeForm,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.people,
                        color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Monthly Salary",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "₹${totalSalary.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by name or phone...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (val) {
                setState(() => searchText = val);
              },
            ),

            const SizedBox(height: 16),

            // Employee List
            Expanded(
              child: filteredEmployees.isEmpty
                  ? const Center(
                child: Text("No employees found"),
              )
                  : ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final emp = filteredEmployees[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EmployeeDetail(employee: emp),
                        ),
                      );
                    },
                    child: employeeCard(emp),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==============================
  // EMPLOYEE CARD
  // ==============================
  Widget employeeCard(Map<String, dynamic> emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green.shade100,
            child: Text(
              emp["name"][0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp["name"],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  emp["phone"],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          Text(
            "₹${emp["salary"]}",
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
