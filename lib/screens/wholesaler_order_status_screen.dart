import 'package:flutter/material.dart';
import '../services/ledger_service.dart';

enum OrderStatus {
  ordered,
  onTheWay,
  onHold,
  delivered,
  cancelled,
}

class WholesalerOrderStatusScreen extends StatefulWidget {
  const WholesalerOrderStatusScreen({super.key});

  @override
  State<WholesalerOrderStatusScreen> createState() =>
      _WholesalerOrderStatusScreenState();
}

class _WholesalerOrderStatusScreenState
    extends State<WholesalerOrderStatusScreen> {
  OrderStatus _status = OrderStatus.ordered;

  final int orderAmount = 5000;
  final String retailerName = "Patel Retail Store";
  final String orderId = "#ORD102";

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return Colors.blue;
      case OrderStatus.onTheWay:
        return Colors.orange;
      case OrderStatus.onHold:
        return Colors.grey;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusText(OrderStatus status) {
    return status
        .toString()
        .split('.')
        .last
        .replaceAllMapped(
      RegExp(r'([A-Z])'),
          (m) => ' ${m[1]}',
    )
        .trim();
  }

  void _updateStatus(OrderStatus status) {
    setState(() => _status = status);

    if (status == OrderStatus.delivered) {
      LedgerService.addEntry(
        party: retailerName,
        type: "Debit",
        amount: orderAmount,
        source: "Order",
      );

      LedgerService.addEntry(
        party: "Wholesaler",
        type: "Credit",
        amount: orderAmount,
        source: "Order",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 ORDER CARD
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
                      retailerName,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "₹$orderAmount",
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

            /// 🔹 STATUS UPDATE TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Update Order Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔹 STATUS BUTTONS
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: OrderStatus.values.map((status) {
                final isSelected = _status == status;

                return ChoiceChip(
                  label: Text(_statusText(status)),
                  selected: isSelected,
                  selectedColor: _statusColor(status),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) => _updateStatus(status),
                );
              }).toList(),
            ),

            const Spacer(),

            /// 🔹 ACTION BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Save Status"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order status updated successfully"),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
