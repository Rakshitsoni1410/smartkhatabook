import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final List<Map<String, dynamic>> _products = [];

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  void _addProduct() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) return;

    setState(() {
      _products.add({
        'name': _nameController.text,
        'price': _priceController.text,
        'stock': _stockController.text,
      });
    });

    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    Navigator.pop(context);
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Product",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                prefixIcon: Icon(Icons.inventory),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Price",
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: "Stock Quantity",
                prefixIcon: Icon(Icons.storage),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.save),
                label: const Text("Save Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
      ),
      body: _products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              "No Products Added",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the button below to add stock",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.inventory, color: Colors.white),
              ),
              title: Text(product['name']),
              subtitle: Text("₹${product['price']} • Stock: ${product['stock']}"),
            ),
          );
        },
      ),
    );
  }
}
