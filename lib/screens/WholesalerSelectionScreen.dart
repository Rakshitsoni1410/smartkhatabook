import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'review_screen.dart';
import '../models/user_role.dart';

class WholesalerSelectionScreen extends StatefulWidget {
  final String businessType;
  final String shopName;

  const WholesalerSelectionScreen({
    super.key,
    required this.businessType,
    required this.shopName,
  });

  @override
  State<WholesalerSelectionScreen> createState() =>
      _WholesalerSelectionScreenState();
}

class _WholesalerSelectionScreenState extends State<WholesalerSelectionScreen> {
  List wholesalers = [];
  bool isLoading = true;

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchWholesalers();
  }

  Future<void> fetchWholesalers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/user/wholesalers/${widget.businessType}'),
    );

    final data = jsonDecode(res.body);

    setState(() {
      wholesalers = data['user'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Wholesaler")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: wholesalers.length,
              itemBuilder: (context, index) {
                final w = wholesalers[index];

                return ListTile(
                  title: Text(w["shopName"] ?? w["name"]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(
                          userId: w["_id"], // 🔥 wholesaler id
                          shopName: widget.shopName,
                          businessType: widget.businessType,
                          userRole: UserRole.retailer,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
