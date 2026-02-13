import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  // Pick Image
  Future<void> _pickLogo() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration successful")),
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
              if (_role != "Customer") ...[
                TextFormField(
                  controller: _shopController,
                  decoration: const InputDecoration(
                    labelText: "Shop / Business Name",
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? "Enter shop name" : null,
                ),

                const SizedBox(height: 15),

                // LOGO UPLOAD
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Shop Logo (Optional)",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _logoFile == null
                            ? const Center(
                          child: Icon(Icons.add_a_photo, size: 35),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _logoFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],

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
