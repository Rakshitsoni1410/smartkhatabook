import 'package:flutter/material.dart';
import 'add_customer_screen.dart';
import 'customer_list_screen.dart';
import 'ledger_summary_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _index = 0;

  final pages = [
    const CustomerListScreen(),
    const LedgerSummaryScreen(),
    const Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book), label: 'Ledger'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
