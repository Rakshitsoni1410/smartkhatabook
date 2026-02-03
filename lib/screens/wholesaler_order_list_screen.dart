import 'package:flutter/material.dart';
import 'wholesaler_order_status_screen.dart';

class WholesalerOrderListScreen extends StatelessWidget {
  const WholesalerOrderListScreen({super.key});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return Colors.blue;
      case OrderStatus.onTheWay:
        return Colors.orange;
      case OrderStatus.onHold:
        return Colors.amber;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.ordered:
        return "Ordered";
      case OrderStatus.onTheWay:
        return "On The Way";
      case OrderStatus.onHold:
        return "On Hold";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        "id": "#1021",
        "retailer": "Patel Kirana",
        "amount": 4200,
        "status": OrderStatus.ordered,
      },
      {
        "id": "#1022",
        "retailer": "Shree Mart",
        "amount": 7800,
        "status": OrderStatus.onTheWay,
      },
      {
        "id": "#1023",
        "retailer": "Ganesh Store",
        "amount": 3100,
        "status": OrderStatus.delivered,
      },
      {
        "id": "#1024",
        "retailer": "City Retail",
        "amount": 2500,
        "status": OrderStatus.onHold,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final OrderStatus status = order["status"] as OrderStatus;
          final bool completed = status == OrderStatus.delivered;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                completed ? Icons.check_circle : Icons.pending_actions,
                color: _statusColor(status),
              ),
              title: Text(
                "${order["id"]} • ${order["retailer"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Amount: ₹${order["amount"]}",
              ),
              trailing: Chip(
                label: Text(
                  _statusText(status),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _statusColor(status),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WholesalerOrderStatusScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
