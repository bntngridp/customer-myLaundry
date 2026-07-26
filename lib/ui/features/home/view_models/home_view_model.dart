import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/branch_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../data/services/promo_service.dart';
import '../../../../domain/models/order.dart';
import '../../../../domain/models/branch.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final OrderRepository orderRepository;
  final BranchRepository? branchRepository;

  bool _isLoading = false;
  String? _errorMessage;
  OrderModel? _activeOrder;

  List<BranchModel> _branches = [
    BranchModel(
      id: 1,
      name: 'myLaundry Bojongsoang',
      address: 'Jl. Raya Bojongsoang No. 12',
      latitude: -6.9740,
      longitude: 107.6303,
      distanceKm: 0.2,
      rating: 4.8,
      imageUrl: 'https://picsum.photos/seed/laundry1/300/200',
    ),
    BranchModel(
      id: 2,
      name: 'myLaundry Sukapura',
      address: 'Jl. Sukapura Raya No. 45',
      latitude: -6.9775,
      longitude: 107.6335,
      distanceKm: 0.9,
      rating: 4.6,
      imageUrl: 'https://picsum.photos/seed/laundry2/300/200',
    ),
    BranchModel(
      id: 3,
      name: 'myLaundry Kiaracondong',
      address: 'Jl. Stasiun Kiaracondong No. 8',
      latitude: -6.9400,
      longitude: 107.6450,
      distanceKm: 2.3,
      rating: 4.7,
      imageUrl: 'https://picsum.photos/seed/laundry3/300/200',
    ),
  ];

  List<Map<String, String>> _promos = [];

  HomeViewModel({
    required this.authRepository,
    required this.orderRepository,
    this.branchRepository,
  }) {
    fetchPromos();
    fetchBranches();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderModel? get activeOrder => _activeOrder;
  List<BranchModel> get branches => _branches;
  List<Map<String, String>> get promos => _promos;

  Future<void> fetchBranches() async {
    if (branchRepository == null) return;
    try {
      final loc = await LocationService.getCurrentLocation();
      final double? lat = loc['lat'] as double?;
      final double? lng = loc['lng'] as double?;

      final list = await branchRepository!.getBranches(lat: lat, lng: lng);
      if (list.isNotEmpty) {
        _branches = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchPromos() async {
    try {
      final res = await PromoService().getPromos();
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'];
          _promos = list.map<Map<String, String>>((item) {
            final String code = item['code'] ?? '';
            final String title = item['title'] ?? 'Promo Diskon Special';
            final String subtitle = item['subtitle'] ?? 'Diskon menarik untuk cucianmu';
            return {
              'code': code,
              'title': title,
              'subtitle': subtitle,
            };
          }).toList();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> checkActiveOrder() async {
    final token = authRepository.token;
    if (token == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    fetchPromos();

    try {
      final orders = await orderRepository.getOrders(token);
      final activeList = orders.where((o) {
        final status = o.status.toLowerCase();
        return status != 'completed' && status != 'cancelled';
      }).toList();

      if (activeList.isNotEmpty) {
        activeList.sort((a, b) => b.id.compareTo(a.id));
        _activeOrder = activeList.first;
      } else {
        _activeOrder = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _activeOrder = null;
      notifyListeners();
    }
  }

  Map<String, dynamic> getOrderStatusDetails() {
    if (_activeOrder == null) {
      return {
        'text': 'Yuk gunakan promo #BersihTanpaPusing',
        'color': const Color(0xFF0007B0),
      };
    }

    final status = _activeOrder!.status.toLowerCase();
    switch (status) {
      case 'pending':
        return {
          'text': 'Sedang mencari kurir',
          'color': const Color(0xFFEAB308),
        };
      case 'accepted':
        return {
          'text': 'Kurir dalam perjalanan',
          'color': const Color(0xFFEAB308),
        };
      case 'arrived':
        return {
          'text': 'Kurir telah sampai',
          'color': const Color(0xFFEAB308),
        };
      case 'in progress':
      case 'processing':
        return {
          'text': 'Pesanan sedang diproses',
          'color': const Color(0xFFEAB308),
        };
      case 'unpaid':
      case 'waiting_payment':
        return {
          'text': 'Menunggu pembayaran',
          'color': const Color(0xFFEAB308),
        };
      case 'returning':
      case 'delivering':
        return {
          'text': 'Kurir dalam perjalanan mengantar pakaianmu',
          'color': const Color(0xFF0007B0),
        };
      case 'done':
        return {
          'text': 'Kurir telah sampai',
          'color': const Color(0xFFEAB308),
        };
      default:
        return {
          'text': 'Pesanan diproses',
          'color': const Color(0xFFEAB308),
        };
    }
  }

  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }
}
