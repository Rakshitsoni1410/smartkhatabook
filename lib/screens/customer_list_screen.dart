import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: ListView(
        children: [
          _customerTile(context, 'Rahul Patel'),
          _customerTile(context, 'Amit Shah'),
          _customerTile(context, 'Neha Mehta'),
        ],
      ),
    );
  }

  Widget _customerTile(BuildContext context, String name) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: const Text('Balance: ₹0'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(customerName: name),
          ),
        );
      },
    );
  }
}
