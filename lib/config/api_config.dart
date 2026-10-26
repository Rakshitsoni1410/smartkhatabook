// lib/config/api_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// SINGLE SOURCE OF TRUTH for the backend URL.
//
// Configure BASE_URL in .env with the API prefix:
// Android emulator  →  http://10.0.2.2:4000/api
// iOS simulator     →  http://127.0.0.1:4000/api
// Real device       →  http://<computer-lan-ip>:4000/api
//
// DO NOT hardcode the URL in any screen — always import this file.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final configuredUrl = dotenv.env['BASE_URL']?.trim();
    if (configuredUrl == null || configuredUrl.isEmpty) {
      return 'http://10.0.2.2:4000';
    }
    return configuredUrl
        .replaceFirst(RegExp(r'/+$'), '')
        .replaceFirst(RegExp(r'/api$'), '');
  }

  static String get apiBaseUrl => '$baseUrl/api';

  // ── Order routes ───────────────────────────────────────────────────────────
  static String createOrder() => '$apiBaseUrl/orders/create';
  static String orderRecommendations() => '$apiBaseUrl/orders/recommendations';
  static String retailerOrders(String id) => '$apiBaseUrl/orders/retailer/$id';
  static String wholesalerOrders(String id) =>
      '$apiBaseUrl/orders/wholesaler/$id';

  // ── Billing routes ─────────────────────────────────────────────────────────
  static String billingRetailer(String id) =>
      '$apiBaseUrl/orders/billing/retailer/$id';
  static String billingWholesaler(String id) =>
      '$apiBaseUrl/orders/billing/wholesaler/$id';

  // ── Payment routes ─────────────────────────────────────────────────────────
  static String payAdvance(String orderId) =>
      '$apiBaseUrl/orders/$orderId/pay-advance';
  static String completePayment(String orderId) =>
      '$apiBaseUrl/orders/$orderId/complete-payment';
  static String requestAdvance(String orderId) =>
      '$apiBaseUrl/orders/$orderId/request-advance';
  static String requestFinalPayment(String orderId) =>
      '$apiBaseUrl/orders/$orderId/request-final-payment';
  static String sendBill(String orderId) =>
      '$apiBaseUrl/orders/$orderId/send-bill';
  static String updateStatus(String orderId) =>
      '$apiBaseUrl/orders/$orderId/status';

  // ── Chatbot ────────────────────────────────────────────────────────────────
  static String chatbot() => '$apiBaseUrl/chatbot/chat';
}
