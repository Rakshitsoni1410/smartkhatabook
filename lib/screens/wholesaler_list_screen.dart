import 'package:flutter/material.dart';

import 'wholesaler_product_screen.dart';

class WholesalerListScreen extends StatelessWidget {
  final String retailerId;

  const WholesalerListScreen({super.key, required this.retailerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Products")),

      body: Center(
        child: ElevatedButton(
          child: const Text("View Products"),

          onPressed: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) => WholesalerProductScreen(retailerId: retailerId),
              ),
            );
          },
        ),
      ),
    );
  }
}
