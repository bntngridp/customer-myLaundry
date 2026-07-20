import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import 'home_view.dart';

class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({super.key});

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
              // Success checkmark illustration with CustomPaint
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _PaymentSuccessIllustrationPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Success Text
              const Text(
                'Terima Kasih,\nPembayaranmu telah Berhasil',
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
                'Terima kasih telah mempercayakan cucian Anda pada kami. Kurir akan segera mengirimkan pakaian bersih Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Kembali ke Home Button
              ElevatedButton(
                onPressed: () {
                  // Reset active order state so user returns to normal state
                  final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
                  homeViewModel.checkActiveOrder(); // Re-fetch to confirm it's cleared or completed

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeContainer()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali ke Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSuccessIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bgPaint = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.fill;

    // Draw outer circle
    canvas.drawCircle(center, size.width * 0.4, bgPaint);

    // Draw Checklist icon inside phone frame representation
    final phonePaint = Paint()
      ..color = const Color(0xFF0B1739)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 65, height: 110),
        const Radius.circular(16),
      ),
      phonePaint,
    );

    // Blue check circle inside phone
    final checkCirclePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, checkCirclePaint);

    // White check symbol
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - 8, center.dy)
      ..lineTo(center.dx - 2, center.dy + 6)
      ..lineTo(center.dx + 8, center.dy - 5);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
