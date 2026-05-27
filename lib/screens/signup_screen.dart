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
  'Stationery',
  'Grocery',
  'Medical',
  'Clothing',
  'Electronics',
  'Footwear',
  'Jewelry',
  'Hardware',
  'Furniture',
  'Cosmetic',
  'Book Store',
  'Mobile Shop',
  'Bakery',
  'Restaurant',
  'Gift Shop',
  'General Store',
  'Sports Shop',
  'Toy Shop',
  'Agriculture',
  'Other',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool get _isCustomer => _role == 'Customer';

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
      _showMessage(
        'Server timeout. Please check your connection.',
        isError: true,
      );
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
    final radius = BorderRadius.circular(12);
    final baseBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.10),
      ),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white54 : Colors.black45,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _kAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _kAccent, size: 18),
      ),
      suffixIcon: suffixIcon,
      counterText: '',
      filled: true,
      fillColor: isDark ? _kFieldBgDark : _kFieldBgLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: _kAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
    );
  }

  Widget _visibilityIcon(bool obscure, VoidCallback onTap, bool isDark) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: isDark ? Colors.white38 : Colors.black38,
        size: 20,
      ),
    );
  }

  // ─── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: _kAccent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Field widgets ─────────────────────────────────────────────────────────

  Widget _buildNameField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Full Name',
        icon: Icons.person_outline_rounded,
        isDark: isDark,
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
    );
  }

  Widget _buildPhoneField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Mobile Number',
        icon: Icons.phone_outlined,
        isDark: isDark,
      ),
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
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Email Address',
        icon: Icons.email_outlined,
        isDark: isDark,
      ),
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
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
      decoration: _inputDecoration(
        label: 'User Role',
        icon: Icons.badge_outlined,
        isDark: isDark,
      ),
      borderRadius: BorderRadius.circular(14),
      items: _kRoles
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: _onRoleChanged,
    );
  }

  Widget _buildShopField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _shopController,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Shop / Business Name',
        icon: Icons.storefront_outlined,
        isDark: isDark,
      ),
      validator: (v) => (!_isCustomer && (v == null || v.trim().isEmpty))
          ? 'Enter shop name'
          : null,
    );
  }

  Widget _buildBusinessTypeDropdown(bool isDark, Color textColor) {
    return DropdownButtonFormField<String>(
      value: _businessType,
      dropdownColor: isDark ? _kDarkCard : Colors.white,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
      decoration: _inputDecoration(
        label: 'Business Type',
        icon: Icons.category_outlined,
        isDark: isDark,
      ),
      borderRadius: BorderRadius.circular(14),
      items: _kBusinessTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _businessType = v),
      validator: (v) => (!_isCustomer && (v == null || v.isEmpty))
          ? 'Select business type'
          : null,
    );
  }

  Widget _buildAddressField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _addressController,
      maxLines: 2,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Address',
        icon: Icons.location_on_outlined,
        isDark: isDark,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter address' : null,
    );
  }

  Widget _buildPasswordField(bool isDark, Color textColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Password',
        icon: Icons.lock_outline_rounded,
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
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: 'Confirm Password',
        icon: Icons.lock_outline_rounded,
        isDark: isDark,
        suffixIcon: _visibilityIcon(
          _obscureConfirmPassword,
          () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
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
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _kAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kAccent.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  key: ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Divider widget ────────────────────────────────────────────────────────

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? Colors.white10 : Colors.black12,
              thickness: 1,
            ),
          ),
        ],
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
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // ── Back button ────────────────────────────────────
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: textColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Header ─────────────────────────────────────────
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _kAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 38,
                                width: 38,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fill in your details to get started',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Personal Info Section ──────────────────────────
                        _sectionLabel('PERSONAL INFO', isDark),
                        _buildCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          child: Column(
                            children: [
                              _buildNameField(isDark, textColor),
                              const SizedBox(height: 12),
                              _buildPhoneField(isDark, textColor),
                              const SizedBox(height: 12),
                              _buildEmailField(isDark, textColor),
                              const SizedBox(height: 12),
                              _buildRoleDropdown(isDark, textColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Business Info Section (conditional) ───────────
                        if (!_isCustomer) ...[
                          _sectionLabel('BUSINESS INFO', isDark),
                          _buildCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            child: Column(
                              children: [
                                _buildShopField(isDark, textColor),
                                const SizedBox(height: 12),
                                _buildBusinessTypeDropdown(isDark, textColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Location Section ───────────────────────────────
                        _sectionLabel('LOCATION', isDark),
                        _buildCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          child: _buildAddressField(isDark, textColor),
                        ),
                        const SizedBox(height: 20),

                        // ── Security Section ───────────────────────────────
                        _sectionLabel('SECURITY', isDark),
                        _buildCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          child: Column(
                            children: [
                              _buildPasswordField(isDark, textColor),
                              const SizedBox(height: 12),
                              _buildConfirmPasswordField(isDark, textColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Submit ─────────────────────────────────────────
                        _buildSubmitButton(),
                        const SizedBox(height: 8),

                        // ── Sign in link ───────────────────────────────────
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 20),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign in',
                                      style: const TextStyle(
                                        color: _kAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Card wrapper ──────────────────────────────────────────────────────────

  Widget _buildCard({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
