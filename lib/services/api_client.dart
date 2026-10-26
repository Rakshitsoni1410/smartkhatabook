import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) => _request('POST', path, body: body);

  static Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) => _request('PATCH', path, body: body);

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['token'] = token;
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final uri = Uri.parse(
        path.startsWith('http') ? path : '${ApiConfig.apiBaseUrl}$path',
      );
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final response = await http.Response.fromStream(
        await request.send().timeout(const Duration(seconds: 20)),
      );
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      final data = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{'data': decoded};

      if (response.statusCode == 401) {
        await _clearSession();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        throw ApiException(
          data['message']?.toString() ??
              'Your session has expired. Please login again.',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          data['message']?.toString() ??
              'Request failed (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Unable to reach the local backend: $error');
    }
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
