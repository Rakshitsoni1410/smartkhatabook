import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _shopController = TextEditingController();
  final _addressController = TextEditingController();

  String _role = "Retailer";

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration successful")),
    );

    Navigator.pop(context); // back to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 10),

              // MOBILE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone),
                  counterText: "",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter mobile number";
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                    return "Enter valid 10-digit number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // ROLE
              DropdownButtonFormField(
                value: _role,
                decoration: const InputDecoration(
                  labelText: "User Role",
                  prefixIcon: Icon(Icons.business),
                ),
                items: const [
                  DropdownMenuItem(
                      value: "Wholesaler", child: Text("Wholesaler")),
                  DropdownMenuItem(
                      value: "Retailer", child: Text("Retailer")),
                  DropdownMenuItem(
                      value: "Customer", child: Text("Customer")),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),

              const SizedBox(height: 10),

              // SHOP NAME (not for customer)
              if (_role != "Customer")
                TextFormField(
                  controller: _shopController,
                  decoration: const InputDecoration(
                    labelText: "Shop / Business Name",
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? "Enter shop name" : null,
                ),

              if (_role != "Customer") const SizedBox(height: 10),

              // ADDRESS
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter address" : null,
              ),

              const SizedBox(height: 10),

              // PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text("Create Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
