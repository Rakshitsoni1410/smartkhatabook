import 'package:flutter/material.dart';
import 'owner_dashboard.dart';
import 'customer_dashboard.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final UserRole role;

  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Mobile (10-digit validation)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter mobile number';
                }
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Enter valid 10-digit mobile number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                if (role == UserRole.shopkeeper) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerDashboard(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerDashboard(),
                    ),
                  );
                }
              },
              child: const Text('Login'),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
