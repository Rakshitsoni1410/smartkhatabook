import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;
  final String userRole;
  final String userId;
  final String userName;
  final String shopName;
  final String businessType;
  final VoidCallback onDelete;
  final Function(Map<String, dynamic>) onUpdate;

  const ProductDetails({
    super.key,
    required this.product,
    required this.userRole,
    required this.userId,
    required this.userName,
    required this.shopName,
    required this.businessType,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool _isSubmittingOrder = false;

  double getNumber(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int getInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String getText(dynamic value) {
    return value?.toString() ?? "";
  }

  String formatCurrency(dynamic amount) {
    return "₹${getNumber(amount).toStringAsFixed(2)}";
  }

  Color getStockColor(int stockQty, bool inStock) {
    if (!inStock || stockQty <= 0) return Colors.red;
    if (stockQty <= 5) return Colors.orange;
    return Colors.green;
  }

  String getStockLabel(int stockQty, bool inStock) {
    if (!inStock || stockQty <= 0) return "Out of Stock";
    if (stockQty <= 5) return "Low Stock";
    return "In Stock";
  }

  Future<void> placeAiOrder() async {
    try {
      setState(() {
        _isSubmittingOrder = true;
      });

      final base = dotenv.env['BASE_URL'] ?? '';

      final uri = Uri.parse('$base/orders/create');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "retailerId": widget.userId,
          "productName": getText(widget.product["name"]),
          "quantity": 1,
          "unit": "piece",
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        _isSubmittingOrder = false;
      });

      if (response.statusCode == 201 && data["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("✅ AI selected best wholesaler successfully"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(data["message"] ?? "Order failed"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmittingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
      );
    }
  }

  Widget infoCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final normalizedRole = widget.userRole.trim().toLowerCase();

    final canManageProduct =
        normalizedRole == 'wholesaler' || normalizedRole == 'retailer';

    final canPlaceOrder = normalizedRole == 'retailer';

    final String name = getText(product["name"]);

    final String category = getText(product["category"]);

    final String description = getText(product["description"]);

    final double purchase = getNumber(product["purchase"]);

    final double selling = getNumber(product["selling"]);

    final double profit = getNumber(product["profit"]);

    final int stockQty = getInt(product["stockQty"]);

    final bool inStock = product["inStock"] == true;

    final Color stockColor = getStockColor(stockQty, inStock);

    final String stockLabel = getStockLabel(stockQty, inStock);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: Text(name.isEmpty ? "Product Details" : name),

        backgroundColor: const Color(0xff6D5DF6),

        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6D5DF6), Color(0xff8E7CFF)],
                ),

                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(category, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: infoCard(
                    title: "Purchase",
                    value: formatCurrency(purchase),
                    color: Colors.orange,
                    icon: Icons.shopping_cart,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: infoCard(
                    title: "Selling",
                    value: formatCurrency(selling),
                    color: Colors.blue,
                    icon: Icons.sell,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: infoCard(
                    title: "Profit",
                    value: formatCurrency(profit),
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: infoCard(
                    title: "Stock",
                    value: stockQty.toString(),
                    color: stockColor,
                    icon: Icons.inventory,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Product Details",

                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  detailRow("Name", name),

                  detailRow("Category", category),

                  detailRow(
                    "Description",
                    description.isEmpty ? "No description" : description,
                  ),

                  detailRow("Stock Status", stockLabel, valueColor: stockColor),

                  detailRow("Stock Qty", stockQty.toString()),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (canPlaceOrder)
              SizedBox(
                width: double.infinity,

                height: 52,

                child: ElevatedButton.icon(
                  onPressed: _isSubmittingOrder ? null : placeAiOrder,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6D5DF6),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  icon: _isSubmittingOrder
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.local_shipping_outlined),

                  label: Text(
                    _isSubmittingOrder ? "Ordering..." : "AI Place Order",

                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
