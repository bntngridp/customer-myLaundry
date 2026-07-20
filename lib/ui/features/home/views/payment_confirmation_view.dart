import 'dart:async';
import 'package:flutter/material.dart';
import 'payment_success_view.dart';

class PaymentConfirmationView extends StatefulWidget {
  const PaymentConfirmationView({super.key});

  @override
  State<PaymentConfirmationView> createState() => _PaymentConfirmationViewState();
}

class _PaymentConfirmationViewState extends State<PaymentConfirmationView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessView()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Custom paint magnifying glass & files folder checking illustration
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _CheckingIllustrationPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              const Text(
                'Bentar ya, kami sedang\nmemeriksa pembayaranmu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1739),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kami sedang melakukan verifikasi transaksi pembayaran Anda. Halaman ini akan diperbarui secara otomatis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0007B0),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckingIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw background blob/circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.4, bgPaint);

    // Draw Folder/document
    final docPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(-10, 10), width: 60, height: 75),
        const Radius.circular(8),
      ),
      docPaint,
    );

    // Draw file lines inside document
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center.translate(-30, -10), center.translate(10, -10), linePaint);
    canvas.drawLine(center.translate(-30, 5), center.translate(5, 5), linePaint);
    canvas.drawLine(center.translate(-30, 20), center.translate(0, 20), linePaint);

    // Draw Magnifying glass
    final glassPaint = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final glassOffset = center.translate(25, -25);
    canvas.drawCircle(glassOffset, 22, glassPaint);

    // Draw magnifying glass handle
    canvas.drawLine(
      glassOffset.translate(15, 15),
      glassOffset.translate(35, 35),
      Paint()
        ..color = const Color(0xFF0007B0)
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
