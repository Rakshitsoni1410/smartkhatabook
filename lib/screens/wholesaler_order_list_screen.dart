import 'package:flutter/material.dart';
import 'wholesaler_order_status_screen.dart';

enum OrderStatus { ordered, onTheWay, onHold, delivered, cancelled }

class WholesalerOrderListScreen extends StatefulWidget {
  const WholesalerOrderListScreen({super.key});

  @override
  State<WholesalerOrderListScreen> createState() =>
      _WholesalerOrderListScreenState();
}

class _WholesalerOrderListScreenState
    extends State<WholesalerOrderListScreen> {
  String _filter = "All";

  final List<Map<String, dynamic>> orders = [
    {
      "id": "#ORD101",
      "retailer": "Patel Store",
      "amount": 5000,
      "status": OrderStatus.delivered,
    },
    {
      "id": "#ORD102",
      "retailer": "Shah Mart",
      "amount": 3200,
      "status": OrderStatus.onTheWay,
    },
    {
      "id": "#ORD103",
      "retailer": "A-One Retail",
      "amount": 4100,
      "status": OrderStatus.ordered,
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    if (_filter == "Completed") {
      return orders
          .where((o) => o["status"] == OrderStatus.delivered)
          .toList();
    }
    if (_filter == "Pending") {
      return orders
          .where((o) => o["status"] != OrderStatus.delivered)
          .toList();
    }
    return orders;
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.onTheWay:
        return Colors.orange;
      case OrderStatus.onHold:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _statusText(OrderStatus status) =>
      status.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        actions: [
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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final o = filteredOrders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WholesalerOrderStatusScreen(),
                  ),
                );
              },
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 TOP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o["retailer"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${o["amount"]}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 🔹 ORDER ID + STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o["id"],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Chip(
                          label: Text(
                            _statusText(o["status"]),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _statusColor(o["status"]),
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
    );
  }
}
