import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../services/ledger_service.dart';

enum OrderStatus { pending, approved, onTheWay, delivered, rejected, cancelled }

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
  final TextEditingController _advanceController = TextEditingController();

  bool _isRequestingAdvance = false;
  bool _isPayingAdvance = false;
  bool _isRequestingFinal = false;
  bool _isCompletingPayment = false;

  // ✅ FIX: Use local mutable copies of order fields so setState rebuilds UI correctly
  late String _orderStatus;
  late String _paymentStatus;
  late bool _advanceRequested;
  late bool _advancePaid;
  late bool _finalPaymentRequested;
  late bool _fullPaymentDone;

  @override
  void initState() {
    super.initState();
    // ✅ Copy all relevant fields into local state on init
    _orderStatus = widget.order["orderStatus"]?.toString() ?? "pending";
    _paymentStatus = widget.order["paymentStatus"]?.toString() ?? "unpaid";
    _advanceRequested = widget.order["advanceRequested"] == true;
    _advancePaid = widget.order["advancePaid"] == true;
    _finalPaymentRequested = widget.order["finalPaymentRequested"] == true;
    _fullPaymentDone = widget.order["fullPaymentDone"] == true;

    _status = _parseStatus(_orderStatus);
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

  String _getProductName() =>
      widget.order["productName"]?.toString() ?? "Product";
  String _getUnit() => widget.order["unit"]?.toString() ?? "item";
  double _getQuantity() => _getAmount(widget.order["quantity"]);
  double _getPricePerUnit() => _getAmount(widget.order["pricePerUnit"]);
  double _getTotalAmount() => _getAmount(widget.order["totalAmount"]);
  double _getAdvanceAmount() => _getAmount(widget.order["advanceAmount"]);
  double _getRemainingAmount() => _getAmount(widget.order["remainingAmount"]);
  double _getAdvancePercentage() =>
      _getAmount(widget.order["advancePercentage"]);

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  Future<void> _saveStatus() async {
    final orderId = widget.order["_id"]?.toString();
    if (orderId == null || orderId.isEmpty) {
      _showSnack("Invalid order id");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      if (base.isEmpty) throw Exception("BASE_URL is missing in .env");

      final response = await http
          .patch(
            Uri.parse('$base/orders/$orderId/status'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"status": _statusApiValue(_status)}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      // ✅ FIX: Update local _orderStatus so "Request Final Payment" card shows correctly
      setState(() {
        _orderStatus = _statusApiValue(_status);
      });

      if (_status == OrderStatus.delivered) {
        LedgerService.addEntry(
          party: _getRetailerName(),
          type: "Debit",
          amount: _getTotalAmount().toInt(),
          source: "Order",
        );
        LedgerService.addEntry(
          party: _getWholesalerName(),
          type: "Credit",
          amount: _getTotalAmount().toInt(),
          source: "Order",
        );
      }

      if (!mounted) return;
      _showSnack(
        _status == OrderStatus.rejected
            ? "Order rejected successfully"
            : "Order status updated successfully",
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack("Failed to update status: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _requestAdvancePayment() async {
    final percentage = double.tryParse(_advanceController.text);
    if (percentage == null || percentage <= 0 || percentage > 100) {
      _showSnack("Enter a valid percentage (1–100)");
      return;
    }

    setState(() => _isRequestingAdvance = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final orderId = widget.order["_id"];

      final response = await http.patch(
        Uri.parse('$base/orders/$orderId/request-advance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"advancePercentage": percentage}),
      );

      if (response.statusCode == 200) {
        // ✅ FIX: Update local state so card switches immediately
        setState(() {
          _advanceRequested = true;
          _paymentStatus = "advanceRequested";
          widget.order["advanceRequested"] = true;
          widget.order["advancePercentage"] = percentage;
          // Calculate and store advance amount locally for display
          widget.order["advanceAmount"] =
              _getTotalAmount() * (percentage / 100);
          widget.order["remainingAmount"] =
              _getTotalAmount() - (widget.order["advanceAmount"] as double);
        });
        if (!mounted) return;
        _showSnack("Advance request sent (${percentage.toStringAsFixed(0)}%)");
        Navigator.pop(context, true);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isRequestingAdvance = false);
    }
  }

  Future<void> _payAdvance() async {
    setState(() => _isPayingAdvance = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final orderId = widget.order["_id"];

      final response = await http.patch(
        Uri.parse('$base/orders/$orderId/pay-advance'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        // ✅ FIX: Update local state variables, not widget.order map
        setState(() {
          _paymentStatus = "advancePaid";
          _advancePaid = true;
          widget.order["paymentStatus"] = "advancePaid";
          widget.order["advancePaid"] = true;
        });
        _showSnack("Advance paid successfully");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isPayingAdvance = false);
    }
  }

  Future<void> _requestFinalPayment() async {
    setState(() => _isRequestingFinal = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final orderId = widget.order["_id"];

      final response = await http.patch(
        Uri.parse('$base/orders/$orderId/request-final-payment'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        // ✅ FIX: Update local _finalPaymentRequested so card hides
        setState(() {
          _finalPaymentRequested = true;
        });
        _showSnack("Final payment requested");
        Navigator.pop(context, true);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isRequestingFinal = false);
    }
  }

  Future<void> _completePayment() async {
    setState(() => _isCompletingPayment = true);

    try {
      final base = dotenv.env['BASE_URL'] ?? '';
      final orderId = widget.order["_id"];

      final response = await http.patch(
        Uri.parse('$base/orders/$orderId/complete-payment'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        // ✅ FIX: Update local state
        setState(() {
          _paymentStatus = "paid";
          _fullPaymentDone = true;
          widget.order["paymentStatus"] = "paid";
          widget.order["fullPaymentDone"] = true;
        });
        _showSnack("Payment completed successfully");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isCompletingPayment = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
    final role = widget.userRole.trim().toLowerCase();
    final canEditStatus = role == "wholesaler";

    // ✅ FIX: Use local state variables for all conditions
    final isAdvancePaid = _paymentStatus.toLowerCase() == "advancepaid";
    final isFullyPaid =
        _fullPaymentDone || _paymentStatus.toLowerCase() == "paid";
    final isDelivered = _orderStatus.toLowerCase() == "delivered";

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── ORDER CARD ───────────────────────────────────────
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
                    _detailRow(
                      "Quantity",
                      "${_formatQuantity(quantity)} $unit",
                    ),
                    _detailRow(
                      "Price / Unit",
                      "₹${pricePerUnit.toStringAsFixed(2)}",
                    ),
                    _detailRow("Payment", _paymentStatus), // ✅ local state
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

            // ─── STATUS CHIPS ─────────────────────────────────────
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
                      ? (_) => setState(() => _status = status)
                      : null,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ─── WHOLESALER: REQUEST ADVANCE ──────────────────────
            // Show only if advance not yet requested
            if (canEditStatus && !_advanceRequested)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Request Advance Payment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _advanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter percentage (e.g. 30)",
                          suffixText: "%",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isRequestingAdvance
                              ? null
                              : _requestAdvancePayment,
                          child: _isRequestingAdvance
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Send Advance Request"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── RETAILER: PAY ADVANCE ────────────────────────────
            // ✅ FIX: Use local _advanceRequested and _advancePaid
            if (!canEditStatus && _advanceRequested)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdvancePaid
                            ? "Advance Payment Completed ✓"
                            : "Advance Requested (${_getAdvancePercentage().toStringAsFixed(0)}%)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAdvancePaid ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isAdvancePaid
                            ? "Advance: ₹${_getAdvanceAmount().toStringAsFixed(2)} paid"
                            : "Advance Amount: ₹${_getAdvanceAmount().toStringAsFixed(2)}",
                      ),
                      // ✅ FIX: Show Pay button only if advance NOT yet paid
                      if (!isAdvancePaid) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: _isPayingAdvance
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.payment),
                            label: const Text("Pay Advance"),
                            onPressed: _isPayingAdvance ? null : _payAdvance,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // ─── RETAILER: COMPLETE FINAL PAYMENT ────────────────
            // ✅ FIX: Show "Pay Remaining" to retailer when finalPaymentRequested
            if (!canEditStatus && _finalPaymentRequested && !isFullyPaid)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Final Payment Requested",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Remaining Amount: ₹${_getRemainingAmount().toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isCompletingPayment
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: const Text("Pay Remaining Amount"),
                          onPressed: _isCompletingPayment
                              ? null
                              : _completePayment,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── WHOLESALER: REQUEST FINAL PAYMENT ───────────────
            // ✅ FIX: Use local _orderStatus and _finalPaymentRequested
            if (canEditStatus && isDelivered && !_finalPaymentRequested)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Request Remaining Payment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Remaining Amount: ₹${_getRemainingAmount().toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isRequestingFinal
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.request_page),
                          label: const Text("Request Remaining Amount"),
                          onPressed: _isRequestingFinal
                              ? null
                              : _requestFinalPayment,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ✅ Show payment done banner for retailer
            if (!canEditStatus && isFullyPaid)
              Card(
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        "All payments completed!",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ─── BOTTOM BUTTON ────────────────────────────────────
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
            const SizedBox(height: 16),
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
