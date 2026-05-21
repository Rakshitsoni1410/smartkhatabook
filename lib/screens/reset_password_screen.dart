import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();

  final _confirmController = TextEditingController();

  bool _isLoading = false;

  bool _obscure1 = true;

  bool _obscure2 = true;

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

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();

    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showMessage("Please fill all fields", isError: true);

      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters", isError: true);

      return;
    }

    if (password != confirm) {
      _showMessage("Passwords do not match", isError: true);

      return;
    }

    final base = dotenv.env['BASE_URL'] ?? '';

    final uri = Uri.parse('$base/user/reset-password/${widget.token}');

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            uri,

            headers: {'Content-Type': 'application/json'},

            body: jsonEncode({"password": password}),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showMessage(data['message'] ?? "Password reset successful");

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showMessage(data['message'] ?? "Reset failed", isError: true);
      }
    } on TimeoutException {
      _showMessage("Server timeout", isError: true);
    } catch (e) {
      _showMessage("Something went wrong", isError: true);
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
        title: const Text("Reset Password"),

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
                  "Reset Password",

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Create a new password for your account.",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _passwordController,

                  obscureText: _obscure1,

                  decoration: InputDecoration(
                    labelText: "New Password",

                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscure1 = !_obscure1;
                        });
                      },

                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _confirmController,

                  obscureText: _obscure2,

                  decoration: InputDecoration(
                    labelText: "Confirm Password",

                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscure2 = !_obscure2;
                        });
                      },

                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,

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
                            "Reset Password",

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
