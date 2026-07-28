import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/services/payment_service.dart';
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
  final PaymentService _paymentService = PaymentService();

  bool _isProcessing = false;
  bool _isPaid = false;
  String? _errorMessage;
  String? _snapRedirectUrl;
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
  String? get snapRedirectUrl => _snapRedirectUrl;
  PaymentMethodItem? get selectedMethod => _selectedMethod;
  int get qrisCountdownSeconds => _qrisCountdownSeconds;

  String get formattedCountdown {
    final minutes = (_qrisCountdownSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_qrisCountdownSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  final List<PaymentMethodItem> availableMethods = [
    PaymentMethodItem(
      id: 'QRIS',
      name: 'QRIS Instant',
      description: 'Scan & Bayar instan via GoPay, OVO, ShopeePay, BCA Mobile',
      icon: Icons.qr_code_scanner_rounded,
      type: PaymentMethodType.qris,
      colors: const [Color(0xFF0007B0), Color(0xFF00B4DB)],
    ),
    PaymentMethodItem(
      id: 'BCA_VA',
      name: 'BCA Virtual Account',
      description: 'Transfer otomatis 24 Jam via M-BCA / KlikBCA',
      icon: Icons.account_balance_rounded,
      type: PaymentMethodType.bankTransfer,
      colors: const [Color(0xFF005691), Color(0xFF0080FF)],
    ),
    PaymentMethodItem(
      id: 'MANDIRI_VA',
      name: 'Mandiri Virtual Account',
      description: "Transfer via Livin' by Mandiri",
      icon: Icons.account_balance_wallet_rounded,
      type: PaymentMethodType.bankTransfer,
      colors: const [Color(0xFF003865), Color(0xFF005691)],
    ),
    PaymentMethodItem(
      id: 'GOPAY',
      name: 'GoPay / GoPay Later',
      description: 'Bayar 1-Klik tanpa perlu pindah aplikasi',
      icon: Icons.account_balance_wallet_outlined,
      type: PaymentMethodType.eWallet,
      colors: const [Color(0xFF00AA13), Color(0xFF00D117)],
    ),
    PaymentMethodItem(
      id: 'COD',
      name: 'Tunai Saat Kurir Datang (COD)',
      description: 'Bayar tunai langsung ke kurir saat antar/jemput',
      icon: Icons.payments_rounded,
      type: PaymentMethodType.cash,
      colors: const [Color(0xFF059669), Color(0xFF10B981)],
    ),
  ];

  void selectMethod(PaymentMethodItem method) {
    _selectedMethod = method;
    _snapRedirectUrl = null;
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

  /// Process payment - calls actual backend API for real Midtrans integration
  Future<bool> processPayment(OrderModel order) async {
    final token = authRepository.token;
    if (token == null) {
      _errorMessage = 'Sesi telah berakhir, silakan login kembali.';
      notifyListeners();
      return false;
    }

    if (_selectedMethod == null) {
      _errorMessage = 'Pilih metode pembayaran terlebih dahulu.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // COD: call cash payment endpoint
      if (_selectedMethod!.type == PaymentMethodType.cash) {
        await _paymentService.confirmCashPayment(
          orderId: order.id,
          token: token,
        );
        _isProcessing = false;
        _isPaid = true;
        _qrisTimer?.cancel();
        notifyListeners();
        return true;
      }

      // Digital payment: Get Midtrans Snap token + open payment URL
      final snapData = await _paymentService.getSnapToken(
        orderId: order.id,
        paymentType: _selectedMethod!.id,
        token: token,
      );

      final redirectUrl = snapData['snap_redirect_url'] as String?;
      if (redirectUrl == null || redirectUrl.isEmpty) {
        throw Exception('URL pembayaran tidak tersedia dari server');
      }

      _snapRedirectUrl = redirectUrl;
      _isProcessing = false;
      notifyListeners();

      // Open Midtrans payment page in browser
      final uri = Uri.parse(redirectUrl);
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Payment will be confirmed via webhook or polling
        // Mark as processing to show waiting state
        _isPaid = true; // Show success after launching payment URL
        _qrisTimer?.cancel();
        notifyListeners();
        return true;
      } else {
        throw Exception('Tidak bisa membuka halaman pembayaran. Pastikan browser tersedia.');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _isProcessing = false;
    _isPaid = false;
    _errorMessage = null;
    _selectedMethod = null;
    _snapRedirectUrl = null;
    _qrisTimer?.cancel();
  }

  @override
  void dispose() {
    _qrisTimer?.cancel();
    super.dispose();
  }
}
