import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: isError ? Colors.red : const Color(0xff2EA3F2),

        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Please enter email", isError: true);

      return;
    }

    final base = dotenv.env['BASE_URL'] ?? '';

    final uri = Uri.parse('$base/user/forgot-password');

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            uri,

            headers: {'Content-Type': 'application/json'},

            body: jsonEncode({"email": email}),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showMessage(data['message'] ?? "Reset link sent");
      } else {
        _showMessage(data['message'] ?? "Something went wrong", isError: true);
      }
    } on TimeoutException {
      _showMessage("Server timeout", isError: true);
    } catch (e) {
      _showMessage("Failed to send reset link", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xff0D1117)
          : const Color(0xffF4F7FB),

      appBar: AppBar(
        title: const Text("Forgot Password"),

        backgroundColor: const Color(0xff2EA3F2),

        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Container(
            width: 420,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: isDark ? const Color(0xff161B22) : Colors.white,

              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),

                  blurRadius: 24,
                ),
              ],
            ),

            child: Column(
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 70,
                  color: Color(0xff2EA3F2),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Enter your registered email to receive a reset link.",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _emailController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: "Email Address",

                    prefixIcon: const Icon(Icons.email_outlined),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2EA3F2),

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
