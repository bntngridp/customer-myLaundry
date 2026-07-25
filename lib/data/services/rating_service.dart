import 'dart:convert';
import 'package:http/http.dart' as http;

class RatingService {
  static const String baseUrl = 'http://localhost:8083/api';

  Future<http.Response> submitRating({
    required String orderId,
    required double courierScore,
    required double branchScore,
    required String tags,
    required String reviewText,
    required String token,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'order_id': orderId,
        'courier_score': courierScore,
        'branch_score': branchScore,
        'tags': tags,
        'review_text': reviewText,
      }),
    );
  }

  Future<http.Response> getOrderRating(String orderId) async {
    return await http.get(Uri.parse('$baseUrl/ratings/order/$orderId'));
  }
}
