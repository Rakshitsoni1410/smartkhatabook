import 'package:flutter/material.dart';
import 'place_order_screen.dart';

class WholesalerProductScreen extends StatelessWidget {
  final String wholesalerName;

  const WholesalerProductScreen({super.key, required this.wholesalerName});

  @override
  Widget build(BuildContext context) {
    final products = [
      {"name": "Rice Bag", "price": 48, "stock": 200},
      {"name": "Sugar Pack", "price": 38, "stock": 150},
      {"name": "Oil Tin", "price": 120, "stock": 90},
      {"name": "Wheat Flour", "price": 42, "stock": 300},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("$wholesalerName Products")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.inventory_2, color: Colors.white),
              ),
              title: Text(
                p["name"].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Stock: ${p["stock"]}  •  ₹${p["price"]}",
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceOrderScreen(
                        productName: p["name"].toString(),
                        price: p["price"] as int,
                        availableStock: p["stock"] as int,
                      ),
                    ),
                  );
                },
                child: const Text("Order"),
              ),
            ),
          );
        },
      ),
    );
  }
}
