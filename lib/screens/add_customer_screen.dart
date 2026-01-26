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
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Enter mobile number' : null,
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
