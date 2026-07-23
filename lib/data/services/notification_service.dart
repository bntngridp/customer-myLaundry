import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8083/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8083/api';
      }
    } catch (_) {}
    return 'http://localhost:8083/api';
  }

  final http.Client _client;

  NotificationService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> getNotifications(String token) async {
    final url = Uri.parse('$baseUrl/notifications/');
    return await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> markAsRead(int id, String token) async {
    final url = Uri.parse('$baseUrl/notifications/$id/read');
    return await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> markAllAsRead(String token) async {
    final url = Uri.parse('$baseUrl/notifications/read-all');
    return await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
