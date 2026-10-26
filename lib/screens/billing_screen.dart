// lib/screens/billing_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Billing screen — role-aware, pure setState, matches all backend routes.
//
// Roles:
//   wholesaler / owner  → GET /billing/wholesaler/:id
//                          can "Send Bill" (PATCH /:id/send-bill)
//                          can "Request Advance" (PATCH /:id/request-advance)
//                          can "Request Final Payment" (PATCH /:id/request-final-payment)
//
//   retailer            → GET /billing/retailer/:id   (bills sent to them)
//                          can "Pay Advance"  (PATCH /:id/pay-advance)
//                          can "Pay Final"    (PATCH /:id/complete-payment)
//
// Payment gateway is DEMO only — mock UPI / Card / NetBanking.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../services/api_client.dart';
import 'invoice_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

class BillingScreen extends StatefulWidget {
  final String userId;
  final String userRole; // "owner" | "wholesaler" | "retailer"

  const BillingScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  // ── state ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _bills = [];
  final Set<String> _busyOrderIds = {};
  bool _loading = true;
  String? _error;
  String _filter = 'all'; // all | unpaid | paid

  // ── derived ────────────────────────────────────────────────────────────────
  bool get _isWholesalerSide =>
      widget.userRole.trim().toLowerCase() == 'wholesaler' ||
      widget.userRole.trim().toLowerCase() == 'owner';

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  // ── fetch ──────────────────────────────────────────────────────────────────
  Future<void> _fetchBills() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = _isWholesalerSide
          ? ApiConfig.billingWholesaler(widget.userId)
          : ApiConfig.billingRetailer(widget.userId);
      final data = await ApiClient.get(url);
      if (data['success'] != true) {
        throw ApiException(
          data['message']?.toString() ?? 'Failed to load bills',
        );
      }
      final raw = data['bills'];
      final fetchedBills = raw is List
          ? raw
                .whereType<Map>()
                .map((bill) => Map<String, dynamic>.from(bill))
                .where(
                  (bill) =>
                      _isWholesalerSide || bill['billSentToRetailer'] == true,
                )
                .toList()
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _bills = fetchedBills;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load bills from the local backend: $error';
        _loading = false;
      });
    }
  }

  // ── filter helper ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _bills;
    if (_filter == 'paid') {
      return _bills.where((b) => b['paymentStatus'] == 'paid').toList();
    }
    // unpaid = anything that isn't "paid"
    return _bills.where((b) => b['paymentStatus'] != 'paid').toList();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  // ── actions ────────────────────────────────────────────────────────────────

  Future<void> _sendBill(Map<String, dynamic> bill) async {
    final orderId = bill['_id']?.toString() ?? bill['id']?.toString() ?? '';
    if (orderId.isEmpty || _busyOrderIds.contains(orderId)) return;
    final invoiceNumber = bill['invoiceNumber']?.toString();
    final productName = bill['productName']?.toString() ?? 'Product';
    final amount = _toDouble(bill['totalAmount']);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send this bill to retailer?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice: ${invoiceNumber?.isNotEmpty == true ? invoiceNumber : 'Assigned when sent'}',
            ),
            Text('Product: $productName'),
            Text('Amount: ₹${amount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _busyOrderIds.contains(orderId)) {
      return;
    }

    setState(() => _busyOrderIds.add(orderId));
    try {
      final data = await ApiClient.patch(ApiConfig.sendBill(orderId));
      if (!mounted) return;
      if (data['success'] != true) {
        throw ApiException(
          data['message']?.toString() ?? 'Failed to send bill',
        );
      }
      _showSnack('Bill sent to retailer', Colors.green);
      await _fetchBills();
    } on ApiException catch (error) {
      if (mounted) _showSnack(error.message, Colors.red);
    } catch (error) {
      if (mounted) _showSnack('Unable to send bill: $error', Colors.red);
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(orderId));
    }
  }

  // Wholesaler: request advance payment
  Future<void> _requestAdvance(String orderId, double totalAmount) async {
    final pct = await _showPercentageDialog(totalAmount);
    if (pct == null) {
      return;
    }

    try {
      final data = await ApiClient.patch(
        ApiConfig.requestAdvance(orderId),
        body: {'advancePercentage': pct},
      );
      if (!mounted) return;
      if (data['success'] != true) {
        throw ApiException(data['message']?.toString() ?? 'Request failed');
      }
      _showSnack('Advance payment requested', Colors.green);
      await _fetchBills();
    } on ApiException catch (error) {
      if (mounted) _showSnack(error.message, Colors.red);
    } catch (error) {
      if (mounted) {
        _showSnack('Unable to request advance payment: $error', Colors.red);
      }
    }
  }

  // Wholesaler: request final payment
  Future<void> _requestFinalPayment(String orderId) async {
    try {
      final data = await ApiClient.patch(
        ApiConfig.requestFinalPayment(orderId),
      );
      if (!mounted) return;
      if (data['success'] != true) {
        throw ApiException(data['message']?.toString() ?? 'Request failed');
      }
      _showSnack('Final payment requested', Colors.green);
      await _fetchBills();
    } on ApiException catch (error) {
      if (mounted) _showSnack(error.message, Colors.red);
    } catch (error) {
      if (mounted) {
        _showSnack('Unable to request final payment: $error', Colors.red);
      }
    }
  }

  // Retailer: pay advance
  Future<void> _payAdvance(Map<String, dynamic> bill) async {
    final amount = _toDouble(bill['advanceAmount']);
    final orderId = bill['_id']?.toString() ?? bill['id']?.toString() ?? '';
    if (orderId.isEmpty) {
      _showSnack('This bill has no valid order ID', Colors.red);
      return;
    }

    await _openDemoPaymentSheet(
      orderId: orderId,
      amount: amount,
      paymentType: 'advance',
    );
  }

  // Retailer: complete final payment
  Future<void> _payFinal(Map<String, dynamic> bill) async {
    final amount = _toDouble(bill['remainingAmount']);
    final orderId = bill['_id']?.toString() ?? bill['id']?.toString() ?? '';
    if (orderId.isEmpty) {
      _showSnack('This bill has no valid order ID', Colors.red);
      return;
    }

    await _openDemoPaymentSheet(
      orderId: orderId,
      amount: amount,
      paymentType: 'final',
    );
  }

  // ── demo payment sheet ─────────────────────────────────────────────────────
  Future<void> _openDemoPaymentSheet({
    required String orderId,
    required double amount,
    required String paymentType, // "advance" | "final"
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DemoPaymentSheet(
        orderId: orderId,
        amount: amount,
        paymentType: paymentType,
        onSuccess: () async {
          _showSnack('Payment successful ✅', Colors.green);
          await _fetchBills();
        },
        onError: (msg) => _showSnack(msg, Colors.red),
      ),
    );
  }

  // ── percentage dialog ──────────────────────────────────────────────────────
  Future<int?> _showPercentageDialog(double totalAmount) async {
    int selected = 30;
    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Request Advance %',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [10, 20, 25, 30, 40, 50].map((pct) {
                  final isSelected = selected == pct;
                  return ChoiceChip(
                    label: Text('$pct%'),
                    selected: isSelected,
                    selectedColor: const Color(0xff6D5DF6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) => setDlg(() => selected = pct),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Advance: ₹${(totalAmount * selected / 100).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6D5DF6),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6D5DF6),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }

  // ── snackbar ───────────────────────────────────────────────────────────────
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: color, content: Text(msg)));
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _isWholesalerSide ? 'Billing' : 'My Bills',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBills,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  // ── error state ────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error == 'SESSION_EXPIRED'
                  ? 'Session expired. Please log in again.'
                  : _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchBills,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6D5DF6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── filter bar ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: ['all', 'unpaid', 'paid'].map((f) {
          final active = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xff6D5DF6)
                      : const Color(0xffF0EFFE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f[0].toUpperCase() + f.substring(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : const Color(0xff6D5DF6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── list ───────────────────────────────────────────────────────────────────
  Widget _buildList() {
    final bills = _filtered;
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _filter == 'all' ? 'No bills yet' : 'No $_filter bills',
              style: const TextStyle(fontSize: 16, color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBills,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (_, i) => _BillCard(
          bill: bills[i],
          isWholesalerSide: _isWholesalerSide,
          onSendBill: _sendBill,
          onViewInvoice: _viewInvoice,
          onRequestAdvance: _requestAdvance,
          onRequestFinalPayment: _requestFinalPayment,
          onPayAdvance: _payAdvance,
          onPayFinal: _payFinal,
        ),
      ),
    );
  }

  void _viewInvoice(Map<String, dynamic> bill) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => InvoiceScreen(bill: bill)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BILL CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BillCard extends StatelessWidget {
  final Map<String, dynamic> bill;
  final bool isWholesalerSide;
  final Future<void> Function(Map<String, dynamic> bill) onSendBill;
  final void Function(Map<String, dynamic> bill) onViewInvoice;
  final Future<void> Function(String orderId, double totalAmount)
  onRequestAdvance;
  final Future<void> Function(String orderId) onRequestFinalPayment;
  final Future<void> Function(Map<String, dynamic> bill) onPayAdvance;
  final Future<void> Function(Map<String, dynamic> bill) onPayFinal;

  const _BillCard({
    required this.bill,
    required this.isWholesalerSide,
    required this.onSendBill,
    required this.onViewInvoice,
    required this.onRequestAdvance,
    required this.onRequestFinalPayment,
    required this.onPayAdvance,
    required this.onPayFinal,
  });

  // ── helpers ────────────────────────────────────────────────────────────────
  String _str(dynamic v, [String fallback = '—']) =>
      v?.toString().trim().isNotEmpty == true ? v.toString().trim() : fallback;

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  bool _bool(dynamic v) => v == true;

  String _fmt(double v) => '₹${v.toStringAsFixed(2)}';

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String _statusLabel(String s) {
    switch (s) {
      case 'unpaid':
        return 'Unpaid';
      case 'advanceRequested':
        return 'Advance Requested';
      case 'advancePaid':
        return 'Advance Paid';
      case 'partial':
        return 'Partial';
      case 'paid':
        return 'Paid ✓';
      default:
        return s;
    }
  }

  Color _orderStatusColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'onTheWay':
        return Colors.blue;
      case 'processing':
        return Colors.indigo;
      case 'advancePending':
        return Colors.orange;
      case 'approved':
        return Colors.green.shade700;
      case 'pending':
        return Colors.amber.shade700;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final orderId = _str(bill['_id']);
    final productName = _str(bill['productName'], 'Product');
    final invoiceNumber = _str(bill['invoiceNumber'], '');
    final totalAmount = _num(bill['totalAmount']);
    final advanceAmount = _num(bill['advanceAmount']);
    final remainingAmount = _num(bill['remainingAmount']);
    final advancePct = _num(bill['advancePercentage']);

    final orderStatus = _str(bill['orderStatus'], 'pending');
    final paymentStatus = _str(bill['paymentStatus'], 'unpaid');

    final billSent = _bool(bill['billSentToRetailer']);
    final advanceRequested = _bool(bill['advanceRequested']);
    final advancePaid = _bool(bill['advancePaid']);
    final finalRequested = _bool(bill['finalPaymentRequested']);
    final fullPaid = _bool(bill['fullPaymentDone']);

    // counterparty info
    final party = _asMap(
      isWholesalerSide ? bill['retailerId'] : bill['wholesalerId'],
    );
    final partyName = _str(party?['shopName'] ?? party?['name'], 'Unknown');

    final quantity = bill['quantity'];
    final unit = _str(bill['unit'], 'pcs');
    final pricePerUnit = _num(bill['pricePerUnit']);
    final orderDate = DateTime.tryParse(
      (bill['createdAt'] ?? bill['billSentAt'] ?? '').toString(),
    );

    // Payment history
    final history = bill['paymentHistory'];
    final payments = history is List
        ? history
              .whereType<Map>()
              .map((payment) => Map<String, dynamic>.from(payment))
              .toList()
        : <Map<String, dynamic>>[];

    // ── what actions are available ─────────────────────────────────────────
    final canSendBill =
        isWholesalerSide &&
        !billSent &&
        (orderStatus == 'delivered' || orderStatus == 'completed');

    final canRequestAdvance =
        isWholesalerSide &&
        !advanceRequested &&
        !fullPaid &&
        orderStatus != 'rejected';

    final canRequestFinal =
        isWholesalerSide &&
        !finalRequested &&
        !fullPaid &&
        orderStatus == 'delivered';

    final canPayAdvance =
        !isWholesalerSide &&
        advanceRequested &&
        !advancePaid &&
        advanceAmount > 0;

    final canPayFinal =
        !isWholesalerSide && finalRequested && !fullPaid && remainingAmount > 0;
    final isDelivered =
        orderStatus == 'delivered' || orderStatus == 'completed';
    final canViewInvoice =
        isDelivered &&
        invoiceNumber.isNotEmpty &&
        (isWholesalerSide || billSent);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header gradient ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6D5DF6), Color(0xff8E7CFF)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quantity $unit • $partyName',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (invoiceNumber.isNotEmpty && isDelivered) ...[
                        const SizedBox(height: 4),
                        Text(
                          'INV: $invoiceNumber',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(paymentStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _orderStatusColor(
                          orderStatus,
                        ).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderStatus,
                        style: TextStyle(
                          color: _orderStatusColor(orderStatus),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── amount summary ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                _AmountTile(
                  label: 'Total',
                  value: _fmt(totalAmount),
                  color: Colors.black87,
                ),
                if (advancePct > 0) ...[
                  const SizedBox(width: 10),
                  _AmountTile(
                    label: 'Advance (${advancePct.toInt()}%)',
                    value: _fmt(advanceAmount),
                    color: Colors.orange,
                  ),
                ],
                if (remainingAmount > 0) ...[
                  const SizedBox(width: 10),
                  _AmountTile(
                    label: 'Remaining',
                    value: _fmt(remainingAmount),
                    color: Colors.red.shade600,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Unit price: ${_fmt(pricePerUnit)}${orderDate == null ? '' : '  •  ${DateFormat('d MMM yyyy').format(orderDate.toLocal())}'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),

          // ── payment history ──────────────────────────────────────────────
          if (payments.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment History',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...payments.map((p) => _PaymentHistoryRow(payment: p)),
                ],
              ),
            ),
          ],

          // ── action buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canViewInvoice)
                  _ActionBtn(
                    label: 'View Invoice',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.blue,
                    onTap: () => onViewInvoice(bill),
                  ),
                if (canSendBill)
                  _ActionBtn(
                    label: 'Send Bill',
                    icon: Icons.send_outlined,
                    color: const Color(0xff6D5DF6),
                    onTap: () => onSendBill(bill),
                  ),
                if (isWholesalerSide && !isDelivered)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Available after delivery',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                if (billSent && isWholesalerSide)
                  _ActionBtn(
                    label: 'Bill Sent ✓',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: null,
                  ),
                if (canRequestAdvance)
                  _ActionBtn(
                    label: 'Request Advance',
                    icon: Icons.request_quote_outlined,
                    color: Colors.orange,
                    onTap: () => onRequestAdvance(orderId, totalAmount),
                  ),
                if (advanceRequested && !advancePaid && isWholesalerSide)
                  _ActionBtn(
                    label: 'Advance Requested',
                    icon: Icons.hourglass_top_outlined,
                    color: Colors.blue,
                    onTap: null,
                  ),
                if (canRequestFinal)
                  _ActionBtn(
                    label: 'Request Final Payment',
                    icon: Icons.payments_outlined,
                    color: Colors.teal,
                    onTap: () => onRequestFinalPayment(orderId),
                  ),
                if (canPayAdvance)
                  _ActionBtn(
                    label: 'Pay Advance  ${_fmt(advanceAmount)}',
                    icon: Icons.payment_outlined,
                    color: Colors.orange,
                    onTap: () => onPayAdvance(bill),
                  ),
                if (canPayFinal)
                  _ActionBtn(
                    label: 'Pay Final  ${_fmt(remainingAmount)}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: () => onPayFinal(bill),
                  ),
                if (fullPaid)
                  _ActionBtn(
                    label: 'Fully Paid ✓',
                    icon: Icons.verified_outlined,
                    color: Colors.green,
                    onTap: null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _AmountTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AmountTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryRow extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentHistoryRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final type = payment['paymentType']?.toString() ?? '';
    final method = payment['paymentMethod']?.toString() ?? '';
    final amount = payment['amount'];
    final amtStr =
        '₹${(amount is num ? amount.toDouble() : double.tryParse(amount?.toString() ?? '') ?? 0).toStringAsFixed(2)}';
    final txnId = payment['transactionId']?.toString() ?? '';
    final isMock = payment['isMockPayment'] == true;
    final paidAt = DateTime.tryParse(payment['paidAt']?.toString() ?? '');
    final paymentLabel = type.isEmpty
        ? 'Payment'
        : '${type[0].toUpperCase()}${type.substring(1)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            type == 'advance'
                ? Icons.arrow_downward
                : Icons.check_circle_outline,
            size: 16,
            color: type == 'advance' ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$paymentLabel • $method • $amtStr${isMock ? ' (demo)' : ''}${paidAt == null ? '' : '\n${DateFormat('d MMM yyyy, h:mm a').format(paidAt.toLocal())}'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: txnId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction ID copied')),
              );
            },
            child: Text(
              txnId.length > 12 ? '${txnId.substring(0, 12)}…' : txnId,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xff6D5DF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade100 : color.withValues(alpha: 0.1),
          border: Border.all(
            color: disabled
                ? Colors.grey.shade300
                : color.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: disabled ? Colors.grey : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: disabled ? Colors.grey : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMO PAYMENT BOTTOM SHEET
// Simulates UPI / Card / NetBanking — generates a fake txn ID, sends it
// to the real backend endpoint. The backend validates mockPayment: true.
// ─────────────────────────────────────────────────────────────────────────────

class _DemoPaymentSheet extends StatefulWidget {
  final String orderId;
  final double amount;
  final String paymentType; // "advance" | "final"
  final Future<void> Function() onSuccess;
  final void Function(String msg) onError;

  const _DemoPaymentSheet({
    required this.orderId,
    required this.amount,
    required this.paymentType,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_DemoPaymentSheet> createState() => _DemoPaymentSheetState();
}

class _DemoPaymentSheetState extends State<_DemoPaymentSheet> {
  String _method = 'upi';
  bool _processing = false;
  bool _done = false;

  static String _generateTxnId() {
    final rnd = Random.secure();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String block(int length) =>
        List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'SKPAY-${block(7)}-XYZ${block(2)}';
  }

  Future<void> _pay() async {
    if (widget.amount <= 0) {
      widget.onError('The payment amount must be greater than zero.');
      return;
    }
    setState(() => _processing = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    final txnId = _generateTxnId();

    try {
      final data = await ApiClient.patch(
        widget.paymentType == 'advance'
            ? ApiConfig.payAdvance(widget.orderId)
            : ApiConfig.completePayment(widget.orderId),
        body: {
          'mockPayment': true,
          'transactionId': txnId,
          'paymentMethod': _method,
          'amount': widget.amount,
        },
      );
      if (data['success'] != true) {
        throw ApiException(data['message']?.toString() ?? 'Payment failed');
      }
      if (!mounted) return;
      setState(() {
        _processing = false;
        _done = true;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
      await widget.onSuccess();
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _processing = false);
        Navigator.pop(context);
      }
      widget.onError(error.message);
    } catch (error) {
      if (mounted) {
        setState(() => _processing = false);
        Navigator.pop(context);
      }
      widget.onError('Payment could not reach the local backend: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff6D5DF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Color(0xff6D5DF6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Khata Pay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Text(
                      'Demo Payment Gateway • TEST MODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '⚠️ Demo payment — no real money charged',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'No real money will be transferred. Do not enter real banking credentials.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 20),

          // amount chip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff6D5DF6), Color(0xff8E7CFF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '₹${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // method selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MethodTile(
                label: 'UPI',
                icon: '📱',
                selected: _method == 'upi',
                onTap: () => setState(() => _method = 'upi'),
              ),
              const SizedBox(width: 8),
              _MethodTile(
                label: 'Card',
                icon: '💳',
                selected: _method == 'card',
                onTap: () => setState(() => _method = 'card'),
              ),
              const SizedBox(width: 8),
              _MethodTile(
                label: 'NetBanking',
                icon: '🏦',
                selected: _method == 'netbanking',
                onTap: () => setState(() => _method = 'netbanking'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // pay button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_processing || _done) ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: _done ? Colors.green : const Color(0xff6D5DF6),
                foregroundColor: Colors.white,
                disabledBackgroundColor: _done
                    ? Colors.green
                    : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _processing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : _done
                  ? const Text(
                      '✅ Payment Successful!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : Text(
                      'Pay Now  ₹${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xff6D5DF6).withValues(alpha: 0.1)
                : Colors.grey.shade50,
            border: Border.all(
              color: selected ? const Color(0xff6D5DF6) : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xff6D5DF6) : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
