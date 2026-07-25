import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/rating_repository.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/home_view_model.dart';
import 'rate_order_modal.dart';

class OrderSuccessDeliveryView extends StatelessWidget {
  const OrderSuccessDeliveryView({super.key});

  void _openRatingModal(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final ratingRepo = Provider.of<RatingRepository>(context, listen: false);
    final homeVm = Provider.of<HomeViewModel>(context, listen: false);
    final activeOrder = homeVm.activeOrder;
    final token = authVm.authRepository.token ?? '';

    if (activeOrder == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RateOrderModal(
        order: activeOrder,
        ratingRepository: ratingRepo,
        token: token,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Premium smartphone checklist illustration
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_chat_read_outlined,
                    size: 64,
                    color: Color(0xFF0007B0),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              const Text(
                'Terima Kasih,\nPesananmu Telah Sampai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1739),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kami senang bisa membantu membersihkan pakaian Anda. Berikan penilaian Anda untuk membantu kami meningkatkan kualitas layanan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // Rating button
              ElevatedButton.icon(
                onPressed: () => _openRatingModal(context),
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: const Text('Beri Ulasan & Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Kembali ke Home button
              OutlinedButton(
                onPressed: () {
                  // Clear active order
                  Provider.of<HomeViewModel>(context, listen: false).clearActiveOrder();
                  // Reset back to Home Container
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Kembali ke Home',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B1739)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
