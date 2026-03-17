import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../services/ledger_service.dart';

class RetailerOrderHubScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String shopName;
  final String businessType;

  const RetailerOrderHubScreen({
    super.key,
    required this.userId,
    this.userName = '',
    this.shopName = '',
    this.businessType = '',
  });

  @override
  State<RetailerOrderHubScreen> createState() => _RetailerOrderHubScreenState();
}

class _RetailerOrderHubScreenState extends State<RetailerOrderHubScreen> {
  bool _isLoadingSuggestions = true;
  late String _businessType;
  late List<Map<String, dynamic>> _orders;
  List<Map<String, dynamic>> _suggestions = [];

  static const List<Map<String, dynamic>> _supplierCatalog = [
    {
      'name': 'Shree Grocery Traders',
      'businessType': 'Grocery',
      'location': 'Ahmedabad',
      'rating': 4.8,
      'price': 46.0,
    },
    {
      'name': 'Patel Stationers Hub',
      'businessType': 'Stationery',
      'location': 'Surat',
      'rating': 4.7,
      'price': 28.0,
    },
    {
      'name': 'Care Medical Supply',
      'businessType': 'Medical',
      'location': 'Rajkot',
      'rating': 4.9,
      'price': 74.0,
    },
    {
      'name': 'Urban Cloth Market',
      'businessType': 'Clothing',
      'location': 'Vadodara',
      'rating': 4.6,
      'price': 180.0,
    },
    {
      'name': 'Electro Wholesale Point',
      'businessType': 'Electronics',
      'location': 'Ahmedabad',
      'rating': 4.5,
      'price': 650.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _businessType = _cleanBusinessType(widget.businessType);
    _orders = _defaultOrdersFor(_businessType);
    _suggestions = _fallbackSuggestionsFor(_businessType);
    _loadSuggestions();
  }

  String _cleanBusinessType(String value) {
    final cleaned = value.trim();
    return cleaned.isEmpty ? 'General' : cleaned;
  }

  List<Map<String, dynamic>> _defaultOrdersFor(String businessType) {
    return [
      {
        'id': '#RT201',
        'product': businessType == 'General' ? 'Popular Stock' : '$businessType Combo',
        'supplier': 'Shree ${businessType == 'General' ? 'Market' : businessType} Traders',
        'quantity': 20,
        'amount': 2400,
        'status': 'On The Way',
        'date': '2026-03-17',
      },
      {
        'id': '#RT198',
        'product': businessType == 'General' ? 'Daily Items' : '$businessType Refill',
        'supplier': 'A-One Supply',
        'quantity': 12,
        'amount': 1320,
        'status': 'Delivered',
        'date': '2026-03-15',
      },
      {
        'id': '#RT194',
        'product': 'Trial Order',
        'supplier': 'Smart Source Hub',
        'quantity': 8,
        'amount': 880,
        'status': 'Ordered',
        'date': '2026-03-14',
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackSuggestionsFor(String businessType) {
    switch (businessType.toLowerCase()) {
      case 'grocery':
        return [
          {'name': 'Rice Bag', 'category': 'Grocery', 'selling': 46.0},
          {'name': 'Sugar Pack', 'category': 'Grocery', 'selling': 38.0},
          {'name': 'Cooking Oil', 'category': 'Grocery', 'selling': 125.0},
        ];
      case 'stationery':
        return [
          {'name': 'Notebook Bundle', 'category': 'Stationery', 'selling': 55.0},
          {'name': 'Pen Pack', 'category': 'Stationery', 'selling': 22.0},
          {'name': 'A4 Paper Rim', 'category': 'Stationery', 'selling': 250.0},
        ];
      case 'medical':
        return [
          {'name': 'Bandage Box', 'category': 'Medical', 'selling': 42.0},
          {'name': 'Vitamin Pack', 'category': 'Medical', 'selling': 95.0},
          {'name': 'Hand Sanitizer', 'category': 'Medical', 'selling': 68.0},
        ];
      case 'clothing':
        return [
          {'name': 'Cotton T-Shirt', 'category': 'Clothing', 'selling': 185.0},
          {'name': 'Kids Wear Set', 'category': 'Clothing', 'selling': 240.0},
          {'name': 'Denim Piece', 'category': 'Clothing', 'selling': 315.0},
        ];
      case 'electronics':
        return [
          {'name': 'USB Cable', 'category': 'Electronics', 'selling': 79.0},
          {'name': 'Power Adapter', 'category': 'Electronics', 'selling': 210.0},
          {'name': 'Earphone Pack', 'category': 'Electronics', 'selling': 145.0},
        ];
      default:
        return [
          {'name': 'Fast Moving Stock', 'category': businessType, 'selling': 50.0},
          {'name': 'Best Seller Item', 'category': businessType, 'selling': 75.0},
          {'name': 'Repeat Order Pack', 'category': businessType, 'selling': 95.0},
        ];
    }
  }

  Future<void> _loadSuggestions() async {
    final base = dotenv.env['BASE_URL'] ?? '';

    if (base.isEmpty) {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
      return;
    }

    try {
      final uri = Uri.parse('$base/product/suggestions/${widget.userId}');
      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data['success'] == true) {
        final apiBusinessType = _cleanBusinessType(
          data['businessType']?.toString() ?? _businessType,
        );
        final parsedSuggestions = List<Map<String, dynamic>>.from(
          data['suggestions'] ?? const [],
        );

        if (!mounted) return;

        setState(() {
          _businessType = apiBusinessType;
          _suggestions = parsedSuggestions.isEmpty
              ? _fallbackSuggestionsFor(apiBusinessType)
              : parsedSuggestions;
          _isLoadingSuggestions = false;
        });

        return;
      }
    } catch (_) {
      // Fall back to same-business local suggestions.
    }

    if (mounted) {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  List<Map<String, dynamic>> get _matchingSuppliers {
    final matches = _supplierCatalog.where((supplier) {
      final supplierType = supplier['businessType']?.toString().toLowerCase() ?? '';
      return supplierType == _businessType.toLowerCase();
    }).toList();

    return matches.isEmpty ? _supplierCatalog : matches;
  }

  List<Map<String, dynamic>> get _ledgerPreview {
    if (LedgerService.ledgerEntries.isNotEmpty) {
      return LedgerService.ledgerEntries.reversed.take(4).toList();
    }

    return [
      {
        'party': 'Shree Grocery Traders',
        'type': 'Debit',
        'amount': 2400,
        'source': 'Order',
        'date': '2026-03-17',
      },
      {
        'party': 'A-One Supply',
        'type': 'Credit',
        'amount': 850,
        'source': 'Return',
        'date': '2026-03-15',
      },
    ];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'on the way':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _openPlaceOrderSheet({
    required String productName,
    required String supplierName,
    required double unitPrice,
  }) {
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: unitPrice.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        double quantity = double.tryParse(quantityController.text) ?? 0;
        double price = double.tryParse(priceController.text) ?? 0;
        double total = quantity * price;

        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateTotal() {
              final parsedQuantity =
                  double.tryParse(quantityController.text.trim()) ?? 0;
              final parsedPrice =
                  double.tryParse(priceController.text.trim()) ?? 0;

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
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Place Retailer Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$productName from $supplierName',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => updateTotal(),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => updateTotal(),
                      decoration: const InputDecoration(
                        labelText: 'Price per unit',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Total Amount: Rs ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final orderQuantity =
                              double.tryParse(quantityController.text.trim()) ?? 0;
                          final orderPrice =
                              double.tryParse(priceController.text.trim()) ?? 0;

                          if (orderQuantity <= 0 || orderPrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid quantity and price',
                                ),
                              ),
                            );
                            return;
                          }

                          final totalAmount = (orderQuantity * orderPrice).round();
                          final orderId = '#RT${200 + _orders.length + 1}';

                          setState(() {
                            _orders.insert(0, {
                              'id': orderId,
                              'product': productName,
                              'supplier': supplierName,
                              'quantity': orderQuantity,
                              'amount': totalAmount,
                              'status': 'Ordered',
                              'date': DateTime.now().toString().split(' ').first,
                            });
                          });

                          LedgerService.addEntry(
                            party: supplierName,
                            type: 'Debit',
                            amount: totalAmount,
                            source: 'Order',
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order created for $productName from $supplierName',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: const Text('Confirm Order'),
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
      quantityController.dispose();
      priceController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayShopName = widget.shopName.trim().isEmpty
        ? widget.userName.trim().isEmpty
            ? 'Retailer'
            : widget.userName.trim()
        : widget.shopName.trim();
    final openOrders = _orders
        .where((order) => order['status']?.toString().toLowerCase() != 'delivered')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Orders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayShopName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Same-business order suggestions for $_businessType',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _summaryChip(
                        title: 'Suppliers',
                        value: '${_matchingSuppliers.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryChip(
                        title: 'Open Orders',
                        value: '$openOrders',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryChip(
                        title: 'Ledger Items',
                        value: '${_ledgerPreview.length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('Suggested Orders'),
          const SizedBox(height: 10),
          if (_isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _suggestions.map((suggestion) {
                final productName = suggestion['name']?.toString() ?? 'Suggested Item';
                final category = suggestion['category']?.toString() ?? _businessType;
                final price =
                    double.tryParse(suggestion['selling']?.toString() ?? '') ?? 0;
                final supplier = _matchingSuppliers.first;

                return ActionChip(
                  avatar: const Icon(Icons.tips_and_updates_outlined, size: 18),
                  label: Text(productName),
                  onPressed: () {
                    _openPlaceOrderSheet(
                      productName: '$productName ($category)',
                      supplierName: supplier['name']?.toString() ?? 'Supplier',
                      unitPrice: price > 0
                          ? price
                          : (supplier['price'] as num?)?.toDouble() ?? 50,
                    );
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          _sectionTitle('Same Business Suppliers'),
          const SizedBox(height: 10),
          ..._matchingSuppliers.map((supplier) {
            final name = supplier['name']?.toString() ?? 'Supplier';
            final location = supplier['location']?.toString() ?? '';
            final rating = supplier['rating']?.toString() ?? '0';
            final price = (supplier['price'] as num?)?.toDouble() ?? 50;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF2563EB),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${supplier['businessType']}  •  $location',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rating $rating  •  From Rs ${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final suggestedProduct = _suggestions.isEmpty
                          ? _fallbackSuggestionsFor(_businessType).first['name'].toString()
                          : _suggestions.first['name']?.toString() ?? 'Suggested Item';

                      _openPlaceOrderSheet(
                        productName: suggestedProduct,
                        supplierName: name,
                        unitPrice: price,
                      );
                    },
                    child: const Text('Order'),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          _sectionTitle('Orders and Status'),
          const SizedBox(height: 10),
          ..._orders.map((order) {
            final status = order['status']?.toString() ?? 'Ordered';
            final color = _statusColor(status);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order['product']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          status,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: color,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order['supplier']}  •  ${order['date']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _orderInfo(
                          label: 'Order ID',
                          value: order['id']?.toString() ?? '',
                        ),
                      ),
                      Expanded(
                        child: _orderInfo(
                          label: 'Quantity',
                          value: '${order['quantity']}',
                        ),
                      ),
                      Expanded(
                        child: _orderInfo(
                          label: 'Amount',
                          value: 'Rs ${order['amount']}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          _sectionTitle('Ledger Preview'),
          const SizedBox(height: 10),
          ..._ledgerPreview.map((entry) {
            final isCredit =
                entry['type']?.toString().toLowerCase() == 'credit';

            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: isCredit
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.12),
                child: Icon(
                  isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                entry['party']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${entry['source']}  •  ${entry['date']}',
              ),
              trailing: Text(
                'Rs ${entry['amount']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _summaryChip({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _orderInfo({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
