import 'package:flutter/material.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final retailerCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  void _send() {
    Navigator.pop(context, {
      "retailer": retailerCtrl.text,
      "total": int.parse(priceCtrl.text),
      "status": "Pending",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Bill")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: retailerCtrl, decoration: const InputDecoration(labelText: "Retailer")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Amount")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _send, child: const Text("Send Bill")),
          ],
        ),
      ),
    );
  }
}
