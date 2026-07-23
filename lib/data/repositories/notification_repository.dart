import 'dart:convert';
import '../../domain/models/notification.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService notificationService;

  NotificationRepository({required this.notificationService});

  Future<List<NotificationModel>> getNotifications(String token) async {
    final response = await notificationService.getNotifications(token);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && (body['success'] == true || body['status'] == 'success')) {
      final List list = body['data'] ?? [];
      return list.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil notifikasi');
    }
  }

  Future<bool> markAsRead(int id, String token) async {
    final response = await notificationService.markAsRead(id, token);
    final body = jsonDecode(response.body);
    return response.statusCode == 200 && (body['success'] == true || body['status'] == 'success');
  }

  Future<bool> markAllAsRead(String token) async {
    final response = await notificationService.markAllAsRead(token);
    final body = jsonDecode(response.body);
    return response.statusCode == 200 && (body['success'] == true || body['status'] == 'success');
  }
}
