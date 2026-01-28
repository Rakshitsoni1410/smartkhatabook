import 'package:flutter/material.dart';

class LedgerSummaryScreen extends StatelessWidget {
  const LedgerSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔹 ICON
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_rounded,
                size: 60,
                color: primary,
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 TITLE
            Text(
              "Ledger Overview",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 SUBTEXT
            Text(
              "Track payments, credits & balances",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 BUTTON
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_chart),
              label: const Text("View Transactions"),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
