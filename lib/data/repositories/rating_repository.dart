import 'dart:convert';
import '../../domain/models/rating.dart';
import '../services/rating_service.dart';

class RatingRepository {
  final RatingService ratingService;

  RatingRepository({required this.ratingService});

  Future<RatingModel?> submitRating({
    required String orderId,
    required double courierScore,
    required double branchScore,
    required String tags,
    required String reviewText,
    required String token,
  }) async {
    final res = await ratingService.submitRating(
      orderId: orderId,
      courierScore: courierScore,
      branchScore: branchScore,
      tags: tags,
      reviewText: reviewText,
      token: token,
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = json.decode(res.body);
      if (body['data'] != null) {
        return RatingModel.fromJson(body['data']);
      }
    } else {
      final body = json.decode(res.body);
      throw Exception(body['message'] ?? 'Gagal mengirim rating');
    }
    return null;
  }

  Future<RatingModel?> getOrderRating(String orderId) async {
    try {
      final res = await ratingService.getOrderRating(orderId);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['data'] != null) {
          return RatingModel.fromJson(body['data']);
        }
      }
    } catch (_) {}
    return null;
  }
}
