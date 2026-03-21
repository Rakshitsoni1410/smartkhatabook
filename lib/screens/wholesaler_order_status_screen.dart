import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../services/ledger_service.dart';

enum OrderStatus {
  pending,
  approved,
  onTheWay,
  delivered,
  rejected,
  cancelled,
}

class WholesalerOrderStatusScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String userRole;

  const WholesalerOrderStatusScreen({
    super.key,
    required this.order,
    required this.userRole,
  });

  @override
  State<WholesalerOrderStatusScreen> createState() =>
      _WholesalerOrderStatusScreenState();
}

class _WholesalerOrderStatusScreenState
    extends State<WholesalerOrderStatusScreen> {
  late OrderStatus _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status =
        _parseStatus(widget.order["orderStatus"]?.toString() ?? "pending");
  }

  OrderStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case "approved":
        return OrderStatus.approved;
      case "ontheway":
        return OrderStatus.onTheWay;
      case "delivered":
        return OrderStatus.delivered;
      case "rejected":
        return OrderStatus.rejected;
      case "cancelled":
        return OrderStatus.cancelled;
      case "pending":
      default:
        return OrderStatus.pending;
    }
  }

  String _statusApiValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "pending";
      case OrderStatus.approved:
        return "approved";
      case OrderStatus.onTheWay:
        return "onTheWay";
      case OrderStatus.delivered:
        return "delivered";
      case OrderStatus.rejected:
        return "rejected";
      case OrderStatus.cancelled:
        return "cancelled";
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.deepPurple;
      case OrderStatus.approved:
        return Colors.blue;
      case OrderStatus.onTheWay:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
    }
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.approved:
        return "Approved";
      case OrderStatus.onTheWay:
        return "On The Way";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.rejected:
        return "Rejected";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  double _getAmount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  String _getRetailerName() {
    final retailer = widget.order["retailerId"];
    if (retailer is Map<String, dynamic>) {
      final shopName = retailer["shopName"]?.toString() ?? "";
      if (shopName.isNotEmpty) return shopName;
      return retailer["name"]?.toString() ?? "Retailer";
    }
    return widget.order["retailerName"]?.toString() ?? "Retailer";
  }

  String _getWholesalerName() {
    final wholesaler = widget.order["wholesalerId"];
    if (wholesaler is Map<String, dynamic>) {
      final shopName = wholesaler["shopName"]?.toString() ?? "";
      if (shopName.isNotEmpty) return shopName;
      return wholesaler["name"]?.toString() ?? "Wholesaler";
    }
    return widget.order["wholesalerName"]?.toString() ?? "Wholesaler";
  }

  String _getOrderId() {
    return widget.order["_id"]?.toString() ??
        widget.order["id"]?.toString() ??
        "Order";
  }

  String _getProductName() {
    return widget.order["productName"]?.toString() ?? "Product";
  }

  String _getUnit() {
    return widget.order["unit"]?.toString() ?? "item";
  }

  double _getQuantity() {
    return _getAmount(widget.order["quantity"]);
  }

  double _getPricePerUnit() {
    return _getAmount(widget.order["pricePerUnit"]);
  }

  double _getTotalAmount() {
    return _getAmount(widget.order["totalAmount"]);
  }

  String _getPaymentStatus() {
    return widget.order["paymentStatus"]?.toString() ?? "unpaid";
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  Future<void> _saveStatus() async {
    final orderId = widget.order["_id"]?.toString();
    if (orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid order id")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      if (base.isEmpty) {
        throw Exception("BASE_URL is missing in .env");
      }

      final uri = Uri.parse('$base/orders/$orderId/status');

      final response = await http
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "status": _statusApiValue(_status),
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception("Failed to update order status");
      }

      if (_status == OrderStatus.delivered) {
        final amount = _getTotalAmount();
        final retailerName = _getRetailerName();
        final wholesalerName = _getWholesalerName();

        LedgerService.addEntry(
          party: retailerName,
          type: "Debit",
          amount: amount.toInt(),
          source: "Order",
        );

        LedgerService.addEntry(
          party: wholesalerName,
          type: "Credit",
          amount: amount.toInt(),
          source: "Order",
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _status == OrderStatus.rejected
                ? "Order rejected successfully"
                : "Order status updated successfully",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  List<OrderStatus> _allowedStatuses() {
    final role = widget.userRole.trim().toLowerCase();

    if (role == "wholesaler") {
      return [
        OrderStatus.pending,
        OrderStatus.approved,
        OrderStatus.onTheWay,
        OrderStatus.delivered,
        OrderStatus.rejected,
      ];
    }

    return [_status];
  }

  @override
  Widget build(BuildContext context) {
    final retailerName = _getRetailerName();
    final wholesalerName = _getWholesalerName();
    final orderId = _getOrderId();
    final productName = _getProductName();
    final quantity = _getQuantity();
    final unit = _getUnit();
    final pricePerUnit = _getPricePerUnit();
    final orderAmount = _getTotalAmount();
    final paymentStatus = _getPaymentStatus();
    final role = widget.userRole.trim().toLowerCase();
    final canEditStatus = role == "wholesaler";

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canEditStatus ? retailerName : wholesalerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Order ID: $orderId",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Divider(height: 24),
                    _detailRow("Product", productName),
                    _detailRow("Quantity", "${_formatQuantity(quantity)} $unit"),
                    _detailRow(
                      "Price / Unit",
                      "₹${pricePerUnit.toStringAsFixed(2)}",
                    ),
                    _detailRow("Payment", paymentStatus),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "₹${orderAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(
                          _statusText(_status),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _statusColor(_status),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                canEditStatus ? "Update Order Status" : "Order Status",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allowedStatuses().map((status) {
                final isSelected = _status == status;

                return ChoiceChip(
                  label: Text(_statusText(status)),
                  selected: isSelected,
                  selectedColor: _statusColor(status),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: canEditStatus
                      ? (_) {
                          setState(() => _status = status);
                        }
                      : null,
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _status == OrderStatus.rejected
                            ? Icons.cancel
                            : Icons.check_circle,
                      ),
                label: Text(
                  canEditStatus
                      ? (_status == OrderStatus.rejected
                          ? "Reject Order"
                          : "Save Status")
                      : "Close",
                ),
                onPressed: _isSaving
                    ? null
                    : canEditStatus
                        ? _saveStatus
                        : () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}