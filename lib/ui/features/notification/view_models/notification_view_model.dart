import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../domain/models/notification.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository notificationRepository;
  final AuthRepository authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
  String _selectedFilter = 'Semua'; // 'Semua', 'Status Pesanan', 'Promo'

  NotificationViewModel({
    required this.notificationRepository,
    required this.authRepository,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _filteredNotifications();
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<NotificationModel> _filteredNotifications() {
    if (_selectedFilter == 'Status Pesanan') {
      return _notifications.where((n) => n.type == 'order_status').toList();
    } else if (_selectedFilter == 'Promo') {
      return _notifications.where((n) => n.type == 'promo').toList();
    }
    return _notifications;
  }

  Future<void> fetchNotifications() async {
    final token = authRepository.token;
    if (token == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await notificationRepository.getNotifications(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final token = authRepository.token;
    if (token == null) return;

    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      try {
        await notificationRepository.markAsRead(id, token);
      } catch (_) {}
    }
  }

  Future<void> markAllAsRead() async {
    final token = authRepository.token;
    if (token == null) return;

    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      await notificationRepository.markAllAsRead(token);
    } catch (_) {}
  }
}
