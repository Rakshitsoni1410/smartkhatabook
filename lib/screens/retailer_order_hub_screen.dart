import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../services/ledger_service.dart';

class RetailerOrderHubScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String shopName;
  final String businessType;

  const RetailerOrderHubScreen({
    super.key,
    required this.userId,
    this.userName = '',
    this.shopName = '',
    this.businessType = '',
  });

  @override
  State<RetailerOrderHubScreen> createState() => _RetailerOrderHubScreenState();
}

class _RetailerOrderHubScreenState extends State<RetailerOrderHubScreen> {
  bool isLoadingProducts = true;

  bool isLoadingOrders = true;

  List products = [];

  List orders = [];

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();

    fetchSuggestedProducts();

    fetchOrders();
  }

  // =========================
  // FETCH PRODUCTS
  // =========================

  Future<void> fetchSuggestedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/suggestions/${widget.userId}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          products = data["suggestions"] ?? [];

          isLoadingProducts = false;
        });
      } else {
        setState(() {
          isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingProducts = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Product Error: $e")));
    }
  }

  // =========================
  // FETCH ORDERS
  // =========================

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/retailer/${widget.userId}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          orders = data;

          isLoadingOrders = false;
        });
      } else {
        setState(() {
          isLoadingOrders = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingOrders = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order Error: $e")));
    }
  }

  // =========================
  // AI ORDER
  // =========================

  Future<void> placeAiOrder({
    required String productName,

    required double sellingPrice,
  }) async {
    final quantityController = TextEditingController(text: "1");

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,

            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: StatefulBuilder(
            builder: (context, setModalState) {
              double quantity = double.tryParse(quantityController.text) ?? 1;

              double total = quantity * sellingPrice;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "AI Smart Order",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(productName),

                    const SizedBox(height: 20),

                    TextField(
                      controller: quantityController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(labelText: "Quantity"),

                      onChanged: (_) {
                        setModalState(() {
                          quantity =
                              double.tryParse(quantityController.text) ?? 1;

                          total = quantity * sellingPrice;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Text(
                        "Total Amount: ₹${total.toStringAsFixed(0)}",

                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),

                        label: const Text("Place AI Order"),

                        onPressed: () async {
                          try {
                            final response = await http.post(
                              Uri.parse('$baseUrl/orders/create'),

                              headers: {"Content-Type": "application/json"},

                              body: jsonEncode({
                                "retailerId": widget.userId,

                                "productName": productName,

                                "quantity": quantity,

                                "unit": "piece",
                              }),
                            );

                            final data = jsonDecode(response.body);

                            if (response.statusCode == 201 &&
                                data["success"] == true) {
                              final totalAmount = (quantity * sellingPrice)
                                  .round();

                              LedgerService.addEntry(
                                party: "AI Selected Wholesaler",

                                type: "Debit",

                                amount: totalAmount,

                                source: "AI Order",
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,

                                  content: Text(
                                    "✅ AI selected best wholesaler successfully",
                                  ),
                                ),
                              );

                              fetchOrders();
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,

                                content: Text("Error: $e"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;

      case "ontheway":
        return Colors.orange;

      case "rejected":
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Retailer Dashboard")),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // =====================
          // HEADER
          // =====================
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),

              borderRadius: BorderRadius.circular(24),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.shopName.isEmpty ? "Retailer" : widget.shopName,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.businessType,

                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================
          // PRODUCTS
          // =====================
          const Text(
            "Suggested Products",

            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          if (isLoadingProducts)
            const Center(child: CircularProgressIndicator())
          else if (products.isEmpty)
            const Center(child: Text("No Products Found"))
          else
            ...products.map((product) {
              final name = product["name"]?.toString() ?? "";

              final category = product["category"]?.toString() ?? "";

              final selling =
                  double.tryParse(product["selling"]?.toString() ?? "0") ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,

                      backgroundColor: Colors.blue.withOpacity(0.1),

                      child: const Icon(Icons.inventory_2, color: Colors.blue),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            name,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(category),

                          const SizedBox(height: 6),

                          Text(
                            "₹${selling.toStringAsFixed(0)}",

                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        placeAiOrder(productName: name, sellingPrice: selling);
                      },

                      child: const Text("Order"),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 28),

          // =====================
          // ORDERS
          // =====================
          const Text(
            "My Orders",

            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          if (isLoadingOrders)
            const Center(child: CircularProgressIndicator())
          else if (orders.isEmpty)
            const Center(child: Text("No Orders Yet"))
          else
            ...orders.map((order) {
              final status = order["orderStatus"]?.toString() ?? "pending";

              return Container(
                margin: const EdgeInsets.only(bottom: 14),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order["productName"]?.toString() ?? "",

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Chip(
                          label: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),

                          backgroundColor: getStatusColor(status),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text("Quantity: ${order["quantity"]}"),

                    const SizedBox(height: 6),

                    Text("Total: ₹${order["totalAmount"]}"),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
