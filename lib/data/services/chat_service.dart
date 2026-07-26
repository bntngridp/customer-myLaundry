import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/chat_message.dart';

class ChatService {
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

  ChatService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ChatMessageModel>> getOrderChatMessages({
    required int orderId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/chats/order/$orderId');
    final response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => ChatMessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil pesan chat (${response.statusCode})');
    }
  }

  Future<ChatMessageModel> sendChatMessage({
    required int orderId,
    required String message,
    String imageUrl = '',
    String messageType = 'TEXT',
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/chats/order/$orderId');
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
        'image_url': imageUrl,
        'message_type': messageType,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return ChatMessageModel.fromJson(body['data'] ?? {});
    } else {
      try {
        final Map<String, dynamic> body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Gagal mengirim pesan chat');
      } catch (e) {
        throw Exception('Gagal mengirim pesan chat (${response.statusCode})');
      }
    }
  }
}
