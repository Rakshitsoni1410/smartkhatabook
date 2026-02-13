import 'package:flutter/material.dart';
import 'product_detail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> products = [];
  String searchText = "";

  // ✅ Filtered Products
  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final name = (product["name"] ?? "").toLowerCase();
      final category = (product["category"] ?? "").toLowerCase();

      return name.contains(searchText.toLowerCase()) ||
          category.contains(searchText.toLowerCase());
    }).toList();
  }

  // ✅ Stock Counts
  int get inStockCount =>
      products.where((p) => p["inStock"] == true).length;

  int get outStockCount =>
      products.where((p) => p["inStock"] == false).length;

  // ==============================
  // OPEN ADD PRODUCT FORM
  // ==============================
  void openAddProductForm() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController categoryCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();
    TextEditingController purchaseCtrl = TextEditingController();
    TextEditingController sellingCtrl = TextEditingController();
    TextEditingController stockCtrl = TextEditingController();
    TextEditingController weightCtrl = TextEditingController();
    TextEditingController notesCtrl = TextEditingController();

    bool inStock = true;
    bool inWeight = false;

    String weightUnit = "kg";
    double profit = 0;

    List<String> weightUnits = ["kg", "gram", "liter", "ml", "piece", "pack", "dozen"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            // ✅ Profit Calculation
            void calcProfit() {
              double purchase = double.tryParse(purchaseCtrl.text) ?? 0;
              double selling = double.tryParse(sellingCtrl.text) ?? 0;

              setModalState(() {
                profit = selling - purchase;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Product",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    // PRODUCT NAME
                    const Text("Product Name *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter product name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CATEGORY
                    const Text("Category"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                        hintText: "e.g., Grocery, Electronics",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DESCRIPTION
                    const Text("Description"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Product description...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // PURCHASE + SELLING
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: purchaseCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => calcProfit(),
                            decoration: InputDecoration(
                              labelText: "Purchase Price ₹",
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
                            keyboardType: TextInputType.number,
                            onChanged: (_) => calcProfit(),
                            decoration: InputDecoration(
                              labelText: "Selling Price ₹",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // PROFIT BOX
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        "Profit: ₹${profit.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // STOCK QUANTITY
                    const Text("Stock Quantity"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "0",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // TOGGLES
                    SwitchListTile(
                      value: inStock,
                      title: const Text("In Stock"),
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setModalState(() => inStock = val);
                      },
                    ),

                    SwitchListTile(
                      value: inWeight,
                      title: const Text("Sell in Weight"),
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setModalState(() => inWeight = val);
                      },
                    ),

                    // WEIGHT SECTION
                    if (inWeight) ...[
                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        value: weightUnit,
                        items: weightUnits
                            .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.toUpperCase()),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setModalState(() => weightUnit = val!);
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
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Weight per item",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // NOTES
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Notes (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ADD BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Add Product"),
                        onPressed: () {
                          if (nameCtrl.text.isEmpty) return;

                          double purchase =
                              double.tryParse(purchaseCtrl.text) ?? 0;

                          double selling =
                              double.tryParse(sellingCtrl.text) ?? 0;

                          int stockQty =
                              int.tryParse(stockCtrl.text) ?? 0;

                          double weight =
                              double.tryParse(weightCtrl.text) ?? 0;

                          setState(() {
                            products.add({
                              "name": nameCtrl.text,
                              "category": categoryCtrl.text,
                              "description": descCtrl.text,

                              // ✅ Store as Numbers
                              "purchase": purchase,
                              "selling": selling,
                              "profit": selling - purchase,
                              "stockQty": stockQty,

                              "inStock": inStock,
                              "inWeight": inWeight,
                              "weightUnit": weightUnit,
                              "weight": weight,

                              "notes": notesCtrl.text,
                              "createdAt": DateTime.now().toString(),
                            });
                          });

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===============================
  // MAIN UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: Colors.green.shade700,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
        onPressed: openAddProductForm,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search product...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() => searchText = val);
              },
            ),

            const SizedBox(height: 15),

            // PRODUCT LIST
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text("No Products Found"))
                  : ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (_, index) {
                  final product = filteredProducts[index];

                  return ListTile(
                    title: Text(product["name"]),
                    subtitle: Text("Profit ₹${product["profit"]}"),
                    trailing: Text("₹${product["selling"]}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetails(product: product),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
