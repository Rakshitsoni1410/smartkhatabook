import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart'; // ✅ added

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget appLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade200],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        size: 50,
        color: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            appLogo(),
            const SizedBox(height: 16),
            const Text(
              'Smart Khata',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Digital Ledger for Small Businesses',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _roleCard(context, title: 'Business Owner', icon: Icons.store),
            const SizedBox(height: 20),
            _roleCard(context, title: 'Customer', icon: Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              role: title == 'Business Owner'
                  ? UserRole.shopkeeper
                  : UserRole.customer,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
