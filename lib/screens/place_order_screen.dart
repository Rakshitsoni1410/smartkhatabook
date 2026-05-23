import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlaceOrderScreen extends StatefulWidget {
  final String retailerId;
  final String productName;
  final int price;
  final int availableStock;

  const PlaceOrderScreen({
    super.key,
    required this.retailerId,
    required this.productName,
    required this.price,
    required this.availableStock,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _quantity = 1;

  bool isLoading = false;

  Future<void> placeOrder() async {
    try {
      setState(() {
        isLoading = true;
      });

      final base = dotenv.env['BASE_URL'] ?? '';

      final uri = Uri.parse('$base/orders/create');

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "retailerId": widget.retailerId,
          "productName": widget.productName,
          "quantity": _quantity,
          "unit": "piece",
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201 &&
          data["success"] == true) {

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "✅ AI selected best wholesaler successfully",
              ),
            ),
          );

          Navigator.pop(context);
        }

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              data["message"] ?? "Order failed",
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final total = _quantity * widget.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Order"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // PRODUCT CARD
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),

                title: Text(
                  widget.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  "Price: ₹${widget.price}\nAvailable: ${widget.availableStock}",
                ),
              ),
            ),

            const SizedBox(height: 24),

            // QUANTITY
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

            // TOTAL
            Card(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(0.1),

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

            // BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_checkout),

                label: Text(
                  isLoading
                      ? "Placing Order..."
                      : "Place Order",
                ),

                onPressed: isLoading
                    ? null
                    : placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}