import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ─── Constants ───────────────────────────────────────────────────────────────

const _kAccent = Color(0xff2EA3F2);
const _kDarkBg = Color(0xff0D1117);
const _kDarkCard = Color(0xff161B22);
const _kLightBg = Color(0xffF4F7FB);
const _kLightTitle = Color(0xff1565C0);
const _kFieldBgDark = Color(0xff0D1117);
const _kFieldBgLight = Color(0xffF7FAFC);

const _kRoles = ['Wholesaler', 'Retailer', 'Customer'];

const _kBusinessTypes = [
  'Stationery', 'Grocery', 'Medical', 'Clothing', 'Electronics',
  'Footwear', 'Jewelry', 'Hardware', 'Furniture', 'Cosmetic',
  'Book Store', 'Mobile Shop', 'Bakery', 'Restaurant', 'Gift Shop',
  'General Store', 'Sports Shop', 'Toy Shop', 'Agriculture', 'Other',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

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

  String _role = 'Retailer';
  String? _businessType;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isCustomer => _role == 'Customer';

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

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

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: isError ? Colors.red.shade600 : _kAccent,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _onRoleChanged(String? value) {
    if (value == null) return;
    setState(() {
      _role = value;
      if (_isCustomer) {
        _businessType = null;
        _shopController.clear();
      }
    });
  }

  // ─── Register logic ────────────────────────────────────────────────────────

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _showMessage('BASE_URL is missing in .env file', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'role': _role,
              'email': _emailController.text.trim(),
              'shopName': _isCustomer ? '' : _shopController.text.trim(),
              'businessType': _isCustomer ? '' : (_businessType ?? ''),
              'address': _addressController.text.trim(),
              'password': _passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage(data['message']?.toString() ?? 'Registration successful');
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.pop(context);
      } else {
        _showMessage(
          data['message']?.toString() ?? 'Registration failed',
          isError: true,
        );
      }
    } on TimeoutException {
      _showMessage('Server timeout. Please check your connection.',
          isError: true);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build helpers ─────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide:
          BorderSide(color: isDark ? Colors.white12 : Colors.black12),
    );

    return InputDecoration(
      labelText: label,
      labelStyle:
          TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      prefixIcon: Icon(icon, color: _kAccent),
      suffixIcon: suffixIcon,
      counterText: '',
      filled: true,
      fillColor: isDark ? _kFieldBgDark : _kFieldBgLight,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  /// Reusable password toggle suffix icon.
  Widget _visibilityIcon(bool obscure, VoidCallback onTap, bool isDark) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  BoxDecoration _cardDecoration(Color cardColor, Color borderColor,
      bool isDark) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? .18 : .06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // ─── Field widgets ─────────────────────────────────────────────────────────

  Widget _buildNameField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'Full Name', icon: Icons.person_outline, isDark: isDark),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter name' : null,
    );
  }

  Widget _buildPhoneField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'Mobile Number',
          icon: Icons.phone_outlined,
          isDark: isDark),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter mobile number';
        if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) {
          return 'Enter valid 10-digit number';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'Email Address',
          icon: Icons.email_outlined,
          isDark: isDark),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter email';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildRoleDropdown(bool isDark, Color textColor) {
    return DropdownButtonFormField<String>(
      value: _role,
      dropdownColor: isDark ? _kDarkCard : Colors.white,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'User Role',
          icon: Icons.business_center_outlined,
          isDark: isDark),
      borderRadius: BorderRadius.circular(18),
      items: _kRoles
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: _onRoleChanged,
    );
  }

  Widget _buildShopField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _shopController,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'Shop / Business Name',
          icon: Icons.storefront_outlined,
          isDark: isDark),
      validator: (v) => (!_isCustomer && (v == null || v.trim().isEmpty))
          ? 'Enter shop name'
          : null,
    );
  }

  Widget _buildBusinessTypeDropdown(bool isDark, Color textColor) {
    return DropdownButtonFormField<String>(
      value: _businessType,
      dropdownColor: isDark ? _kDarkCard : Colors.white,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'Business Type',
          icon: Icons.category_outlined,
          isDark: isDark),
      borderRadius: BorderRadius.circular(18),
      items: _kBusinessTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _businessType = v),
      validator: (v) =>
          (!_isCustomer && (v == null || v.isEmpty))
              ? 'Select business type'
              : null,
    );
  }

  Widget _buildAddressField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _addressController,
      maxLines: 2,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
          label: 'Address',
          icon: Icons.location_on_outlined,
          isDark: isDark),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter address' : null,
    );
  }

  Widget _buildPasswordField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
        label: 'Password',
        icon: Icons.lock_outline,
        isDark: isDark,
        suffixIcon: _visibilityIcon(
          _obscurePassword,
          () => setState(() => _obscurePassword = !_obscurePassword),
          isDark,
        ),
      ),
      validator: (v) => (v == null || v.trim().length < 6)
          ? 'Password must be at least 6 characters'
          : null,
    );
  }

  Widget _buildConfirmPasswordField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(
        label: 'Confirm Password',
        icon: Icons.lock_outline,
        isDark: isDark,
        suffixIcon: _visibilityIcon(
          _obscureConfirmPassword,
          () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          isDark,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Confirm your password';
        if (v != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _kAccent,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Create Account',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? _kDarkBg : _kLightBg;
    final cardColor = isDark ? _kDarkCard : Colors.white;
    final titleColor = isDark ? _kAccent : _kLightTitle;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = _kAccent.withOpacity(isDark ? .20 : .12);
    final cardDeco = _cardDecoration(cardColor, borderColor, isDark);

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
                    // ── Back button ─────────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: textColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ── Header card ─────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: cardDeco,
                      child: Column(
                        children: [
                          Image.asset('assets/images/logo.png', height: 110),
                          const SizedBox(height: 14),
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Register your profile and start managing'
                            ' your business easily.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 14, color: subtitleColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Form card ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: cardDeco,
                      child: Column(
                        children: [
                          _buildNameField(isDark, textColor),
                          const SizedBox(height: 14),
                          _buildPhoneField(isDark, textColor),
                          const SizedBox(height: 14),
                          _buildEmailField(isDark, textColor),
                          const SizedBox(height: 14),
                          _buildRoleDropdown(isDark, textColor),
                          const SizedBox(height: 14),
                          if (!_isCustomer) ...[
                            _buildShopField(isDark, textColor),
                            const SizedBox(height: 14),
                            _buildBusinessTypeDropdown(isDark, textColor),
                            const SizedBox(height: 14),
                          ],
                          _buildAddressField(isDark, textColor),
                          const SizedBox(height: 14),
                          _buildPasswordField(isDark, textColor),
                          const SizedBox(height: 14),
                          _buildConfirmPasswordField(isDark, textColor),
                          const SizedBox(height: 24),
                          _buildSubmitButton(),
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