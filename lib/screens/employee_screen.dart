import 'package:flutter/material.dart';
import 'employee_detail_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  String searchText = "";

  // ✅ Dummy Employee for Testing
  List<Map<String, dynamic>> employees = [
    {
      "name": "Rahul Sharma",
      "phone": "9876543210",
      "category": "Salesman",
      "salary": 15000.0,
      "salaryDate": 5, // salary paid every month on 5th
      "notes": "",
      "payments": <Map<String, dynamic>>[],
    }
  ];

  // ================= FILTER =================
  List<Map<String, dynamic>> get filteredEmployees {
    return employees.where((emp) {
      return emp["name"]
          .toLowerCase()
          .contains(searchText.toLowerCase()) ||
          emp["phone"].contains(searchText);
    }).toList();
  }

  double get totalSalary {
    return employees.fold(
        0, (sum, emp) => sum + (emp["salary"] ?? 0));
  }

  // ================= ADD / EDIT FORM =================
  void openEmployeeForm({Map<String, dynamic>? employee}) {
    bool isEdit = employee != null;

    TextEditingController nameCtrl =
    TextEditingController(text: employee?["name"]);
    TextEditingController phoneCtrl =
    TextEditingController(text: employee?["phone"]);
    TextEditingController salaryCtrl =
    TextEditingController(
        text: employee?["salary"]?.toString());
    TextEditingController notesCtrl =
    TextEditingController(text: employee?["notes"]);

    String category = employee?["category"] ?? "Salesman";
    int salaryDate = employee?["salaryDate"] ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      isEdit
                          ? "Edit Employee"
                          : "Add Employee",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: nameCtrl,
                      decoration:
                      const InputDecoration(
                        labelText: "Name",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: phoneCtrl,
                      keyboardType:
                      TextInputType.phone,
                      decoration:
                      const InputDecoration(
                        labelText: "Phone",
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField(
                      value: category,
                      items: [
                        "Cashier",
                        "Salesman",
                        "Delivery Boy",
                        "Manager",
                        "Other"
                      ]
                          .map((c) =>
                          DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                          .toList(),
                      onChanged: (val) {
                        setModalState(
                                () => category = val!);
                      },
                      decoration:
                      const InputDecoration(
                        labelText: "Category",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: salaryCtrl,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText: "Monthly Salary",
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ Salary Date Picker
                    DropdownButtonFormField<int>(
                      value: salaryDate,
                      items: List.generate(
                        31,
                            (index) =>
                            DropdownMenuItem(
                              value: index + 1,
                              child:
                              Text("${index + 1}"),
                            ),
                      ),
                      onChanged: (val) {
                        setModalState(
                                () => salaryDate = val!);
                      },
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Salary Pay Date (Day of Month)",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: notesCtrl,
                      decoration:
                      const InputDecoration(
                        labelText: "Notes",
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton
                          .styleFrom(
                        minimumSize:
                        const Size(
                            double.infinity,
                            50),
                        backgroundColor:
                        Colors.blueAccent,
                      ),
                      child: Text(isEdit
                          ? "Update"
                          : "Save"),
                      onPressed: () {
                        if (nameCtrl.text
                            .trim()
                            .isEmpty) return;

                        if (isEdit) {
                          setState(() {
                            employee["name"] =
                                nameCtrl.text;
                            employee["phone"] =
                                phoneCtrl.text;
                            employee["category"] =
                                category;
                            employee["salary"] =
                                double.tryParse(
                                    salaryCtrl
                                        .text) ??
                                    0;
                            employee["salaryDate"] =
                                salaryDate;
                            employee["notes"] =
                                notesCtrl.text;
                          });
                        } else {
                          setState(() {
                            employees.add({
                              "name":
                              nameCtrl.text,
                              "phone":
                              phoneCtrl.text,
                              "category":
                              category,
                              "salary":
                              double.tryParse(
                                  salaryCtrl
                                      .text) ??
                                  0,
                              "salaryDate":
                              salaryDate,
                              "notes":
                              notesCtrl.text,
                              "payments":
                              <Map<String,
                                  dynamic>>[],
                            });
                          });
                        }

                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton:
      FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () =>
            openEmployeeForm(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [

            // Salary Summary
            Container(
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people),
                  const SizedBox(width: 10),
                  Text(
                    "Total Salary: ₹${totalSalary.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontWeight:
                        FontWeight.bold),
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration:
              const InputDecoration(
                hintText:
                "Search employee...",
                prefixIcon:
                Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() =>
                searchText = val);
              },
            ),

            const SizedBox(height: 15),

            Expanded(
              child:
              filteredEmployees.isEmpty
                  ? const Center(
                  child: Text(
                      "No employees"))
                  : ListView.builder(
                itemCount:
                filteredEmployees
                    .length,
                itemBuilder:
                    (_, index) {
                  final emp =
                  filteredEmployees[
                  index];

                  return Card(
                    child:
                    ListTile(
                      title: Text(
                          emp[
                          "name"]),
                      subtitle: Text(
                          "₹${emp["salary"]} | Pay on ${emp["salaryDate"]}"),
                      trailing:
                      PopupMenuButton(
                        itemBuilder:
                            (_) => [
                          const PopupMenuItem(
                            value:
                            "edit",
                            child: Text(
                                "Edit"),
                          ),
                          const PopupMenuItem(
                            value:
                            "delete",
                            child: Text(
                                "Delete"),
                          ),
                        ],
                        onSelected:
                            (val) {
                          if (val ==
                              "edit") {
                            openEmployeeForm(
                                employee:
                                emp);
                          } else {
                            setState(
                                    () {
                                  employees.remove(
                                      emp);
                                });
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                EmployeeDetail(
                                  employee:
                                  emp,
                                ),
                          ),
                        );
                      },
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
