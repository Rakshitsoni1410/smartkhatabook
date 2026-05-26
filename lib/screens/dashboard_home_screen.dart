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

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with TickerProviderStateMixin {
  int stock = 0;
  int employees = 0;
  int orders = 0;
  int reviews = 0;
  bool isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() => isLoading = false);
      _fadeController.forward();
      _slideController.forward();
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
      _DashboardMetric(
        Icons.inventory_2_rounded,
        'Stock',
        stock,
        const Color(0xFF3B82F6),
        const Color(0xFFEFF6FF),
      ),
      _DashboardMetric(
        Icons.group_rounded,
        'Employees',
        employees,
        const Color(0xFFF97316),
        const Color(0xFFFFF7ED),
      ),
      _DashboardMetric(
        Icons.local_shipping_rounded,
        'Orders',
        orders,
        const Color(0xFF10B981),
        const Color(0xFFECFDF5),
      ),
      _DashboardMetric(
        Icons.star_rounded,
        'Reviews',
        reviews,
        const Color(0xFF8B5CF6),
        const Color(0xFFF5F3FF),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  color: const Color(0xFF3B82F6),
                  onRefresh: loadDashboardData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── HEADER ──────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _buildHeader(),
                        ),
                      ),

                      // ── SECTION TITLE ────────────────────────────
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            "Dashboard Overview",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),

                      // ── METRICS GRID ────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildMetricCard(metrics[index], index),
                            childCount: metrics.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.15,
                              ),
                        ),
                      ),

                      // ── INSIGHT BANNER ──────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildInsightBanner(),
                        ),
                      ),

                      // ── QUICK ACTIONS ───────────────────────────
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildQuickActions(),
                        ),
                      ),

                      // ── RECENT ACTIVITY ─────────────────────────
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            "Recent Activity",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          child: _buildRecentActivity(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Row(
            children: [
              _headerChip(Icons.store_rounded, widget.shopName),
              const SizedBox(width: 10),
              _headerChip(Icons.category_rounded, widget.businessType),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── METRIC CARD ───────────────────────────────────────────────────────────
  Widget _buildMetricCard(_DashboardMetric m, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: m.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(m.icon, color: m.color, size: 22),
            ),
            const Spacer(),
            Text(
              "${m.value}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              m.title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── INSIGHT BANNER ────────────────────────────────────────────────────────
  Widget _buildInsightBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Keep track of your performance and improve your business 🚀",
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(Icons.add_circle_rounded, "Add", const Color(0xFF3B82F6)),
      _QuickAction(
        Icons.shopping_cart_rounded,
        "Order",
        const Color(0xFF10B981),
      ),
      _QuickAction(Icons.bar_chart_rounded, "Report", const Color(0xFF8B5CF6)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions
            .map(
              (a) => InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(a.icon, color: a.color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── RECENT ACTIVITY ───────────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final activities = [
      _Activity(
        "Order placed",
        "2 min ago",
        Icons.local_shipping_rounded,
        const Color(0xFF10B981),
        const Color(0xFFECFDF5),
      ),
      _Activity(
        "New review",
        "10 min ago",
        Icons.star_rounded,
        const Color(0xFF8B5CF6),
        const Color(0xFFF5F3FF),
      ),
      _Activity(
        "Stock updated",
        "1 hr ago",
        Icons.inventory_2_rounded,
        const Color(0xFF3B82F6),
        const Color(0xFFEFF6FF),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 68, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final a = activities[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: a.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(a.icon, color: a.color, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    a.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Text(
                  a.time,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── DATA CLASSES ──────────────────────────────────────────────────────────────
class _DashboardMetric {
  final IconData icon;
  final String title;
  final int value;
  final Color color;
  final Color bgColor;

  _DashboardMetric(this.icon, this.title, this.value, this.color, this.bgColor);
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;

  _QuickAction(this.icon, this.label, this.color);
}

class _Activity {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _Activity(this.title, this.time, this.icon, this.color, this.bgColor);
}
