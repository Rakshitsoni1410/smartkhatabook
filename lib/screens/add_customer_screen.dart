import 'package:flutter/material.dart';

class AddCustomerScreen extends StatelessWidget {
  AddCustomerScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Customer Added')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
