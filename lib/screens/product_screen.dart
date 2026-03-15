import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'product_detail.dart';

class ProductScreen extends StatefulWidget {
  final String userId;

  const ProductScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String searchText = "";
  String businessType = "General";
  bool isLoading = true;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> suggestions = [];

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => isLoading = true);
    await Future.wait([
      loadSuggestions(),
      loadProducts(),
    ]);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadSuggestions() async {
    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final uri = Uri.parse('$base/product/suggestions/${widget.userId}');

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data["success"] == true) {
        setState(() {
          businessType = data["businessType"] ?? "General";
          suggestions = List<Map<String, dynamic>>.from(data["suggestions"] ?? []);
        });
      }
    } catch (_) {}
  }

  Future<void> loadProducts() async {
    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final uri = Uri.parse('$base/product/list/${widget.userId}');

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data["success"] == true) {
        setState(() {
          products = List<Map<String, dynamic>>.from(data["products"] ?? []);
        });
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final name = (product["name"] ?? "").toString().toLowerCase();
      final category = (product["category"] ?? "").toString().toLowerCase();

      return name.contains(searchText.toLowerCase()) ||
          category.contains(searchText.toLowerCase());
    }).toList();
  }

  Future<void> deleteProductApi(String productId) async {
    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final uri = Uri.parse('$base/product/delete/$productId');

      final resp = await http.delete(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data["success"] == true) {
        await loadProducts();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Delete failed")),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delete failed")),
        );
      }
    }
  }

  Future<void> updateProductApi(Map<String, dynamic> updatedProduct) async {
    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final productId = updatedProduct["_id"];
      final uri = Uri.parse('$base/product/update/$productId');

      final resp = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedProduct),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data["success"] == true) {
        await loadProducts();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Update failed")),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update failed")),
        );
      }
    }
  }

  Future<void> addProductApi(Map<String, dynamic> body) async {
    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final uri = Uri.parse('$base/product/add');

      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(resp.body);

      if (resp.statusCode == 201 && data["success"] == true) {
        await loadProducts();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product added successfully")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Add product failed")),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add product failed")),
        );
      }
    }
  }

  void openAddProductForm() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController categoryCtrl = TextEditingController(text: businessType);
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
              double purchase = double.tryParse(purchaseCtrl.text) ?? 0;
              double selling = double.tryParse(sellingCtrl.text) ?? 0;

              setModalState(() {
                profit = selling - purchase;
              });
            }

            void applySuggestion(Map<String, dynamic> item) {
              nameCtrl.text = item["name"]?.toString() ?? "";
              categoryCtrl.text = item["category"]?.toString() ?? businessType;
              descCtrl.text = item["description"]?.toString() ?? "";
              purchaseCtrl.text = (item["purchase"] ?? 0).toString();
              sellingCtrl.text = (item["selling"] ?? 0).toString();
              stockCtrl.text = (item["stockQty"] ?? 0).toString();
              inWeight = item["inWeight"] ?? false;
              weightUnit = item["weightUnit"]?.toString() ?? "kg";
              weightCtrl.text = (item["weight"] ?? 0).toString();
              inStock = (item["stockQty"] ?? 0) > 0;

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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (suggestions.isNotEmpty) ...[
                      Text(
                        "Suggested for $businessType",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final item = suggestions[index];
                            return ActionChip(
                              label: Text(item["name"]?.toString() ?? ""),
                              onPressed: () => applySuggestion(item),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

                    // NAME
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
                              labelText: "Selling ₹",
                              errorText: sellingError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Profit: ₹${profit.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // IN STOCK
                    SwitchListTile(
                      value: inStock,
                      title: const Text("In Stock"),
                      onChanged: (val) {
                        setModalState(() => inStock = val);
                      },
                    ),

                    // SELL IN WEIGHT
                    SwitchListTile(
                      value: inWeight,
                      title: const Text("Sell in Weight"),
                      onChanged: (val) {
                        setModalState(() => inWeight = val);
                      },
                    ),

                    if (inWeight) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        initialValue: weightUnit,
                        items: weightUnits
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() => weightUnit = val!);
                        },
                        decoration: const InputDecoration(
                          labelText: "Weight Unit",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Weight per item",
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ADD BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        child: const Text("Add Product"),
                        onPressed: () {
                          setModalState(() {
                            nameError =
                                nameCtrl.text.isEmpty ? "Required" : null;
                            categoryError =
                                categoryCtrl.text.isEmpty ? "Required" : null;
                            purchaseError =
                                purchaseCtrl.text.isEmpty ? "Required" : null;
                            sellingError =
                                sellingCtrl.text.isEmpty ? "Required" : null;
                            stockError =
                                stockCtrl.text.isEmpty ? "Required" : null;
                          });

                          if (nameError != null ||
                              categoryError != null ||
                              purchaseError != null ||
                              sellingError != null ||
                              stockError != null) {
                            return;
                          }

                          final body = {
                            "ownerId": widget.userId,
                            "name": nameCtrl.text.trim(),
                            "category": categoryCtrl.text.trim(),
                            "description": descCtrl.text.trim(),
                            "purchase": double.tryParse(purchaseCtrl.text) ?? 0,
                            "selling": double.tryParse(sellingCtrl.text) ?? 0,
                            "stockQty": int.tryParse(stockCtrl.text) ?? 0,
                            "inStock": inStock,
                            "inWeight": inWeight,
                            "weightUnit": weightUnit,
                            "weight": double.tryParse(weightCtrl.text) ?? 0,
                            "businessType": businessType,
                          };

                          addProductApi(body);
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

  String formatMoney(dynamic value) {
    final number = (value is num)
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0.0;
    return "₹${number.toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddProductForm,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Search product...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() => searchText = val);
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text("No Products Found"))
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (_, index) {
                        final product = filteredProducts[index];

                        bool outOfStock = (product["stockQty"] ?? 0) == 0 ||
                            (product["inStock"] ?? false) == false;

                        return Card(
                          color: outOfStock ? Colors.red.shade50 : Colors.white,
                          child: ListTile(
                            title: Text(
                              product["name"] ?? "",
                              style: TextStyle(
                                color: outOfStock ? Colors.red : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              outOfStock
                                  ? "Out of Stock"
                                  : "Profit ${formatMoney(product["profit"])}",
                            ),
                            trailing: Text(formatMoney(product["selling"])),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetails(
                                    product: product,
                                    userRole: "Retailer",
                                    onDelete: () async {
                                      await deleteProductApi(product["_id"]);
                                      if (mounted) Navigator.pop(context);
                                    },
                                    onUpdate: (updatedProduct) async {
                                      await updateProductApi(updatedProduct);
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