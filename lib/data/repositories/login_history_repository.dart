import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/login_history_entry.dart';

class LoginHistoryRepository {
  static const int _maxEntries = 10;

  String _historyKey(int userId) => 'login_history_$userId';

  Future<List<LoginHistoryEntry>> getHistory({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getStringList(_historyKey(userId)) ?? const <String>[];

    return rawHistory
        .map((item) => LoginHistoryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordLogin({
    required int userId,
    required String accountLabel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory(userId: userId);

    final updatedHistory = <LoginHistoryEntry>[
      LoginHistoryEntry(
        deviceLabel: _buildDeviceLabel(accountLabel),
        loggedInAt: DateTime.now(),
        isCurrentSession: true,
      ),
      ...history.map((entry) => entry.copyWith(isCurrentSession: false)),
    ];

    await prefs.setStringList(
      _historyKey(userId),
      updatedHistory
          .take(_maxEntries)
          .map((entry) => jsonEncode(entry.toJson()))
          .toList(),
    );
  }

  Future<void> clearHistory({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey(userId));
  }

  String _buildDeviceLabel(String accountLabel) {
    return '$accountLabel • ${_platformLabel()}';
  }

  String _platformLabel() {
    if (kIsWeb) {
      return 'Web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }
}

