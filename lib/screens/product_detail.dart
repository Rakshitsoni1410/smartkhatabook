import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {

  // ✅ SAFE NUMBER CONVERTER (Fix All Errors)
  double getNumber(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value.toDouble();
    if (value is double) return value;

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  // ✅ Currency Formatter
  String formatCurrency(dynamic amount) {
    return "₹${getNumber(amount).toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // ✅ Safe Values
    double purchase = getNumber(product["purchase"]);
    double selling = getNumber(product["selling"]);
    double profit = selling - purchase;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(product["name"] ?? "Product Details"),
        backgroundColor: Colors.green.shade700,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ✅ Product Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    product["name"] ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("Category: ${product["category"] ?? "-"}"),

                  const SizedBox(height: 15),

                  // ✅ Pricing Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Purchase Price:"),
                      Text(formatCurrency(purchase)),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Selling Price:"),
                      Text(formatCurrency(selling)),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profit:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatCurrency(profit),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ✅ Stock Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Stock Quantity:"),
                      Text("${product["stockQty"] ?? 0}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Notes
            if ((product["notes"] ?? "").toString().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "Notes: ${product["notes"]}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
