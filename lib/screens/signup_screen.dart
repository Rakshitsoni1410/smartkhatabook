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

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _shopController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _role = UserRole.retailer;
  File? _logoFile;

  // 📷 PICK LOGO (OPTIONAL)
  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // 🔐 DEMO DATA (later send to backend)
    final data = {
      "name": _nameController.text,
      "mobile": _mobileController.text,
      "role": _role.name,
      "shopName": _role == UserRole.customer ? null : _shopController.text,
      "address": _addressController.text,
      "logo": _logoFile?.path,
    };

    debugPrint("SIGNUP DATA: $data");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account Created Successfully")),
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
              // 🔹 FULL NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter full name" : null,
              ),

              const SizedBox(height: 12),

              // 🔹 MOBILE (10 DIGIT)
              TextFormField(
                controller: _mobileController,
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

              // 🔹 USER ROLE
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: "User Role",
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(
                      value: UserRole.wholesaler,
                      child: Text("Wholesaler")),
                  DropdownMenuItem(
                      value: UserRole.retailer,
                      child: Text("Retailer")),
                  DropdownMenuItem(
                      value: UserRole.customer,
                      child: Text("Customer")),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),

              const SizedBox(height: 12),

              // 🔹 SHOP NAME (ONLY FOR SHOP OWNERS)
              if (_role != UserRole.customer)
                TextFormField(
                  controller: _shopController,
                  decoration: const InputDecoration(
                    labelText: "Shop / Business Name",
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (v) {
                    if (_role != UserRole.customer &&
                        (v == null || v.isEmpty)) {
                      return "Enter shop name";
                    }
                    return null;
                  },
                ),

              if (_role != UserRole.customer) const SizedBox(height: 12),

              // 🔹 LOGO UPLOAD (OPTIONAL)
              if (_role != UserRole.customer)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                      _logoFile != null ? FileImage(_logoFile!) : null,
                      child: _logoFile == null
                          ? const Icon(Icons.store)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Logo (Optional)"),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // 🔹 ADDRESS
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) =>
                v == null || v.length < 6 ? "Min 6 characters" : null,
              ),

              const SizedBox(height: 12),

              // 🔹 CONFIRM PASSWORD
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
