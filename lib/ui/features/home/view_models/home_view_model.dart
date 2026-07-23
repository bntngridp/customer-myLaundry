import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../domain/models/order.dart';
import '../../../../domain/models/branch.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final OrderRepository orderRepository;

  bool _isLoading = false;
  String? _errorMessage;
  OrderModel? _activeOrder;

  final List<BranchModel> _branches = [
    BranchModel(
      name: 'myLaundry Bojongsoang',
      address: 'Jl. Raya Bojongsoang No. 12',
      distance: 0.2,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?auto=format&fit=crop&q=80&w=300',
    ),
    BranchModel(
      name: 'myLaundry Sukapura',
      address: 'Jl. Sukapura Raya No. 45',
      distance: 0.9,
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?auto=format&fit=crop&q=80&w=300',
    ),
    BranchModel(
      name: 'myLaundry Kiaracondong',
      address: 'Jl. Stasiun Kiaracondong No. 8',
      distance: 2.3,
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1604335399105-a0c585fd810e?auto=format&fit=crop&q=80&w=300',
    ),
  ];

  final List<Map<String, String>> _promos = [
    {
      'title': 'Dapatkan Diskon 30%',
      'subtitle': 'Hingga Rp5000',
      'code': 'BersihTanpaPusing',
    },
    {
      'title': 'Dapatkan Diskon 50%',
      'subtitle': 'Hingga Rp10000',
      'code': 'CucianWangi',
    },
  ];

  HomeViewModel({
    required this.authRepository,
    required this.orderRepository,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderModel? get activeOrder => _activeOrder;
  List<BranchModel> get branches => _branches;
  List<Map<String, String>> get promos => _promos;

  Future<void> checkActiveOrder() async {
    final token = authRepository.token;
    if (token == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orders = await orderRepository.getOrders(token);
      
      // Active order is one that is not completed or cancelled
      final activeList = orders.where((o) {
        final status = o.status.toLowerCase();
        return status != 'completed' && status != 'cancelled';
      }).toList();

      if (activeList.isNotEmpty) {
        // Sort by id descending to get the latest active order
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

  // Translates database status into Figma status string and color
  Map<String, dynamic> getOrderStatusDetails() {
    if (_activeOrder == null) {
      return {
        'text': 'Yuk gunakan promo #BersihTanpaPusing',
        'color': const Color(0xFF0007B0), // Blue indicator
      };
    }

    final status = _activeOrder!.status.toLowerCase();
    switch (status) {
      case 'pending':
        return {
          'text': 'Sedang mencari kurir',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
      case 'accepted':
        return {
          'text': 'Kurir dalam perjalanan',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
      case 'arrived':
        return {
          'text': 'Kurir telah sampai',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
      case 'in progress':
      case 'processing':
        return {
          'text': 'Pesanan sedang diproses',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
      case 'unpaid':
      case 'waiting_payment':
        return {
          'text': 'Menunggu pembayaran',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
      case 'returning':
      case 'delivering':
        return {
          'text': 'Kurir dalam perjalanan mengantar pakaianmu',
          'color': const Color(0xFF0007B0), // Blue indicator
        };
      case 'done':
        return {
          'text': 'Kurir telah sampai',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
      default:
        return {
          'text': 'Pesanan diproses',
          'color': const Color(0xFFEAB308), // Yellow indicator
        };
    }
  }

  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }
}
