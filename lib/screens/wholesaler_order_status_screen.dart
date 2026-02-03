import 'package:flutter/material.dart';

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

  bool get isCompleted => _status == OrderStatus.delivered;

  String get statusText {
    switch (_status) {
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

  Color get statusColor {
    switch (_status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Status")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER INFO
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text(
                  "Order #1023",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Retailer: Patel Kirana Store"),
              ),
            ),

            const SizedBox(height: 16),

            /// CURRENT STATUS
            Card(
              color: statusColor.withOpacity(0.1),
              child: ListTile(
                title: const Text("Current Status"),
                trailing: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// STATUS DROPDOWN (WHOLESALER CONTROL)
            DropdownButtonFormField<OrderStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: "Update Order Status",
                prefixIcon: Icon(Icons.sync),
              ),
              items: const [
                DropdownMenuItem(
                  value: OrderStatus.ordered,
                  child: Text("Ordered"),
                ),
                DropdownMenuItem(
                  value: OrderStatus.onTheWay,
                  child: Text("On The Way"),
                ),
                DropdownMenuItem(
                  value: OrderStatus.onHold,
                  child: Text("On Hold"),
                ),
                DropdownMenuItem(
                  value: OrderStatus.delivered,
                  child: Text("Delivered"),
                ),
                DropdownMenuItem(
                  value: OrderStatus.cancelled,
                  child: Text("Cancelled"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            /// COMPLETION INFO
            Card(
              child: ListTile(
                leading: Icon(
                  isCompleted ? Icons.check_circle : Icons.hourglass_bottom,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(
                  isCompleted
                      ? "Order Completed"
                      : "Order Not Completed",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),

            const Spacer(),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Status"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCompleted
                            ? "Order marked as completed"
                            : "Order status updated",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
