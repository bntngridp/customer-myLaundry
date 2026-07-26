import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/order.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/payment_view_model.dart';

class PaymentView extends StatefulWidget {
  final OrderModel order;

  const PaymentView({super.key, required this.order});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentViewModel>().resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final paymentVm = Provider.of<PaymentViewModel>(context);

    // Calculate total price based on service price or fallback
    final price = widget.order.service?.price ?? 0;
    final servicePrice = price > 0 ? price : 25000;
    const deliveryFee = 5000;
    const adminFee = 1000;
    final totalPrice = servicePrice + deliveryFee + adminFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B1739), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          authViewModel.translate('Pembayaran'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1739),
          ),
        ),
        centerTitle: true,
      ),
      body: paymentVm.isPaid
          ? _buildSuccessView(context, authViewModel, totalPrice)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  _buildOrderSummaryCard(authViewModel, servicePrice, deliveryFee, adminFee, totalPrice),
                  const SizedBox(height: 24),

                  // Select Payment Method Header
                  Text(
                    authViewModel.translate('Pilih Metode Pembayaran'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1739),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Method List
                  ...paymentVm.availableMethods.map((method) {
                    final isSelected = paymentVm.selectedMethod?.id == method.id;
                    return _buildPaymentMethodCard(method, isSelected, paymentVm);
                  }),

                  const SizedBox(height: 24),

                  // Detailed Payment Instructions / QRIS Code View
                  if (paymentVm.selectedMethod != null) ...[
                    _buildSelectedMethodDetail(paymentVm.selectedMethod!, paymentVm, totalPrice),
                    const SizedBox(height: 24),
                  ],

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: paymentVm.selectedMethod == null || paymentVm.isProcessing
                          ? null
                          : () async {
                              final success = await paymentVm.processPayment(widget.order);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authViewModel.translate('Pembayaran Berhasil! 🎉')),
                                    backgroundColor: const Color(0xFF059669),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0007B0),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: paymentVm.isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              paymentVm.selectedMethod == null
                                  ? authViewModel.translate('Pilih Metode Dahulu')
                                  : '${authViewModel.translate('Bayar Sekarang')} • Rp ${_formatCurrency(totalPrice)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummaryCard(
    AuthViewModel authVm,
    int servicePrice,
    int deliveryFee,
    int adminFee,
    int totalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID #${widget.order.id}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0007B0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  authVm.translate('Belum Dibayar'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
          _buildSummaryRow(authVm.translate('Layanan Laundry'), widget.order.service?.title ?? 'Layanan Laundry'),
          const SizedBox(height: 8),
          _buildSummaryRow(authVm.translate('Subtotal'), 'Rp ${_formatCurrency(servicePrice)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(authVm.translate('Biaya Antar-Jemput'), 'Rp ${_formatCurrency(deliveryFee)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(authVm.translate('Biaya Layanan'), 'Rp ${_formatCurrency(adminFee)}'),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                authVm.translate('Total Pembayaran'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1739),
                ),
              ),
              Text(
                'Rp ${_formatCurrency(totalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0007B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0B1739)),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethodItem method,
    bool isSelected,
    PaymentViewModel vm,
  ) {
    return GestureDetector(
      onTap: () => vm.selectMethod(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: method.colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF0B1739),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.description,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: method.id,
              groupValue: vm.selectedMethod?.id,
              activeColor: const Color(0xFF0007B0),
              onChanged: (_) => vm.selectMethod(method),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMethodDetail(
    PaymentMethodItem method,
    PaymentViewModel vm,
    int totalPrice,
  ) {
    if (method.type == PaymentMethodType.qris) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QRIS Code Official',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Batas Waktu: ${vm.formattedCountdown}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=MYLAUNDRY_ORDER_${widget.order.id}_$totalPrice',
                width: 180,
                height: 180,
                errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2_rounded, size: 140, color: Color(0xFF0007B0)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Buka aplikasi e-wallet / banking kamu, pilih Scan QRIS & bayar sesuai total nominal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    } else if (method.type == PaymentMethodType.bankTransfer) {
      const vaNumber = '88012398492041';
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nomor Virtual Account ${method.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    vaNumber,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF0007B0)),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: vaNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nomor VA berhasil disalin!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'SALIN',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0007B0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSuccessView(BuildContext context, AuthViewModel authVm, int totalPrice) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 72, color: Color(0xFF059669)),
            ),
            const SizedBox(height: 24),
            Text(
              authVm.translate('Pembayaran Berhasil!'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1739),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Rp ${_formatCurrency(totalPrice)} telah terverifikasi.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  authVm.translate('Kembali ke Pesanan'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
