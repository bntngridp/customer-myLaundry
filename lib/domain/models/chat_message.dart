class ChatMessageModel {
  final int id;
  final int orderId;
  final int senderId;
  final String senderRole; // "courier", "customer", "admin"
  final String message;
  final String imageUrl;
  final String messageType; // "TEXT", "DELIVERY_PROOF"
  final DateTime sentAt;
  final String? senderUsername;

  ChatMessageModel({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.imageUrl,
    required this.messageType,
    required this.sentAt,
    this.senderUsername,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String rawDate = json['sent_at'] ?? json['SentAt'] ?? json['CreatedAt'] ?? '';
    DateTime dateParsed;
    try {
      dateParsed = DateTime.parse(rawDate);
    } catch (_) {
      dateParsed = DateTime.now();
    }

    String? username;
    if (json['sender'] != null && json['sender'] is Map) {
      username = json['sender']['username'];
    }

    return ChatMessageModel(
      id: json['ID'] ?? json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderRole: json['sender_role'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['image_url'] ?? '',
      messageType: json['message_type'] ?? 'TEXT',
      sentAt: dateParsed,
      senderUsername: username,
    );
  }
}
