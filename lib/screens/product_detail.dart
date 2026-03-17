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

  String formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  IconData getCategoryIcon(String category) {
    final c = category.toLowerCase();

    if (c.contains("grocery")) return Icons.shopping_basket_outlined;
    if (c.contains("stationery")) return Icons.edit_note_outlined;
    if (c.contains("medical")) return Icons.local_hospital_outlined;
    if (c.contains("electronics")) return Icons.devices_other_outlined;
    if (c.contains("clothing")) return Icons.checkroom_outlined;
    if (c.contains("footwear")) return Icons.hiking_outlined;
    if (c.contains("jewelry")) return Icons.diamond_outlined;
    if (c.contains("furniture")) return Icons.chair_outlined;
    if (c.contains("book")) return Icons.menu_book_outlined;
    if (c.contains("mobile")) return Icons.smartphone_outlined;
    if (c.contains("bakery")) return Icons.bakery_dining_outlined;
    if (c.contains("restaurant")) return Icons.restaurant_outlined;

    return Icons.inventory_2_outlined;
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

  void editProduct() {
    final product = widget.product;

    final TextEditingController nameCtrl =
        TextEditingController(text: getText(product["name"]));
    final TextEditingController categoryCtrl =
        TextEditingController(text: getText(product["category"]));
    final TextEditingController descCtrl =
        TextEditingController(text: getText(product["description"]));
    final TextEditingController purchaseCtrl =
        TextEditingController(text: getNumber(product["purchase"]).toString());
    final TextEditingController sellingCtrl =
        TextEditingController(text: getNumber(product["selling"]).toString());
    final TextEditingController stockCtrl =
        TextEditingController(text: getInt(product["stockQty"]).toString());
    final TextEditingController weightCtrl =
        TextEditingController(text: getNumber(product["weight"]).toString());

    bool inWeight = product["inWeight"] == true;
    String weightUnit = getText(product["weightUnit"]).isEmpty
        ? "piece"
        : getText(product["weightUnit"]);
    double profit =
        getNumber(product["selling"]) - getNumber(product["purchase"]);

    final List<String> weightUnits = [
      "kg",
      "gram",
      "liter",
      "ml",
      "piece",
      "pack",
      "dozen",
      "strip",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            void calcProfit() {
              final purchase = double.tryParse(purchaseCtrl.text) ?? 0;
              final selling = double.tryParse(sellingCtrl.text) ?? 0;

              setModalState(() {
                profit = selling - purchase;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Product",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: "Product Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: purchaseCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => calcProfit(),
                            decoration: InputDecoration(
                              labelText: "Purchase ₹",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: sellingCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => calcProfit(),
                            decoration: InputDecoration(
                              labelText: "Selling ₹",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Profit: ₹${profit.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Stock Quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: inWeight,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Sell in Weight"),
                      onChanged: (val) {
                        setModalState(() {
                          inWeight = val;
                        });
                      },
                    ),
                    if (inWeight) ...[
                      DropdownButtonFormField<String>(
                        value: weightUnit,
                        items: weightUnits
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() {
                            weightUnit = val!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Weight Unit",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: "Weight per item",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final purchase =
                              double.tryParse(purchaseCtrl.text) ?? 0;
                          final selling =
                              double.tryParse(sellingCtrl.text) ?? 0;
                          final stock = int.tryParse(stockCtrl.text) ?? 0;

                          final updatedProduct = {
                            ...widget.product,
                            "name": nameCtrl.text.trim(),
                            "category": categoryCtrl.text.trim(),
                            "description": descCtrl.text.trim(),
                            "purchase": purchase,
                            "selling": selling,
                            "profit": selling - purchase,
                            "stockQty": stock,
                            "inStock": stock > 0,
                            "inWeight": inWeight,
                            "weightUnit": weightUnit,
                            "weight": double.tryParse(weightCtrl.text) ?? 0,
                          };

                          widget.onUpdate(updatedProduct);
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6D5DF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Update Product"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      categoryCtrl.dispose();
      descCtrl.dispose();
      purchaseCtrl.dispose();
      sellingCtrl.dispose();
      stockCtrl.dispose();
      weightCtrl.dispose();
    });
  }

  void openWholesalerOrderForm() {
    final product = widget.product;
    final bool inWeight = product["inWeight"] == true;
    final String unitLabel = getText(product["weightUnit"]).isEmpty
        ? "piece"
        : getText(product["weightUnit"]);
    final double purchasePrice = getNumber(product["purchase"]);
    final double sellingPrice = getNumber(product["selling"]);
    final double defaultPrice = purchasePrice > 0 ? purchasePrice : sellingPrice;

    final quantityCtrl = TextEditingController(text: "1");
    final priceCtrl = TextEditingController(
      text: defaultPrice > 0 ? formatQuantity(defaultPrice) : "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        double quantity = double.tryParse(quantityCtrl.text) ?? 0;
        double price = double.tryParse(priceCtrl.text) ?? 0;
        double total = quantity * price;

        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            void updateTotal() {
              final parsedQuantity = double.tryParse(quantityCtrl.text) ?? 0;
              final parsedPrice = double.tryParse(priceCtrl.text) ?? 0;

              setModalState(() {
                quantity = parsedQuantity;
                price = parsedPrice;
                total = parsedQuantity * parsedPrice;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Wholesaler Order",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getText(product["name"]).isEmpty
                          ? "Create a new order"
                          : getText(product["name"]),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: inWeight,
                      ),
                      onChanged: (_) => updateTotal(),
                      decoration: InputDecoration(
                        labelText:
                            inWeight ? "Quantity ($unitLabel)" : "Quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => updateTotal(),
                      decoration: InputDecoration(
                        labelText: inWeight
                            ? "Price per $unitLabel"
                            : "Price per item",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xff6D5DF6).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Order Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff6D5DF6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Total Amount: ${formatCurrency(total)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final orderQuantity =
                              double.tryParse(quantityCtrl.text.trim()) ?? 0;
                          final orderPrice =
                              double.tryParse(priceCtrl.text.trim()) ?? 0;

                          if (orderQuantity <= 0 || orderPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Enter a valid quantity and price",
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Order sent for ${formatQuantity(orderQuantity)} "
                                "${inWeight ? unitLabel : "items"} at "
                                "${formatCurrency(orderPrice)} each",
                              ),
                            ),
                          );

                          debugPrint({
                            "productId": product["id"],
                            "productName": getText(product["name"]),
                            "quantity": orderQuantity,
                            "pricePerUnit": orderPrice,
                            "unit": inWeight ? unitLabel : "item",
                            "total": orderQuantity * orderPrice,
                            "status": "pending",
                          }.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6D5DF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: const Text("Send Order"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      quantityCtrl.dispose();
      priceCtrl.dispose();
    });
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
          )
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
    final bool inWeight = product["inWeight"] == true;
    final String weightUnit = getText(product["weightUnit"]);
    final double weight = getNumber(product["weight"]);

    final Color stockColor = getStockColor(stockQty, inStock);
    final String stockLabel = getStockLabel(stockQty, inStock);
    final bool lowStock = stockQty > 0 && stockQty <= 5 && inStock;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text(name.isEmpty ? "Product Details" : name),
        backgroundColor: const Color(0xff6D5DF6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: canManageProduct
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: editProduct,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
              ]
            : null,
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
                  colors: [
                    Color(0xff6D5DF6),
                    Color(0xff8E7CFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      getCategoryIcon(category),
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                category.isEmpty ? "General" : category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: stockColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                stockLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: stockColor == Colors.green
                                      ? Colors.white
                                      : stockColor,
                                ),
                              ),
                            ),
                            if (inWeight)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "${formatQuantity(weight)} $weightUnit",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            if (lowStock) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.20),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Low stock alert: this product has 5 or fewer items left.",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: infoCard(
                    title: "Purchase",
                    value: formatCurrency(purchase),
                    color: const Color(0xffFB8C00),
                    icon: Icons.shopping_cart_checkout_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: infoCard(
                    title: "Selling",
                    value: formatCurrency(selling),
                    color: const Color(0xff1E88E5),
                    icon: Icons.sell_outlined,
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
                    color: const Color(0xff2E7D32),
                    icon: Icons.trending_up_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: infoCard(
                    title: "Stock",
                    value: "$stockQty",
                    color: stockColor,
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Details",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  detailRow("Name", name),
                  detailRow("Category", category.isEmpty ? "General" : category),
                  detailRow(
                    "Description",
                    description.isEmpty ? "No description added" : description,
                  ),
                  detailRow(
                    "Stock Status",
                    stockLabel,
                    valueColor: stockColor,
                  ),
                  detailRow("Stock Qty", "$stockQty"),
                  detailRow("Sell in Weight", inWeight ? "Yes" : "No"),
                  if (inWeight) ...[
                    detailRow("Weight Unit", weightUnit),
                    detailRow("Weight", formatQuantity(weight)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (canPlaceOrder)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: openWholesalerOrderForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6D5DF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text(
                    "Order from Wholesaler",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}