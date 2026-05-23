import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'place_order_screen.dart';

class WholesalerProductScreen extends StatefulWidget {
  final String retailerId;

  const WholesalerProductScreen({super.key, required this.retailerId});

  @override
  State<WholesalerProductScreen> createState() =>
      _WholesalerProductScreenState();
}

class _WholesalerProductScreenState extends State<WholesalerProductScreen> {
  List products = [];

  bool isLoading = true;

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/list/${widget.retailerId}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          products = data["products"] ?? [];

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text("No Products Found"))
          : ListView.builder(
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
                      p["name"]?.toString() ?? "",

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      "Stock: ${p["stockQty"]}  •  ₹${p["selling"]}",
                    ),

                    trailing: ElevatedButton(
                      child: const Text("Order"),

                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => PlaceOrderScreen(
                              retailerId: widget.retailerId,

                              productName: p["name"].toString(),

                              price: (p["selling"] ?? 0),

                              availableStock: (p["stockQty"] ?? 0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
