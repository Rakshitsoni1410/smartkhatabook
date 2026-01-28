import 'package:flutter/material.dart';
import 'product_screen.dart';
import 'employee_screen.dart';
import 'customer_list_screen.dart';
import 'ledger_summary_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _index = 0;

  final pages = const [
    ProductScreen(),
    EmployeeScreen(),
    CustomerListScreen(),
    LedgerSummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Owner Dashboard")),
      body: pages[_index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Employees"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Ledger"),
        ],
      ),
    );
  }
}
