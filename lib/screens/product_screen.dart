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

  // =========================
  // FILTER PRODUCTS
  // =========================
  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final name = (product["name"] ?? "").toLowerCase();
      final category = (product["category"] ?? "").toLowerCase();

      return name.contains(searchText.toLowerCase()) ||
          category.contains(searchText.toLowerCase());
    }).toList();
  }

  // =========================
  // ADD PRODUCT FORM
  // =========================
  void openAddProductForm() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController categoryCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();
    TextEditingController purchaseCtrl = TextEditingController();
    TextEditingController sellingCtrl = TextEditingController();
    TextEditingController stockCtrl = TextEditingController();
    TextEditingController weightCtrl = TextEditingController();

    bool inStock = true;
    bool inWeight = false;
    String weightUnit = "kg";
    double profit = 0;

    List<String> weightUnits = [
      "kg",
      "gram",
      "liter",
      "ml",
      "piece",
      "pack",
      "dozen"
    ];

    String? nameError;
    String? categoryError;
    String? purchaseError;
    String? sellingError;
    String? stockError;

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
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
                        errorText: nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CATEGORY
                    const Text("Category *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                        errorText: categoryError,
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
                              labelText: "Purchase ₹",
                              errorText: purchaseError,
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
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
                              labelText: "Selling ₹",
                              errorText: sellingError,
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
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
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.shade200),
                      ),
                      child: Text(
                        "Profit: ₹${profit.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // STOCK
                    const Text("Stock Quantity *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        errorText: stockError,
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // IN STOCK TOGGLE
                    SwitchListTile(
                      value: inStock,
                      title: const Text("In Stock"),
                      activeThumbColor: Colors.green,
                      onChanged: (val) {
                        setModalState(() => inStock = val);
                      },
                    ),

                    // SELL IN WEIGHT TOGGLE
                    SwitchListTile(
                      value: inWeight,
                      title:
                      const Text("Sell in Weight"),
                      activeThumbColor: Colors.green,
                      onChanged: (val) {
                        setModalState(() => inWeight = val);
                      },
                    ),

                    if (inWeight) ...[
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        initialValue: weightUnit,
                        items: weightUnits
                            .map((u) =>
                            DropdownMenuItem(
                              value: u,
                              child: Text(
                                  u.toUpperCase()),
                            ))
                            .toList(),
                        onChanged: (val) {
                          setModalState(
                                  () => weightUnit = val!);
                        },
                        decoration: InputDecoration(
                          labelText: "Weight Unit",
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: weightCtrl,
                        keyboardType:
                        TextInputType.number,
                        decoration:
                        InputDecoration(
                          labelText:
                          "Weight per item",
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ADD BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        child:
                        const Text("Add Product"),
                        onPressed: () {
                          setModalState(() {
                            nameError =
                            nameCtrl.text.isEmpty
                                ? "Required"
                                : null;
                            categoryError =
                            categoryCtrl.text
                                .isEmpty
                                ? "Required"
                                : null;
                            purchaseError =
                            purchaseCtrl.text
                                .isEmpty
                                ? "Required"
                                : null;
                            sellingError =
                            sellingCtrl.text
                                .isEmpty
                                ? "Required"
                                : null;
                            stockError =
                            stockCtrl.text
                                .isEmpty
                                ? "Required"
                                : null;
                          });

                          if (nameError != null ||
                              categoryError != null ||
                              purchaseError != null ||
                              sellingError != null ||
                              stockError != null) {
                            return;
                          }

                          setState(() {
                            products.add({
                              "name":
                              nameCtrl.text,
                              "category":
                              categoryCtrl.text,
                              "description":
                              descCtrl.text,
                              "purchase": double.parse(
                                  purchaseCtrl.text),
                              "selling": double.parse(
                                  sellingCtrl.text),
                              "profit": profit,
                              "stockQty": int.parse(
                                  stockCtrl.text),
                              "inStock":
                              inStock,
                              "inWeight":
                              inWeight,
                              "weightUnit":
                              weightUnit,
                              "weight":
                              double.tryParse(
                                  weightCtrl
                                      .text) ??
                                  0,
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

  // =========================
  // MAIN UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: Colors.green.shade700,
      ),
      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        Colors.green.shade700,
        onPressed: openAddProductForm,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText:
                "Search product...",
                prefixIcon:
                const Icon(Icons.search),
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                      12),
                ),
              ),
              onChanged: (val) {
                setState(() =>
                searchText = val);
              },
            ),
            const SizedBox(
                height: 15),
            Expanded(
              child:
              filteredProducts.isEmpty
                  ? const Center(
                  child: Text(
                      "No Products Found"))
                  : ListView
                  .builder(
                itemCount:
                filteredProducts
                    .length,
                itemBuilder:
                    (_, index) {
                  final product =
                  filteredProducts[
                  index];

                  return ListTile(
                    title: Text(
                        product[
                        "name"]),
                    subtitle: Text(
                        "Profit ₹${product["profit"]}"),
                    trailing: Text(
                        "₹${product["selling"]}"),
                    onTap: () {
                      Navigator
                          .push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                              ProductDetails(
                                product:
                                product,
                                userRole:
                                "Retailer",
                                onDelete:
                                    () {
                                  setState(
                                          () {
                                        products
                                            .remove(
                                            product);
                                      });
                                  Navigator.pop(
                                      context);
                                },
                                onUpdate:
                                    (updatedProduct) {
                                  setState(
                                          () {
                                        int index =
                                        products.indexOf(
                                            product);
                                        products[index] =
                                            updatedProduct;
                                      });
                                },
                              ),
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
