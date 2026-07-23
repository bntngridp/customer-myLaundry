import 'package:intl/intl.dart';

class LoginHistoryEntry {
  final String deviceLabel;
  final DateTime loggedInAt;
  final bool isCurrentSession;

  const LoginHistoryEntry({
    required this.deviceLabel,
    required this.loggedInAt,
    required this.isCurrentSession,
  });

  factory LoginHistoryEntry.fromJson(Map<String, dynamic> json) {
    return LoginHistoryEntry(
      deviceLabel: json['device_label'] as String? ?? '',
      loggedInAt: DateTime.tryParse(json['logged_in_at'] as String? ?? '') ?? DateTime.now(),
      isCurrentSession: json['is_current_session'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_label': deviceLabel,
      'logged_in_at': loggedInAt.toIso8601String(),
      'is_current_session': isCurrentSession,
    };
  }

  LoginHistoryEntry copyWith({
    String? deviceLabel,
    DateTime? loggedInAt,
    bool? isCurrentSession,
  }) {
    return LoginHistoryEntry(
      deviceLabel: deviceLabel ?? this.deviceLabel,
      loggedInAt: loggedInAt ?? this.loggedInAt,
      isCurrentSession: isCurrentSession ?? this.isCurrentSession,
    );
  }

  String get statusLabel {
    if (isCurrentSession) {
      return 'Aktif sekarang';
    }

    return DateFormat('dd/MM/yyyy • HH:mm').format(loggedInAt);
  }
}

