import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8083/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8083/api';
      }
    } catch (_) {
      // Platform check can fail on web
    }
    return 'http://localhost:8083/api';
  }

  final http.Client _client;

  PaymentService({http.Client? client}) : _client = client ?? http.Client();

  /// Request Midtrans Snap token for digital payment methods (QRIS, Bank Transfer, E-Wallet)
  Future<Map<String, dynamic>> getSnapToken({
    required int orderId,
    required String paymentType,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/payments/snap-token');
    final res = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'order_id': orderId,
        'payment_type': paymentType,
      }),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal membuat token pembayaran Midtrans');
    }
    return body['data'] as Map<String, dynamic>;
  }

  /// Confirm COD (Cash on Delivery) payment method for an order
  Future<void> confirmCashPayment({
    required int orderId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/payments/cash');
    final res = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'order_id': orderId}),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Gagal mengkonfirmasi pembayaran tunai');
    }
  }
}
