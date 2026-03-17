import 'package:flutter/material.dart';

import 'dashboard_home_screen.dart';
import 'product_screen.dart';
import 'employee_screen.dart';
import 'customer_list_screen.dart';
import 'ledger_summary_screen.dart';
import 'wholesaler_order_list_screen.dart';

class OwnerDashboard extends StatefulWidget {
  final String userId;
  final String userName;

  const OwnerDashboard({
    super.key,
    required this.userId,
    this.userName = '',
  });

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      DashboardHomeScreen(userName: widget.userName), // 0 Overview
      ProductScreen(userId: widget.userId),       // 1 Products
      const EmployeeScreen(),                     // 2 Employees
      const WholesalerOrderListScreen(),          // 3 Orders
      const CustomerListScreen(),                 // 4 Customers
      const LedgerSummaryScreen(),                // 5 Ledger
    ];
  }

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
