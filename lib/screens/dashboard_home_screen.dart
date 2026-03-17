import 'package:flutter/material.dart';
import '../models/user_role.dart';

class DashboardHomeScreen extends StatelessWidget {
  final String userName;
  final String shopName;
  final String businessType;
  final UserRole userRole;

  const DashboardHomeScreen({
    super.key,
    this.userName = '',
    this.shopName = '',
    this.businessType = '',
    required this.userRole,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }
    if (hour < 17) {
      return "Good Afternoon";
    }
    return "Good Evening";
  }

  List<_DashboardMetric> _metricsForRole() {
    switch (userRole) {
      case UserRole.owner:
        return const [
          _DashboardMetric(
            icon: Icons.store_outlined,
            title: 'Total Shops',
            value: '5',
            color: Color(0xFF2563EB),
          ),
          _DashboardMetric(
            icon: Icons.people_outline,
            title: 'Total Staff',
            value: '18',
            color: Color(0xFF2E7D32),
          ),
          _DashboardMetric(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            value: '140',
            color: Color(0xFFF57C00),
          ),
          _DashboardMetric(
            icon: Icons.currency_rupee,
            title: 'Revenue',
            value: '₹52K',
            color: Color(0xFF8E24AA),
          ),
        ];

      case UserRole.wholesaler:
        return const [
          _DashboardMetric(
            icon: Icons.inventory_2_outlined,
            title: 'Stock Items',
            value: '24',
            color: Color(0xFF2563EB),
          ),
          _DashboardMetric(
            icon: Icons.group_outlined,
            title: 'Employees',
            value: '6',
            color: Color(0xFF2E7D32),
          ),
          _DashboardMetric(
            icon: Icons.local_shipping_outlined,
            title: 'Orders',
            value: '12',
            color: Color(0xFFF57C00),
          ),
          _DashboardMetric(
            icon: Icons.reviews_outlined,
            title: 'Reviews',
            value: '18',
            color: Color(0xFF8E24AA),
          ),
        ];

      case UserRole.retailer:
        return const [
          _DashboardMetric(
            icon: Icons.inventory_2_outlined,
            title: 'Stock Items',
            value: '18',
            color: Color(0xFF2563EB),
          ),
          _DashboardMetric(
            icon: Icons.group_outlined,
            title: 'Employees',
            value: '4',
            color: Color(0xFFF57C00),
          ),
          _DashboardMetric(
            icon: Icons.local_shipping_outlined,
            title: 'Order Status',
            value: '3',
            color: Color(0xFF2E7D32),
          ),
          _DashboardMetric(
            icon: Icons.book_outlined,
            title: 'Ledger',
            value: '6',
            color: Color(0xFF8E24AA),
          ),
        ];

      case UserRole.customer:
        return const [
          _DashboardMetric(
            icon: Icons.book_outlined,
            title: 'Ledger Entries',
            value: '8',
            color: Color(0xFF2563EB),
          ),
          _DashboardMetric(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Due Amount',
            value: '₹1,250',
            color: Color(0xFFE53935),
          ),
          _DashboardMetric(
            icon: Icons.done_all_outlined,
            title: 'Settled Bills',
            value: '5',
            color: Color(0xFF2E7D32),
          ),
          _DashboardMetric(
            icon: Icons.reviews_outlined,
            title: 'Reviews',
            value: '3',
            color: Color(0xFF8E24AA),
          ),
        ];
    }
  }

  String _getFocusText() {
    switch (userRole) {
      case UserRole.owner:
        return 'Monitor all shops, track revenue, review staff performance, and keep business operations running smoothly.';
      case UserRole.wholesaler:
        return 'Manage stock, monitor employees, handle incoming retailer orders, and review customer feedback.';
      case UserRole.retailer:
        return 'Manage stock, review employees, track order status, keep ledger updated, and monitor reviews.';
      case UserRole.customer:
        return 'Check your latest ledger entries and stay on top of recent activity.';
    }
  }

  String _getRoleSubtitle() {
    switch (userRole) {
      case UserRole.owner:
        return 'Owner account';
      case UserRole.wholesaler:
        return 'Wholesaler account';
      case UserRole.retailer:
        return 'Retailer account';
      case UserRole.customer:
        return 'Customer account';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userName.trim();
    final displayShopName = shopName.trim();
    final displayBusinessType =
        businessType.trim().isEmpty ? 'General' : businessType.trim();
    final greeting = _getGreeting();
    final metrics = _metricsForRole();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text(userRole.dashboardTitle),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isEmpty ? greeting : '$greeting, $displayName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayShopName.isEmpty
                        ? _getRoleSubtitle()
                        : displayShopName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$displayBusinessType business',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final metric = metrics[index];
                return _infoCard(context, metric);
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Focus",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getFocusText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, _DashboardMetric metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: metric.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: metric.color),
          ),
          const Spacer(),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DashboardMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}