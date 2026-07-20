import 'dart:convert';
import '../../domain/models/order.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService orderService;

  OrderRepository({required this.orderService});

  Future<List<OrderModel>> getOrders(String token) async {
    final response = await orderService.getOrders(token);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      final msg = body['message'] ?? 'Gagal mengambil data pesanan';
      throw Exception(msg);
    }
  }

  Future<OrderModel> createOrder({
    required int serviceId,
    required int addressId,
    required String token,
  }) async {
    final response = await orderService.createOrder(
      serviceId: serviceId,
      addressId: addressId,
      token: token,
    );
    final body = jsonDecode(response.body);

    if (response.statusCode == 201 || (response.statusCode == 200 && body['success'] == true)) {
      return OrderModel.fromJson(body['data']);
    } else {
      final msg = body['message'] ?? 'Gagal membuat pesanan baru';
      throw Exception(msg);
    }
  }

  Future<List<ServiceModel>> getServices(String token) async {
    final response = await orderService.getServices(token);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      final msg = body['message'] ?? 'Gagal mengambil data layanan';
      throw Exception(msg);
    }
  }
}
