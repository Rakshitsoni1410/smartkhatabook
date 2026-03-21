import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/user_role.dart';
import 'product_detail.dart';

class ProductScreen extends StatefulWidget {
  final String userId;
  final UserRole userRole;
  final String userName;
  final String shopName;
  final String initialBusinessType;

  const ProductScreen({
    super.key,
    required this.userId,
    required this.userRole,
    this.userName = '',
    this.shopName = '',
    this.initialBusinessType = '',
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String searchText = "";
  late String businessType;
  bool isLoading = true;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> suggestions = [];

  @override
  void initState() {
    super.initState();
    businessType = widget.initialBusinessType.trim().isEmpty
        ? "General"
        : widget.initialBusinessType.trim();
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
          businessType = (data["businessType"]?.toString().trim().isNotEmpty ??
                  false)
              ? data["businessType"].toString().trim()
              : businessType;
          suggestions = List<Map<String, dynamic>>.from(
            data["suggestions"] ?? [],
          );
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "Failed to load suggestions"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Suggestions error: $e")),
        );
      }
    }
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "Failed to load products"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Products error: $e")),
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
            SnackBar(
              content: Text(data["message"] ?? "Product added successfully"),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data["message"] ?? "Add product failed (${resp.statusCode})",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Add product failed: $e")),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Product updated")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Update failed")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    }
  }

  Future<void> deleteProductApi(String productId) async {
    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final uri = Uri.parse('$base/product/delete/$productId');

      final resp = await http.delete(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data["success"] == true) {
        await loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Product deleted")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Delete failed")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final name = (product["name"] ?? "").toString().toLowerCase();
      final category = (product["category"] ?? "").toString().toLowerCase();

      return name.contains(searchText.toLowerCase()) ||
          category.contains(searchText.toLowerCase());
    }).toList();
  }

  void openAddProductForm() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController categoryCtrl =
        TextEditingController(text: businessType);
    final TextEditingController descCtrl = TextEditingController();
    final TextEditingController purchaseCtrl = TextEditingController();
    final TextEditingController sellingCtrl = TextEditingController();
    final TextEditingController stockCtrl = TextEditingController();
    final TextEditingController weightCtrl = TextEditingController();

    bool inStock = true;
    bool inWeight = false;
    String weightUnit = "kg";
    double profit = 0;

    String? nameError;
    String? categoryError;
    String? purchaseError;
    String? sellingError;
    String? stockError;

    final List<String> weightUnits = [
      "kg",
      "gram",
      "liter",
      "ml",
      "piece",
      "pack",
      "dozen",
      "strip"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void calcProfit() {
              final purchase = double.tryParse(purchaseCtrl.text) ?? 0;
              final selling = double.tryParse(sellingCtrl.text) ?? 0;

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
                    if (suggestions.isNotEmpty) ...[
                      Text(
                        "Suggested for $businessType",
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                    SwitchListTile(
                      value: inStock,
                      title: const Text("In Stock"),
                      onChanged: (val) {
                        setModalState(() => inStock = val);
                      },
                    ),
                    SwitchListTile(
                      value: inWeight,
                      title: const Text("Sell in Weight"),
                      onChanged: (val) {
                        setModalState(() => inWeight = val);
                      },
                    ),
                    if (inWeight) ...[
                      const SizedBox(height: 10),
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        child: const Text("Add Product"),
                        onPressed: () {
                          setModalState(() {
                            nameError =
                                nameCtrl.text.trim().isEmpty ? "Required" : null;
                            categoryError = categoryCtrl.text.trim().isEmpty
                                ? "Required"
                                : null;
                            purchaseError = purchaseCtrl.text.trim().isEmpty
                                ? "Required"
                                : null;
                            sellingError = sellingCtrl.text.trim().isEmpty
                                ? "Required"
                                : null;
                            stockError =
                                stockCtrl.text.trim().isEmpty ? "Required" : null;
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

  Widget _infoBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManageStock = widget.userRole != UserRole.customer;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: canManageStock
          ? FloatingActionButton(
              heroTag: null,
              onPressed: openAddProductForm,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
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
                  : ListView.separated(
                      itemCount: filteredProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final product = filteredProducts[index];

                        final bool outOfStock =
                            (product["stockQty"] ?? 0) == 0 ||
                            (product["inStock"] ?? false) == false;

                        final String name = product["name"]?.toString() ?? "";
                        final String category =
                            product["category"]?.toString() ?? "";
                        final double selling =
                            double.tryParse(product["selling"].toString()) ?? 0;
                        final double profit =
                            double.tryParse(product["profit"].toString()) ?? 0;
                        final int stockQty =
                            int.tryParse(product["stockQty"].toString()) ?? 0;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetails(
                                  product: product,
                                  userRole: widget.userRole.label,
                                  userId: widget.userId,
                                  userName: widget.userName,
                                  shopName: widget.shopName,
                                  businessType: businessType,
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
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: outOfStock
                                  ? const Color(0xffFFF1F1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: outOfStock
                                    ? Colors.red.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.10),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 54,
                                  width: 54,
                                  decoration: BoxDecoration(
                                    color: outOfStock
                                        ? Colors.red.withOpacity(0.10)
                                        : const Color(0xff6D5DF6)
                                            .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: outOfStock
                                        ? Colors.red
                                        : const Color(0xff6D5DF6),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: outOfStock
                                              ? Colors.red
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff6D5DF6)
                                                  .withOpacity(0.10),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              category.isEmpty
                                                  ? "General"
                                                  : category,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff6D5DF6),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: outOfStock
                                                  ? Colors.red.withOpacity(0.10)
                                                  : Colors.green
                                                      .withOpacity(0.10),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              outOfStock
                                                  ? "Out of Stock"
                                                  : "In Stock",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: outOfStock
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _infoBox(
                                              title: "Selling",
                                              value:
                                                  "₹${selling.toStringAsFixed(0)}",
                                              color: const Color(0xff2196F3),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _infoBox(
                                              title: "Profit",
                                              value:
                                                  "₹${profit.toStringAsFixed(0)}",
                                              color: const Color(0xff2E7D32),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _infoBox(
                                              title: "Stock",
                                              value: stockQty.toString(),
                                              color: const Color(0xffF57C00),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
