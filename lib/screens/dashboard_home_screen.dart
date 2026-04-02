import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user_role.dart';

class DashboardHomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String shopName;
  final String businessType;
  final UserRole userRole;

  const DashboardHomeScreen({
    super.key,
    required this.userId,
    this.userName = '',
    this.shopName = '',
    this.businessType = '',
    required this.userRole,
  });

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int stock = 0;
  int employees = 0;
  int orders = 0;
  int reviews = 0;

  bool isLoading = true;

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final role = widget.userRole.label.toLowerCase().trim();

      final res = await http.get(
        Uri.parse('$baseUrl/dashboard/$role?userId=${widget.userId}'),
      );

      final data = jsonDecode(res.body);

      setState(() {
        stock = data['stock'] ?? 0;
        employees = data['employees'] ?? 0;
        orders = data['orders'] ?? 0;
        reviews = data['reviews'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  List<_DashboardMetric> _metrics() {
    return [
      _DashboardMetric(Icons.inventory_2, 'Stock', stock, Colors.blue),
      _DashboardMetric(Icons.group, 'Employees', employees, Colors.orange),
      _DashboardMetric(Icons.local_shipping, 'Orders', orders, Colors.green),
      _DashboardMetric(Icons.star, 'Reviews', reviews, Colors.purple),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics();

    return Scaffold(
      backgroundColor: const Color(0xffF1F5F9),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔥 HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_getGreeting()},",
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(widget.userName,
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.store, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(widget.shopName,
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.category,
                                  color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(widget.businessType,
                                  style: const TextStyle(
                                      color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Dashboard Overview",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 12),

                    // 🔥 GRID
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: metrics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final m = metrics[index];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: m.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(m.icon, color: m.color),
                              ),
                              const Spacer(),
                              Text("${m.value}",
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(m.title,
                                  style: TextStyle(
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // 🔥 INSIGHT
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.insights, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                "Keep track of your performance and improve your business 🚀"),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 QUICK ACTIONS
                    const Text("Quick Actions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickButton(Icons.add, "Add"),
                        _quickButton(Icons.shopping_cart, "Order"),
                        _quickButton(Icons.bar_chart, "Report"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔥 RECENT ACTIVITY
                    const Text("Recent Activity",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _activity("Order placed", "2 min ago",
                              Icons.local_shipping),
                          const Divider(),
                          _activity(
                              "New review", "10 min ago", Icons.star),
                          const Divider(),
                          _activity("Stock updated", "1 hr ago",
                              Icons.inventory),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _quickButton(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(text),
      ],
    );
  }

  Widget _activity(String title, String time, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(child: Text(title)),
        Text(time, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _DashboardMetric {
  final IconData icon;
  final String title;
  final int value;
  final Color color;

  _DashboardMetric(this.icon, this.title, this.value, this.color);
}