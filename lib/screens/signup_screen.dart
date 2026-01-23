import 'package:flutter/material.dart';
import 'login_screen.dart';

enum UserRole { shopkeeper, customer }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _role = UserRole.shopkeeper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),

              // Mobile
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                validator: (v) => v!.isEmpty ? 'Enter mobile number' : null,
              ),

              // Password
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Enter password' : null,
              ),

              const SizedBox(height: 20),

              // ROLE SELECTION
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Role',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              RadioListTile<UserRole>(
                title: const Text('Shopkeeper'),
                value: UserRole.shopkeeper,
                groupValue: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),

              RadioListTile<UserRole>(
                title: const Text('Customer'),
                value: UserRole.customer,
                groupValue: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // For now, just go to login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(role: _role),
                      ),
                    );
                  }
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
