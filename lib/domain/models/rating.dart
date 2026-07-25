class RatingModel {
  final int id;
  final String orderId;
  final int customerId;
  final int courierId;
  final int branchId;
  final double courierScore;
  final double branchScore;
  final String tags;
  final String reviewText;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.courierId,
    required this.branchId,
    required this.courierScore,
    required this.branchScore,
    required this.tags,
    required this.reviewText,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as int? ?? 0,
      orderId: json['order_id'] as String? ?? '',
      customerId: json['customer_id'] as int? ?? 0,
      courierId: json['courier_id'] as int? ?? 0,
      branchId: json['branch_id'] as int? ?? 0,
      courierScore: (json['courier_score'] as num?)?.toDouble() ?? 5.0,
      branchScore: (json['branch_score'] as num?)?.toDouble() ?? 5.0,
      tags: json['tags'] as String? ?? '',
      reviewText: json['review_text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
