
import 'package:flutter/material.dart';
import 'customer_detail.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String searchQuery = "";

  // ✅ Controllers for Add Customer Inputs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // ✅ Customer List (Dummy Data)
  List<Map<String, dynamic>> customers = [
    {"id": "1", "name": "Rahul Patel", "phone": "9876543210"},
    {"id": "2", "name": "Amit Shah", "phone": "9123456780"},
  ];

  // ✅ Filter Customers (Search Logic)
  List<Map<String, dynamic>> get filteredCustomers {
    return customers.where((c) {
      return c["name"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          c["phone"].toString().contains(searchQuery);
    }).toList();
  }

  // ✅ Add Customer Function
  void addCustomer() {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter name & phone")),
      );
      return;
    }

    // ✅ Add New Customer
    setState(() {
      customers.add({
        "id": DateTime.now().toString(),
        "name": name,
        "phone": phone,
      });
    });

    // Clear Inputs
    nameController.clear();
    phoneController.clear();

    // Close Bottom Sheet
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Customer Added Successfully")),
    );
  }

  // ✅ Open Add Customer Bottom Sheet
  void openAddCustomerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) {
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
              const Text(
                "Add New Customer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Name Input
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Customer Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Phone Input
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: addCustomer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Save Customer"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ AppBar Header
      appBar: AppBar(
        title: const Text("All Customers"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "${customers.length} customers",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          )
        ],
      ),

      // ✅ Body
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or phone...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // ✅ Customer List
          Expanded(
            child: filteredCustomers.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        customer["name"][0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    title: Text(
                      customer["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(customer["phone"]),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),

                    // ✅ OPEN CUSTOMER DETAIL PAGE ON TAP
                    onTap: () async {
                      // ✅ Open Customer Detail Page and wait for result
                      final deleted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerDetail(
                            name: customer["name"],
                            phone: customer["phone"],
                            balance: (customer["balance"] ?? 0.0).toDouble(),
                          ),
                        ),
                      );

                      // ✅ If customer deleted, remove from list
                      if (deleted == true) {
                        setState(() {
                          customers.remove(customer);
                        });
                      }
                    },
                  ),
                );
              },
            )
                : const Center(
              child: Text("No customers yet"),
            ),
          ),
        ],
      ),

      // ✅ Floating Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: openAddCustomerSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
