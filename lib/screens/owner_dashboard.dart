import 'package:flutter/material.dart';
import 'dashboard_home_screen.dart';
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

  // 🔑 ORDER MATTERS (same as bottom nav)
  final pages = const [
    DashboardHomeScreen(),   // 0
    ProductScreen(),         // 1
    EmployeeScreen(),        // 2
    CustomerListScreen(),    // 3
    LedgerSummaryScreen(),   // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Owner Dashboard")),
      body: pages[_index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          // ✅ NEW OVERVIEW ICON
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Overview",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Products",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Employees",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Customers",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Ledger",
          ),
        ],
      ),
    );
  }
}
