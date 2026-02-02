import 'package:flutter/material.dart';

class PlaceOrderScreen extends StatefulWidget {
  final String productName;
  final int price;
  final int availableStock;

  const PlaceOrderScreen({
    super.key,
    required this.productName,
    required this.price,
    required this.availableStock,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final total = _quantity * widget.price;

    return Scaffold(
      appBar: AppBar(title: const Text("Place Order")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 PRODUCT CARD
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(
                  widget.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Price: ₹${widget.price}\nAvailable: ${widget.availableStock}",
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 QUANTITY SELECTOR
            Text(
              "Quantity",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _quantity > 1
                      ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                      : null,
                ),
                Text(
                  _quantity.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _quantity < widget.availableStock
                      ? () {
                    setState(() {
                      _quantity++;
                    });
                  }
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 TOTAL
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: ListTile(
                title: const Text("Total Amount"),
                trailing: Text(
                  "₹$total",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // 🔹 PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text("Place Order"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order placed successfully (demo)"),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
