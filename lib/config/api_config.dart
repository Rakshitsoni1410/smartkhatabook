// lib/config/api_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// SINGLE SOURCE OF TRUTH for the backend URL.
//
// Android emulator  →  http://10.0.2.2:4000
// iOS simulator     →  http://localhost:4000
// Real device       →  replace with your machine's LAN IP, e.g. http://192.168.1.5:4000
//
// DO NOT hardcode the URL in any screen — always import this file.
// ─────────────────────────────────────────────────────────────────────────────

class ApiConfig {
  // ── Change only this one line when switching environments ──────────────────
  static const String baseUrl = 'http://10.0.2.2:4000';

  // ── Order routes ───────────────────────────────────────────────────────────
  static String createOrder()               => '$baseUrl/api/orders/create';
  static String orderRecommendations()      => '$baseUrl/api/orders/recommendations';
  static String retailerOrders(String id)   => '$baseUrl/api/orders/retailer/$id';
  static String wholesalerOrders(String id) => '$baseUrl/api/orders/wholesaler/$id';

  // ── Billing routes ─────────────────────────────────────────────────────────
  static String billingRetailer(String id)   => '$baseUrl/api/orders/billing/retailer/$id';
  static String billingWholesaler(String id) => '$baseUrl/api/orders/billing/wholesaler/$id';

  // ── Payment routes ─────────────────────────────────────────────────────────
  static String payAdvance(String orderId)          => '$baseUrl/api/orders/$orderId/pay-advance';
  static String completePayment(String orderId)     => '$baseUrl/api/orders/$orderId/complete-payment';
  static String requestAdvance(String orderId)      => '$baseUrl/api/orders/$orderId/request-advance';
  static String requestFinalPayment(String orderId) => '$baseUrl/api/orders/$orderId/request-final-payment';
  static String sendBill(String orderId)            => '$baseUrl/api/orders/$orderId/send-bill';
  static String updateStatus(String orderId)        => '$baseUrl/api/orders/$orderId/status';

  // ── Chatbot ────────────────────────────────────────────────────────────────
  static String chatbot() => '$baseUrl/api/chatbot/chat';
}