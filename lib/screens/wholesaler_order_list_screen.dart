import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'wholesaler_order_status_screen.dart';

enum OrderStatus { ordered, onTheWay, onHold, delivered, cancelled }

class WholesalerOrderListScreen extends StatefulWidget {
  final String title;
  final String userId;
  final String userRole;

  const WholesalerOrderListScreen({
    super.key,
    required this.userId,
    required this.userRole,
    this.title = 'Orders',
  });

  @override
  State<WholesalerOrderListScreen> createState() =>
      _WholesalerOrderListScreenState();
}

class _WholesalerOrderListScreenState
    extends State<WholesalerOrderListScreen> {
  String _filter = "All";
  bool _isLoading = true;

  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      if (base.isEmpty) {
        throw Exception("BASE_URL is missing in .env");
      }

      final normalizedRole = widget.userRole.trim().toLowerCase();

      final uri = normalizedRole == "wholesaler"
          ? Uri.parse('$base/orders/wholesaler/${widget.userId}')
          : Uri.parse('$base/orders/retailer/${widget.userId}');

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200) {
        if (data is List) {
          orders = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data["orders"] is List) {
          orders = List<Map<String, dynamic>>.from(data["orders"]);
        } else {
          orders = [];
        }
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Orders error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (_filter == "Completed") {
      return orders
          .where((o) =>
              (o["orderStatus"]?.toString().toLowerCase() ?? "") ==
              "delivered")
          .toList();
    }

    if (_filter == "Pending") {
      return orders
          .where((o) =>
              (o["orderStatus"]?.toString().toLowerCase() ?? "") !=
              "delivered")
          .toList();
    }

    return orders;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "ontheway":
        return Colors.orange;
      case "approved":
        return Colors.blue;
      case "onhold":
        return Colors.grey;
      case "cancelled":
      case "rejected":
        return Colors.red;
      case "pending":
      default:
        return Colors.deepPurple;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case "ontheway":
        return "On The Way";
      case "onhold":
        return "On Hold";
      case "approved":
        return "Approved";
      case "rejected":
        return "Rejected";
      case "pending":
        return "Pending";
      case "delivered":
        return "Delivered";
      case "cancelled":
        return "Cancelled";
      default:
        return status.isEmpty ? "Pending" : status;
    }
  }

  String _displayPartyName(Map<String, dynamic> order) {
    final normalizedRole = widget.userRole.trim().toLowerCase();

    if (normalizedRole == "wholesaler") {
      final retailer = order["retailerId"];
      if (retailer is Map<String, dynamic>) {
        return retailer["shopName"]?.toString().isNotEmpty == true
            ? retailer["shopName"].toString()
            : retailer["name"]?.toString() ?? "Retailer";
      }
      return order["retailerName"]?.toString() ?? "Retailer";
    } else {
      final wholesaler = order["wholesalerId"];
      if (wholesaler is Map<String, dynamic>) {
        return wholesaler["shopName"]?.toString().isNotEmpty == true
            ? wholesaler["shopName"].toString()
            : wholesaler["name"]?.toString() ?? "Wholesaler";
      }
      return order["wholesalerName"]?.toString() ?? "Wholesaler";
    }
  }

  String _displayOrderId(Map<String, dynamic> order) {
    return order["_id"]?.toString() ??
        order["id"]?.toString() ??
        "Order";
  }

  double _displayAmount(Map<String, dynamic> order) {
    final value = order["totalAmount"];
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? "0") ?? 0;
  }

  String _displayProduct(Map<String, dynamic> order) {
    return order["productName"]?.toString() ?? "Product";
  }

  @override
  Widget build(BuildContext context) {
    final normalizedRole = widget.userRole.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: loadOrders,
            icon: const Icon(Icons.refresh),
          ),
          DropdownButton<String>(
            value: _filter,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            items: const [
              DropdownMenuItem(value: "All", child: Text("All")),
              DropdownMenuItem(value: "Completed", child: Text("Completed")),
              DropdownMenuItem(value: "Pending", child: Text("Pending")),
            ],
            onChanged: (v) => setState(() => _filter = v!),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredOrders.isEmpty
              ? Center(
                  child: Text(
                    normalizedRole == "wholesaler"
                        ? "No incoming orders"
                        : "No order history found",
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final o = filteredOrders[index];
                      final status =
                          o["orderStatus"]?.toString() ?? "pending";
                      final partyName = _displayPartyName(o);
                      final amount = _displayAmount(o);
                      final orderId = _displayOrderId(o);
                      final productName = _displayProduct(o);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WholesalerOrderStatusScreen(
                                  order: o,
                                  userRole: widget.userRole,
                                ),
                              ),
                            );

                            loadOrders();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        partyName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "₹${amount.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  productName,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        orderId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Chip(
                                      label: Text(
                                        _statusText(status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: _statusColor(status),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}