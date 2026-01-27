import 'package:flutter/material.dart';

class CreateBillScreen extends StatefulWidget {
  CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final List<Map<String, dynamic>> _items = [];

  final _itemNameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  String _paymentMethod = 'Cash';

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item['qty'] * item['price'];
    }
    return total;
  }

  void _addItem() {
    if (_itemNameController.text.isEmpty ||
        _qtyController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }

    setState(() {
      _items.add({
        'name': _itemNameController.text,
        'qty': int.parse(_qtyController.text),
        'price': double.parse(_priceController.text),
      });
    });

    _itemNameController.clear();
    _qtyController.clear();
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer: Rahul Patel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              'Add Item',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add Item'),
            ),

            const SizedBox(height: 20),

            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            _items.isEmpty
                ? const Text('No items added')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                    'Qty: ${item['qty']}  Price: ₹${item['price']}',
                  ),
                  trailing: Text(
                    '₹${item['qty'] * item['price']}',
                  ),
                );
              },
            ),

            const Divider(height: 30),

            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            RadioListTile(
              title: const Text('Cash'),
              value: 'Cash',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('UPI'),
              value: 'UPI',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Bank Transfer'),
              value: 'Bank',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bill Generated Successfully'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Generate Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
