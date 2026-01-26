import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCards(),
            const SizedBox(height: 24),
            _pieChartCard(),
            const SizedBox(height: 24),
            _barChartCard(),
          ],
        ),
      ),
    );
  }

  // ===== Summary =====
  Widget _summaryCards() {
    return Row(
      children: const [
        Expanded(
          child: _SummaryCard(
            title: 'Total Credit',
            amount: '₹8,000',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Total Debit',
            amount: '₹5,500',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ===== Pie Chart =====
  Widget _pieChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Spending Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'Groceries',
                      color: Colors.blue,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 35,
                      title: 'Stationery',
                      color: Colors.orange,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 25,
                      title: 'Others',
                      color: Colors.purple,
                      radius: 60,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Bar Chart =====
  Widget _barChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Monthly Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _bar(0, 2.5),
                    _bar(1, 3.2),
                    _bar(2, 1.8),
                    _bar(3, 4.0),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr'];
                          return Text(months[value.toInt()]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}

// ===== Summary Card Widget =====
class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
