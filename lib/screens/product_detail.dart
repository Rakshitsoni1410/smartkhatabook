import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final Function(Map<String, dynamic>) onUpdate;
  final String userRole;

  const ProductDetails({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onUpdate,
    required this.userRole,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {

  double getNumber(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String formatCurrency(dynamic amount) {
    return "₹${getNumber(amount).toStringAsFixed(2)}";
  }

  void editProduct() {
    TextEditingController nameCtrl =
    TextEditingController(text: widget.product["name"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Product Name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.product["name"] = nameCtrl.text;
              });
              widget.onUpdate(widget.product);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void orderToWholesaler() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order placed to wholesaler successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    double purchase = getNumber(product["purchase"]);
    double selling = getNumber(product["selling"]);
    double profit = selling - purchase;

    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"] ?? "Product Details"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: editProduct,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

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

            if (widget.userRole == "Retailer")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: orderToWholesaler,
                  icon: const Icon(Icons.local_shipping),
                  label: const Text("Order to Wholesaler"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
