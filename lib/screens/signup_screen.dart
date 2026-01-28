import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _role = "Retailer";
  String _category = "Grocery";
  File? _logo;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logo = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Business Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                /// 🔹 LOGO UPLOAD
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF2563EB),
                    backgroundImage: _logo != null ? FileImage(_logo!) : null,
                    child: _logo == null
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Upload Shop Logo (Optional)",
                    style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: "Wholesaler", child: Text("Wholesaler")),
                    DropdownMenuItem(value: "Retailer", child: Text("Retailer")),
                    DropdownMenuItem(value: "Shopkeeper", child: Text("Shopkeeper")),
                  ],
                  onChanged: (value) => setState(() => _role = value!),
                  decoration: const InputDecoration(
                    labelText: 'Business Role',
                    prefixIcon: Icon(Icons.business_center),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField(
                  value: _category,
                  items: const [
                    DropdownMenuItem(value: "Grocery", child: Text("Grocery")),
                    DropdownMenuItem(value: "Vegetables", child: Text("Vegetables")),
                    DropdownMenuItem(value: "Stationery", child: Text("Stationery")),
                    DropdownMenuItem(value: "Medical", child: Text("Medical Store")),
                    DropdownMenuItem(value: "Electronics", child: Text("Electronics")),
                    DropdownMenuItem(value: "Clothing", child: Text("Clothing")),
                  ],
                  onChanged: (value) => setState(() => _category = value!),
                  decoration: const InputDecoration(
                    labelText: 'Shop Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Business Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('Register Business'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
