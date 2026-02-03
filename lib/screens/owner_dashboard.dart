import 'package:flutter/material.dart';

import 'dashboard_home_screen.dart';
import 'product_screen.dart';
import 'employee_screen.dart';
import 'customer_list_screen.dart';
import 'ledger_summary_screen.dart';
import 'wholesaler_order_list_screen.dart'; // ✅ NEW

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _index = 0;

  // 🔑 ORDER MUST MATCH bottom nav order
  final pages = const [
    DashboardHomeScreen(),        // 0 Overview
    ProductScreen(),              // 1 Products
    EmployeeScreen(),             // 2 Employees
    WholesalerOrderListScreen(),  // 3 Orders ✅
    CustomerListScreen(),         // 4 Customers
    LedgerSummaryScreen(),        // 5 Ledger
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
      ),
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

          // ✅ NEW ORDERS TAB
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: "Orders",
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
