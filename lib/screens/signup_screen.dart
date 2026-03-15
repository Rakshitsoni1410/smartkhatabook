import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _shopController = TextEditingController();
  final _addressController = TextEditingController();

  String _role = "Retailer";
  String? _businessType;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _businessTypes = [
    "Stationery",
    "Grocery",
    "Medical",
    "Clothing",
    "Electronics",
    "Footwear",
    "Jewelry",
    "Hardware",
    "Furniture",
    "Cosmetic",
    "Book Store",
    "Mobile Shop",
    "Bakery",
    "Restaurant",
    "Gift Shop",
    "General Store",
    "Sports Shop",
    "Toy Shop",
    "Agriculture",
    "Other",
  ];

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xff2EA3F2),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final base = dotenv.env['BASE_URL'] ?? '';

    if (base.isEmpty) {
      _showMessage("BASE_URL is missing in .env file", isError: true);
      return;
    }

    final uri = Uri.parse('$base/user/register');

    setState(() => _isLoading = true);

    try {
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'role': _role,
              'email': _emailController.text.trim(),
              'shopName': _role == 'Customer' ? '' : _shopController.text.trim(),
              'businessType': _role == 'Customer' ? '' : (_businessType ?? ''),
              'address': _addressController.text.trim(),
              'password': _passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _showMessage(data['message'] ?? "Registration successful");
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.pop(context);
      } else {
        _showMessage(
          data['message'] ?? "Registration failed",
          isError: true,
        );
      }
    } on TimeoutException {
      _showMessage(
        "Server timeout. Please check your connection.",
        isError: true,
      );
    } catch (_) {
      _showMessage(
        "Something went wrong. Please try again.",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xff2EA3F2),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? const Color(0xff0D1117) : const Color(0xffF7FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xff2EA3F2),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCustomer = _role == "Customer";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xff0D1117) : const Color(0xffF4F7FB);
    final cardColor = isDark ? const Color(0xff161B22) : Colors.white;
    final titleColor = isDark ? const Color(0xff2EA3F2) : const Color(0xff1565C0);
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor =
        isDark ? const Color(0xff2EA3F2).withOpacity(.20) : const Color(0xff2EA3F2).withOpacity(.12);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(.18)
                                : Colors.black.withOpacity(.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: 110,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Register your profile and start managing your business easily.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(.18)
                                : Colors.black.withOpacity(.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "Full Name",
                              icon: Icons.person_outline,
                              isDark: isDark,
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? "Enter name" : null,
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "Mobile Number",
                              icon: Icons.phone_outlined,
                              isDark: isDark,
                            ).copyWith(counterText: ""),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Enter mobile number";
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) {
                                return "Enter valid 10-digit number";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              isDark: isDark,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Enter email";
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(v.trim())) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            value: _role,
                            dropdownColor:
                                isDark ? const Color(0xff161B22) : Colors.white,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "User Role",
                              icon: Icons.business_center_outlined,
                              isDark: isDark,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            items: const [
                              DropdownMenuItem(
                                value: "Wholesaler",
                                child: Text("Wholesaler"),
                              ),
                              DropdownMenuItem(
                                value: "Retailer",
                                child: Text("Retailer"),
                              ),
                              DropdownMenuItem(
                                value: "Customer",
                                child: Text("Customer"),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _role = v!;
                                if (_role == "Customer") {
                                  _businessType = null;
                                  _shopController.clear();
                                }
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          if (!isCustomer) ...[
                            TextFormField(
                              controller: _shopController,
                              style: TextStyle(color: textColor),
                              decoration: _inputDecoration(
                                label: "Shop / Business Name",
                                icon: Icons.storefront_outlined,
                                isDark: isDark,
                              ),
                              validator: (v) {
                                if (!isCustomer &&
                                    (v == null || v.trim().isEmpty)) {
                                  return "Enter shop name";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              value: _businessType,
                              dropdownColor:
                                  isDark ? const Color(0xff161B22) : Colors.white,
                              style: TextStyle(color: textColor),
                              decoration: _inputDecoration(
                                label: "Business Type",
                                icon: Icons.category_outlined,
                                isDark: isDark,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              items: _businessTypes
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _businessType = value;
                                });
                              },
                              validator: (value) {
                                if (!isCustomer &&
                                    (value == null || value.isEmpty)) {
                                  return "Select business type";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),
                          ],

                          TextFormField(
                            controller: _addressController,
                            maxLines: 2,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "Address",
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? "Enter address"
                                : null,
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "Password",
                              icon: Icons.lock_outline,
                              isDark: isDark,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: TextStyle(color: textColor),
                            decoration: _inputDecoration(
                              label: "Confirm Password",
                              icon: Icons.lock_outline,
                              isDark: isDark,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Confirm your password";
                              }
                              if (v != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xff2EA3F2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Create Account",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}