import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8085/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8085/api';
      }
    } catch (_) {
      // Platform check can fail in web unit tests
    }
    return 'http://localhost:8085/api';
  }

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    return await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  Future<http.Response> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    return await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': password,
        'role': 'customer',
      }),
    );
  }

  Future<http.Response> getMe(String token) async {
    final url = Uri.parse('$baseUrl/auth/me');
    return await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    return await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Future<http.Response> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    return await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
  }

  Future<http.Response> resetPassword(String email, String otp, String password) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    return await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
        'confirm_password': password,
      }),
    );
  }
}
