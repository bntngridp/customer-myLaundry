import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class CallMessage {
  final String type; // "CALL_OFFER", "CALL_RINGING", "CALL_ANSWER", "CALL_REJECT", "CALL_END", "ICE_CANDIDATE"
  final int callerUserId;
  final int targetUserId;
  final int orderId;
  final String callerName;
  final String sdp;
  final String reason;

  CallMessage({
    required this.type,
    required this.callerUserId,
    required this.targetUserId,
    required this.orderId,
    this.callerName = '',
    this.sdp = '',
    this.reason = '',
  });

  factory CallMessage.fromJson(Map<String, dynamic> json) {
    return CallMessage(
      type: json['type'] ?? '',
      callerUserId: json['caller_user_id'] ?? 0,
      targetUserId: json['target_user_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      callerName: json['caller_name'] ?? '',
      sdp: json['sdp'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'caller_user_id': callerUserId,
      'target_user_id': targetUserId,
      'order_id': orderId,
      'caller_name': callerName,
      'sdp': sdp,
      'reason': reason,
    };
  }
}

class CallSignalingService {
  static String get wsUrl {
    if (kIsWeb) {
      return 'ws://localhost:8083/api/ws/call';
    }
    try {
      if (Platform.isAndroid) {
        return 'ws://10.0.2.2:8083/api/ws/call';
      }
    } catch (_) {}
    return 'ws://localhost:8083/api/ws/call';
  }

  WebSocket? _socket;
  final StreamController<CallMessage> _messageController = StreamController<CallMessage>.broadcast();
  bool _isConnected = false;

  Stream<CallMessage> get onMessage => _messageController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String token) async {
    if (_isConnected) return;
    try {
      final uri = Uri.parse('$wsUrl?token=$token');
      _socket = await WebSocket.connect(uri.toString());
      _isConnected = true;

      _socket?.listen(
        (data) {
          try {
            final Map<String, dynamic> json = jsonDecode(data.toString());
            final msg = CallMessage.fromJson(json);
            _messageController.add(msg);
          } catch (_) {}
        },
        onError: (err) {
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (_) {
      _isConnected = false;
    }
  }

  void startCall({required int targetUserId, required int orderId, String callerName = 'Pelanggan'}) {
    if (!_isConnected || _socket == null) return;
    final msg = CallMessage(
      type: 'CALL_OFFER',
      callerUserId: 0,
      targetUserId: targetUserId,
      orderId: orderId,
      callerName: callerName,
    );
    _socket?.add(jsonEncode(msg.toJson()));
  }

  void answerCall({required int callerUserId, required int orderId}) {
    if (!_isConnected || _socket == null) return;
    final msg = CallMessage(
      type: 'CALL_ANSWER',
      callerUserId: 0,
      targetUserId: callerUserId,
      orderId: orderId,
    );
    _socket?.add(jsonEncode(msg.toJson()));
  }

  void rejectCall({required int callerUserId, required int orderId, String reason = 'busy'}) {
    if (!_isConnected || _socket == null) return;
    final msg = CallMessage(
      type: 'CALL_REJECT',
      callerUserId: 0,
      targetUserId: callerUserId,
      orderId: orderId,
      reason: reason,
    );
    _socket?.add(jsonEncode(msg.toJson()));
  }

  void endCall({required int targetUserId, required int orderId}) {
    if (!_isConnected || _socket == null) return;
    final msg = CallMessage(
      type: 'CALL_END',
      callerUserId: 0,
      targetUserId: targetUserId,
      orderId: orderId,
    );
    _socket?.add(jsonEncode(msg.toJson()));
  }

  void disconnect() {
    _isConnected = false;
    _socket?.close();
    _socket = null;
  }
}
