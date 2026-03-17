import 'package:flutter/material.dart';

class DashboardHomeScreen extends StatelessWidget {
  final String userName;

  const DashboardHomeScreen({
    super.key,
    this.userName = '',
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final displayName = userName.trim();
    final greeting = _getGreeting();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName.isEmpty ? greeting : "$greeting, $displayName",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayName.isEmpty
                ? "Welcome to Smart Khatabook"
                : "Welcome back, $displayName",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Overview",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _infoCard(
                context,
                icon: Icons.inventory_2,
                title: "Products",
                value: "24",
                color: primary,
              ),
              _infoCard(
                context,
                icon: Icons.people,
                title: "Customers",
                value: "18",
                color: Colors.green,
              ),
              _infoCard(
                context,
                icon: Icons.currency_rupee,
                title: "Today Sales",
                value: "₹2,450",
                color: Colors.orange,
              ),
              _infoCard(
                context,
                icon: Icons.warning_amber,
                title: "Low Stock",
                value: "3",
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color color,
      }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
