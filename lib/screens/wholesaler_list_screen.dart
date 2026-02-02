import 'package:flutter/material.dart';
import 'wholesaler_product_screen.dart';

class WholesalerListScreen extends StatelessWidget {
  const WholesalerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wholesalers = [
      {
        "name": "Shree Traders",
        "category": "Grocery Wholesaler",
        "location": "Ahmedabad",
      },
      {
        "name": "Patel Foods",
        "category": "Grains & Pulses",
        "location": "Surat",
      },
      {
        "name": "FreshVeg Supply",
        "category": "Vegetables",
        "location": "Vadodara",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Select Wholesaler")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wholesalers.length,
        itemBuilder: (context, index) {
          final w = wholesalers[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.store, color: Colors.white),
              ),
              title: Text(
                w["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${w["category"]} • ${w["location"]}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WholesalerProductScreen(
                      wholesalerName: w["name"]!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
