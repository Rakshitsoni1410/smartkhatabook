import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_role.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  UserRole _role = UserRole.retailer;
  File? _logo;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickLogo() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _logo = File(image.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // 🔹 DEMO SUBMIT (Backend later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully")),
    );

    Navigator.pop(context);
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
              /// 🔹 LOGO UPLOAD
              GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                  _logo != null ? FileImage(_logo!) : null,
                  child: _logo == null
                      ? const Icon(Icons.camera_alt,
                      size: 28, color: Colors.blue)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Upload Shop Logo (optional)",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// 🔹 FULL NAME
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter full name" : null,
              ),

              const SizedBox(height: 12),

              /// 🔹 MOBILE NUMBER (10 DIGIT)
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone),
                  counterText: "",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter mobile number";
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                    return "Enter valid 10-digit number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              /// 🔹 USER ROLE
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: "User Role",
                  prefixIcon: Icon(Icons.business),
                ),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.wholesaler,
                    child: Text("Wholesaler"),
                  ),
                  DropdownMenuItem(
                    value: UserRole.retailer,
                    child: Text("Retailer"),
                  ),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),

              const SizedBox(height: 12),

              /// 🔹 SHOP / BUSINESS NAME
              TextFormField(
                controller: _shopCtrl,
                decoration: const InputDecoration(
                  labelText: "Shop / Business Name",
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter shop name" : null,
              ),

              const SizedBox(height: 12),

              /// 🔹 ADDRESS
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: "Address",
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 PASSWORD
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) =>
                v!.length < 6 ? "Min 6 characters" : null,
              ),

              const SizedBox(height: 12),

              /// 🔹 CONFIRM PASSWORD
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                v != _passwordCtrl.text
                    ? "Passwords do not match"
                    : null,
              ),

              const SizedBox(height: 24),

              /// 🔹 SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
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
