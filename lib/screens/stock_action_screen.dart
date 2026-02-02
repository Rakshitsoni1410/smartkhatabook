import 'package:flutter/material.dart';

enum StockActionType { add, reduce }

class StockActionScreen extends StatefulWidget {
  final String productName;
  final int currentStock;

  const StockActionScreen({
    super.key,
    required this.productName,
    required this.currentStock,
  });

  @override
  State<StockActionScreen> createState() => _StockActionScreenState();
}

class _StockActionScreenState extends State<StockActionScreen> {
  StockActionType _actionType = StockActionType.add;
  String _reason = "Purchase";
  final TextEditingController _qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isAdd = _actionType == StockActionType.add;

    return Scaffold(
      appBar: AppBar(title: const Text("Stock Update")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 PRODUCT INFO
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(widget.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "Current Stock: ${widget.currentStock}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 ACTION TYPE
            Text("Action",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Add Stock"),
                    selected: isAdd,
                    selectedColor: Colors.green.shade100,
                    onSelected: (_) {
                      setState(() => _actionType = StockActionType.add);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Reduce Stock"),
                    selected: !isAdd,
                    selectedColor: Colors.red.shade100,
                    onSelected: (_) {
                      setState(() => _actionType = StockActionType.reduce);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 QUANTITY
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                prefixIcon: Icon(Icons.numbers),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 REASON
            DropdownButtonFormField(
              value: _reason,
              decoration: const InputDecoration(
                labelText: "Reason",
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: const [
                DropdownMenuItem(value: "Purchase", child: Text("Purchase")),
                DropdownMenuItem(value: "Sale", child: Text("Sale")),
                DropdownMenuItem(value: "Damage", child: Text("Damage")),
                DropdownMenuItem(value: "Return", child: Text("Return")),
                DropdownMenuItem(value: "Manual", child: Text("Manual Adjustment")),
              ],
              onChanged: (value) {
                setState(() => _reason = value!);
              },
            ),

            const Spacer(),

            // 🔹 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(isAdd ? Icons.add : Icons.remove),
                label: Text(isAdd ? "Add Stock" : "Reduce Stock"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdd ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  // UI only for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${isAdd ? "Added" : "Reduced"} stock successfully",
                      ),
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
