import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../domain/models/order.dart';

enum PaymentMethodType { qris, bankTransfer, eWallet, cash }

class PaymentMethodItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final PaymentMethodType type;
  final List<Color> colors;

  PaymentMethodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.colors,
  });
}

class PaymentViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final OrderRepository orderRepository;

  bool _isProcessing = false;
  bool _isPaid = false;
  String? _errorMessage;
  PaymentMethodItem? _selectedMethod;
  Timer? _qrisTimer;
  int _qrisCountdownSeconds = 900; // 15 mins

  PaymentViewModel({
    required this.authRepository,
    required this.orderRepository,
  });

  bool get isProcessing => _isProcessing;
  bool get isPaid => _isPaid;
  String? get errorMessage => _errorMessage;
  PaymentMethodItem? get selectedMethod => _selectedMethod;
  int get qrisCountdownSeconds => _qrisCountdownSeconds;

  String get formattedCountdown {
    final minutes = (_qrisCountdownSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_qrisCountdownSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  final List<PaymentMethodItem> availableMethods = [
    PaymentMethodItem(
      id: 'qris',
      name: 'QRIS Instant',
      description: 'Scan & Bayar instan via GoPay, OVO, ShopeePay, BCA Mobile',
      icon: Icons.qr_code_scanner_rounded,
      type: PaymentMethodType.qris,
      colors: const [Color(0xFF0007B0), Color(0xFF00B4DB)],
    ),
    PaymentMethodItem(
      id: 'bca_va',
      name: 'BCA Virtual Account',
      description: 'Transfer otomatis 24 Jam via M-BCA / KlikBCA',
      icon: Icons.account_balance_rounded,
      type: PaymentMethodType.bankTransfer,
      colors: const [Color(0xFF005691), Color(0xFF0080FF)],
    ),
    PaymentMethodItem(
      id: 'mandiri_va',
      name: 'Mandiri Virtual Account',
      description: 'Transfer via Livin\' by Mandiri',
      icon: Icons.account_balance_wallet_rounded,
      type: PaymentMethodType.bankTransfer,
      colors: const [Color(0xFF003865), Color(0xFF005691)],
    ),
    PaymentMethodItem(
      id: 'gopay',
      name: 'GoPay / GoPay Later',
      description: 'Bayar 1-Klik tanpa perlu pindah aplikasi',
      icon: Icons.account_balance_wallet_outlined,
      type: PaymentMethodType.eWallet,
      colors: const [Color(0xFF00AA13), Color(0xFF00D117)],
    ),
    PaymentMethodItem(
      id: 'cod',
      name: 'Tunai Saat Kurir Datang (COD)',
      description: 'Bayar tunai langsung ke kurir saat antar/jemput',
      icon: Icons.payments_rounded,
      type: PaymentMethodType.cash,
      colors: const [Color(0xFF059669), Color(0xFF10B981)],
    ),
  ];

  void selectMethod(PaymentMethodItem method) {
    _selectedMethod = method;
    if (method.type == PaymentMethodType.qris) {
      _startQrisTimer();
    } else {
      _qrisTimer?.cancel();
    }
    notifyListeners();
  }

  void _startQrisTimer() {
    _qrisTimer?.cancel();
    _qrisCountdownSeconds = 900;
    _qrisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrisCountdownSeconds > 0) {
        _qrisCountdownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<bool> processPayment(OrderModel order) async {
    final token = authRepository.token;
    if (token == null) {
      _errorMessage = 'Sesi telah berakhir, silakan login kembali.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    // Simulated network payment verification
    await Future.delayed(const Duration(seconds: 2));

    _isProcessing = false;
    _isPaid = true;
    _qrisTimer?.cancel();
    notifyListeners();
    return true;
  }

  void resetState() {
    _isProcessing = false;
    _isPaid = false;
    _errorMessage = null;
    _selectedMethod = null;
    _qrisTimer?.cancel();
  }

  @override
  void dispose() {
    _qrisTimer?.cancel();
    super.dispose();
  }
}
