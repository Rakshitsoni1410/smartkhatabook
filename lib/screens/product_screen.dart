import 'package:flutter/material.dart';
import 'product_detail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String searchText = "";

  // ✅ Dummy Products
  List<Map<String, dynamic>> products = [
    {
      "name": "Rice Bag",
      "category": "Grocery",
      "description": "Premium basmati rice",
      "purchase": 800.0,
      "selling": 950.0,
      "profit": 150.0,
      "stockQty": 20,
      "inStock": true,
      "inWeight": false,
      "weightUnit": "kg",
      "weight": 0.0,
    },
    {
      "name": "Sugar 1kg",
      "category": "Grocery",
      "description": "White sugar",
      "purchase": 40.0,
      "selling": 45.0,
      "profit": 5.0,
      "stockQty": 0,
      "inStock": false,
      "inWeight": false,
      "weightUnit": "kg",
      "weight": 0.0,
    }
  ];

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

    String? nameError;
    String? categoryError;
    String? purchaseError;
    String? sellingError;
    String? stockError;

    List<String> weightUnits = [
      "kg",
      "gram",
      "liter",
      "ml",
      "piece",
      "pack",
      "dozen"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void calcProfit() {
              double purchase =
                  double.tryParse(purchaseCtrl.text) ?? 0;
              double selling =
                  double.tryParse(sellingCtrl.text) ?? 0;

              setModalState(() {
                profit = selling - purchase;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // HEADER
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Product",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold),
                        ),
                        IconButton(
                          icon:
                          const Icon(Icons.close),
                          onPressed: () =>
                              Navigator.pop(context),
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    // NAME
                    const Text("Product Name *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        errorText: nameError,
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
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
                        errorText:
                        categoryError,
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
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
                      decoration:
                      InputDecoration(
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // PURCHASE + SELLING
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                            purchaseCtrl,
                            keyboardType:
                            TextInputType
                                .number,
                            onChanged: (_) =>
                                calcProfit(),
                            decoration:
                            InputDecoration(
                              labelText:
                              "Purchase ₹",
                              errorText:
                              purchaseError,
                              border:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller:
                            sellingCtrl,
                            keyboardType:
                            TextInputType
                                .number,
                            onChanged: (_) =>
                                calcProfit(),
                            decoration:
                            InputDecoration(
                              labelText:
                              "Selling ₹",
                              errorText:
                              sellingError,
                              border:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // PROFIT
                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(
                          14),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(
                            12),
                      ),
                      child: Text(
                        "Profit: ₹${profit.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight:
                            FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // STOCK
                    const Text(
                        "Stock Quantity *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: stockCtrl,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      InputDecoration(
                        errorText: stockError,
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // IN STOCK
                    SwitchListTile(
                      value: inStock,
                      title:
                      const Text("In Stock"),
                      onChanged: (val) {
                        setModalState(
                                () => inStock = val);
                      },
                    ),

                    // SELL IN WEIGHT
                    SwitchListTile(
                      value: inWeight,
                      title: const Text(
                          "Sell in Weight"),
                      onChanged: (val) {
                        setModalState(
                                () => inWeight = val);
                      },
                    ),

                    if (inWeight) ...[
                      const SizedBox(height: 10),

                      DropdownButtonFormField(
                        initialValue:
                        weightUnit,
                        items: weightUnits
                            .map((u) =>
                            DropdownMenuItem(
                              value: u,
                              child: Text(
                                  u),
                            ))
                            .toList(),
                        onChanged: (val) {
                          setModalState(() =>
                          weightUnit =
                          val!);
                        },
                        decoration:
                        const InputDecoration(
                          labelText:
                          "Weight Unit",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                        weightCtrl,
                        keyboardType:
                        TextInputType
                            .number,
                        decoration:
                        const InputDecoration(
                          labelText:
                          "Weight per item",
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ADD BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        child: const Text(
                            "Add Product"),
                        onPressed: () {

                          setModalState(() {
                            nameError =
                            nameCtrl
                                .text
                                .isEmpty
                                ? "Required"
                                : null;
                            categoryError =
                            categoryCtrl
                                .text
                                .isEmpty
                                ? "Required"
                                : null;
                            purchaseError =
                            purchaseCtrl
                                .text
                                .isEmpty
                                ? "Required"
                                : null;
                            sellingError =
                            sellingCtrl
                                .text
                                .isEmpty
                                ? "Required"
                                : null;
                            stockError =
                            stockCtrl
                                .text
                                .isEmpty
                                ? "Required"
                                : null;
                          });

                          if (nameError !=
                              null ||
                              categoryError !=
                                  null ||
                              purchaseError !=
                                  null ||
                              sellingError !=
                                  null ||
                              stockError !=
                                  null) return;

                          setState(() {
                            products.add({
                              "name":
                              nameCtrl.text,
                              "category":
                              categoryCtrl
                                  .text,
                              "description":
                              descCtrl.text,
                              "purchase":
                              double.parse(
                                  purchaseCtrl
                                      .text),
                              "selling":
                              double.parse(
                                  sellingCtrl
                                      .text),
                              "profit":
                              profit,
                              "stockQty":
                              int.parse(
                                  stockCtrl
                                      .text),
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

                          Navigator.pop(
                              context);
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
  // MAIN SCREEN UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("All Products"),
        backgroundColor:
        Colors.green.shade700,
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed:
        openAddProductForm,
        backgroundColor:
        Colors.green.shade700,
        child:
        const Icon(Icons.add),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              decoration:
              const InputDecoration(
                hintText:
                "Search product...",
                prefixIcon:
                Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() =>
                searchText = val);
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child:
              filteredProducts.isEmpty
                  ? const Center(
                  child: Text(
                      "No Products Found"))
                  : ListView.builder(
                itemCount:
                filteredProducts
                    .length,
                itemBuilder:
                    (_, index) {
                  final product =
                  filteredProducts[
                  index];

                  bool outOfStock =
                      product[
                      "stockQty"] ==
                          0 ||
                          product[
                          "inStock"] ==
                              false;

                  return Card(
                    color: outOfStock
                        ? Colors
                        .red.shade50
                        : Colors
                        .white,
                    child: ListTile(
                      title: Text(
                        product[
                        "name"],
                        style:
                        TextStyle(
                          color: outOfStock
                              ? Colors
                              .red
                              : Colors
                              .black,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                      subtitle:
                      Text(outOfStock
                          ? "Out of Stock"
                          : "Profit ₹${product["profit"]}"),
                      trailing: Text(
                          "₹${product["selling"]}"),
                      onTap: () {
                        Navigator.push(
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
                                          products.remove(
                                              product);
                                        });
                                    Navigator.pop(
                                        context);
                                  },
                                  onUpdate:
                                      (updatedProduct) {
                                    setState(
                                            () {
                                          int i = products.indexOf(
                                              product);
                                          products[i] =
                                              updatedProduct;
                                        });
                                  },
                                ),
                          ),
                        );
                      },
                    ),
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
