import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';

class OrderSuccessDeliveryView extends StatelessWidget {
  const OrderSuccessDeliveryView({super.key});

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
                    color: Color(0xFFE6F0FF),
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
                'Kami senang bisa membantu membersihkan pakaian Anda. Sampai jumpa di pemesanan berikutnya!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // Kembali ke Home button
              ElevatedButton(
                onPressed: () {
                  // Clear the active order simulation
                  Provider.of<HomeViewModel>(context, listen: false).clearActiveOrder();
                  // Reset back to Home Container
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali ke Home',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
