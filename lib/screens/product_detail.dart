import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;
  final String userRole;
  final VoidCallback onDelete;
  final Function(Map<String, dynamic>) onUpdate;

  const ProductDetails({
    super.key,
    required this.product,
    required this.userRole,
    required this.onDelete,
    required this.onUpdate,
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

  // ================= EDIT PRODUCT =================
  void editProduct() {
    TextEditingController nameCtrl =
    TextEditingController(text: widget.product["name"]);
    TextEditingController categoryCtrl =
    TextEditingController(text: widget.product["category"]);
    TextEditingController purchaseCtrl =
    TextEditingController(text: widget.product["purchase"].toString());
    TextEditingController sellingCtrl =
    TextEditingController(text: widget.product["selling"].toString());
    TextEditingController stockCtrl =
    TextEditingController(text: widget.product["stockQty"].toString());

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
          child: SingleChildScrollView(
            child: Column(
              children: [

                const Text(
                  "Edit Product",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: purchaseCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Purchase ₹",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: sellingCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Selling ₹",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Stock Quantity",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> updatedProduct = {
                      ...widget.product,
                      "name": nameCtrl.text,
                      "category": categoryCtrl.text,
                      "purchase": double.parse(purchaseCtrl.text),
                      "selling": double.parse(sellingCtrl.text),
                      "profit": double.parse(sellingCtrl.text) -
                          double.parse(purchaseCtrl.text),
                      "stockQty": int.parse(stockCtrl.text),
                      "inStock":
                      int.parse(stockCtrl.text) > 0,
                    };

                    widget.onUpdate(updatedProduct);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Update Product"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    double purchase = getNumber(product["purchase"]);
    double selling = getNumber(product["selling"]);
    double profit = selling - purchase;

    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"]),
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
                borderRadius:
                BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    product["name"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("Category: ${product["category"]}"),

                  const SizedBox(height: 15),

                  Text("Purchase: ${formatCurrency(purchase)}"),
                  Text("Selling: ${formatCurrency(selling)}"),
                  Text(
                    "Profit: ${formatCurrency(profit)}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight:
                        FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  Text("Stock: ${product["stockQty"]}"),

                ],
              ),
            ),

            const SizedBox(height: 20),

            if (widget.userRole == "Retailer")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Order sent to wholesaler")),
                    );
                  },
                  child:
                  const Text("Order from Wholesaler"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
