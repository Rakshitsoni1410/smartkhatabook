import 'package:flutter/material.dart';

import '../models/user_role.dart';
import 'dashboard_home_screen.dart';
import 'employee_screen.dart';
import 'ledger_summary_screen.dart';
import 'product_screen.dart';
import 'review_screen.dart';
import 'wholesaler_order_list_screen.dart';

class OwnerDashboard extends StatefulWidget {
  final String userId;
  final String userName;
  final String shopName;
  final String businessType;
  final UserRole userRole;

  const OwnerDashboard({
    super.key,
    required this.userId,
    this.userName = '',
    this.shopName = '',
    this.businessType = '',
    required this.userRole,
  });

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _index = 0;
  late final List<_DashboardTabConfig> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
  }

  List<_DashboardTabConfig> _buildTabs() {
    final home = DashboardHomeScreen(
      userId: widget.userId,
      userName: widget.userName,
      shopName: widget.shopName,
      businessType: widget.businessType,
      userRole: widget.userRole,
    );

    final reviews = ReviewScreen(
      userId: widget.userId,
      userRole: widget.userRole,
      shopName: widget.shopName,
      businessType: widget.businessType,
    );

    switch (widget.userRole) {
      case UserRole.owner:
        return [
          _DashboardTabConfig(
            page: home,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
          ),
          _DashboardTabConfig(
            page: ProductScreen(
              userId: widget.userId,
              userRole: widget.userRole,
              userName: widget.userName,
              shopName: widget.shopName,
              initialBusinessType: widget.businessType,
            ),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Stock',
            ),
          ),
          _DashboardTabConfig(
            page: const EmployeeScreen(),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Employees',
            ),
          ),
          _DashboardTabConfig(
            page: WholesalerOrderListScreen(
              title: 'All Orders',
              userId: widget.userId,
              userRole: widget.userRole.label,
            ),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              label: 'Orders',
            ),
          ),
          _DashboardTabConfig(
            page: const LedgerSummaryScreen(),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Ledger',
            ),
          ),
          _DashboardTabConfig(
            page: reviews,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined),
              label: 'Reviews',
            ),
          ),
        ];

      case UserRole.wholesaler:
        return [
          _DashboardTabConfig(
            page: home,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
          ),
          _DashboardTabConfig(
            page: ProductScreen(
              userId: widget.userId,
              userRole: widget.userRole,
              userName: widget.userName,
              shopName: widget.shopName,
              initialBusinessType: widget.businessType,
            ),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Stock',
            ),
          ),
          _DashboardTabConfig(
            page: const EmployeeScreen(),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Employees',
            ),
          ),
          _DashboardTabConfig(
            page: WholesalerOrderListScreen(
              title: 'Orders',
              userId: widget.userId,
              userRole: widget.userRole.label,
            ),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              label: 'Orders',
            ),
          ),
          _DashboardTabConfig(
            page: reviews,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined),
              label: 'Reviews',
            ),
          ),
        ];

      case UserRole.customer:
        return [
          _DashboardTabConfig(
            page: home,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
          ),
          _DashboardTabConfig(
            page: const LedgerSummaryScreen(),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Ledger',
            ),
          ),
          _DashboardTabConfig(
            page: reviews,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined),
              label: 'Reviews',
            ),
          ),
        ];

      case UserRole.retailer:
        return [
          _DashboardTabConfig(
            page: home,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
          ),
          _DashboardTabConfig(
            page: ProductScreen(
              userId: widget.userId,
              userRole: widget.userRole,
              userName: widget.userName,
              shopName: widget.shopName,
              initialBusinessType: widget.businessType,
            ),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Stock',
            ),
          ),
          _DashboardTabConfig(
            page: const EmployeeScreen(),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Employee',
            ),
          ),
          _DashboardTabConfig(
            page: WholesalerOrderListScreen(
              title: 'Order Status',
              userId: widget.userId,
              userRole: widget.userRole.label,
            ),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              label: 'Status',
            ),
          ),
          _DashboardTabConfig(
            page: const LedgerSummaryScreen(),
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Ledger',
            ),
          ),
          _DashboardTabConfig(
            page: reviews,
            item: const BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined),
              label: 'Reviews',
            ),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2563EB),
        unselectedItemColor: Colors.grey,
        items: _tabs.map((tab) => tab.item).toList(),
      ),
    );
  }
}

class _DashboardTabConfig {
  final Widget page;
  final BottomNavigationBarItem item;

  const _DashboardTabConfig({required this.page, required this.item});
}
