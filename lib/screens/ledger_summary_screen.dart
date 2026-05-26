import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class LedgerSummaryScreen extends StatefulWidget {
  final String userId;

  const LedgerSummaryScreen({super.key, required this.userId});

  @override
  State<LedgerSummaryScreen> createState() => _LedgerSummaryScreenState();
}

class _LedgerSummaryScreenState extends State<LedgerSummaryScreen> {
  List entries = [];

  bool isLoading = true;

  String filter = "All";

  final TextEditingController searchController = TextEditingController();

  // =========================
  // FETCH LEDGER
  // =========================

  @override
  void initState() {
    super.initState();

    fetchLedger();
  }

  Future<void> fetchLedger() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:4000/api/ledger/${widget.userId}"),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          entries = data["entries"];

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  // =========================
  // TOTAL CREDIT
  // =========================

  double get totalCredit {
    return entries
        .where((e) => e["type"] == "credit")
        .fold(0.0, (sum, e) => sum + double.parse(e["amount"].toString()));
  }

  // =========================
  // TOTAL DEBIT
  // =========================

  double get totalDebit {
    return entries
        .where((e) => e["type"] == "debit")
        .fold(0.0, (sum, e) => sum + double.parse(e["amount"].toString()));
  }

  // =========================
  // FILTERED ENTRIES
  // =========================

  List get filteredEntries {
    return entries.where((e) {
      final type = e["type"].toString().toLowerCase();

      final party = (e["partyId"]?["shopName"] ?? e["partyId"]?["name"] ?? "")
          .toString()
          .toLowerCase();

      final matchFilter = filter == "All" || type == filter.toLowerCase();

      final matchSearch = party.contains(searchController.text.toLowerCase());

      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalCredit - totalDebit;

    return Scaffold(
      appBar: AppBar(title: const Text("Ledger")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // =====================
                // SUMMARY
                // =====================
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          "Credit",
                          totalCredit,
                          Colors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryCard("Debit", totalDebit, Colors.red),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryCard("Balance", balance, Colors.blue),
                      ),
                    ],
                  ),
                ),

                // =====================
                // SEARCH
                // =====================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: TextField(
                    controller: searchController,

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      hintText: "Search party...",

                      prefixIcon: const Icon(Icons.search),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =====================
                // FILTERS
                // =====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    _filterButton("All"),

                    _filterButton("credit"),

                    _filterButton("debit"),
                  ],
                ),

                const SizedBox(height: 14),

                // =====================
                // LIST
                // =====================
                Expanded(
                  child: filteredEntries.isEmpty
                      ? const Center(child: Text("No ledger entries"))
                      : ListView.builder(
                          itemCount: filteredEntries.length,

                          itemBuilder: (context, i) {
                            final e = filteredEntries[i];

                            final isCredit = e["type"] == "credit";

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 14,

                                vertical: 6,
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCredit
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,

                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,

                                    color: isCredit ? Colors.green : Colors.red,
                                  ),
                                ),

                                title: Text(
                                  e["partyId"]?["shopName"] ??
                                      e["partyId"]?["name"] ??
                                      "Unknown",
                                ),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(e["note"] ?? ""),

                                    const SizedBox(height: 4),

                                    Text(
                                      e["source"] ?? "Order",

                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),

                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  crossAxisAlignment: CrossAxisAlignment.end,

                                  children: [
                                    Text(
                                      "${isCredit ? "+" : "-"} ₹${e["amount"]}",

                                      style: TextStyle(
                                        color: isCredit
                                            ? Colors.green
                                            : Colors.red,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      DateTime.parse(
                                        e["createdAt"],
                                      ).toLocal().toString().split(" ")[0],

                                      style: TextStyle(
                                        fontSize: 11,

                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // =========================
  // SUMMARY CARD
  // =========================

  Widget _summaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Text(title, style: TextStyle(color: color)),

          const SizedBox(height: 8),

          Text(
            "₹${amount.toStringAsFixed(0)}",

            style: TextStyle(
              color: color,

              fontWeight: FontWeight.bold,

              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // FILTER BUTTON
  // =========================

  Widget _filterButton(String value) {
    final active = filter == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? Colors.indigo : Colors.grey.shade300,
        ),

        onPressed: () {
          setState(() {
            filter = value;
          });
        },

        child: Text(value.toUpperCase()),
      ),
    );
  }
}
