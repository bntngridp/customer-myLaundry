import 'package:flutter/material.dart';
import 'login_view.dart';

class RegisterSuccessView extends StatelessWidget {
  const RegisterSuccessView({super.key});

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
                    painter: _SuccessIllustrationPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Success Text
              const Text(
                'Terima Kasih,\nKini akunmu telah terdaftar',
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
                'Pendaftaran akun pelanggan Anda berhasil. Silakan masuk untuk mulai menikmati semua kemudahan layanan My Laundry.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Masuk Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
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
                  'Masuk',
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

class _SuccessIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bgPaint = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.fill;
    
    // Draw outer circle
    canvas.drawCircle(center, size.width * 0.4, bgPaint);
    
    // Draw secondary inner highlight circle
    final highlightPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center.translate(-30, -30), size.width * 0.15, highlightPaint);

    // Draw Checkmark circle
    final checkCirclePaint = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.22, checkCirclePaint);

    // Draw check icon in white
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - 16, center.dy)
      ..lineTo(center.dx - 4, center.dy + 12)
      ..lineTo(center.dx + 16, center.dy - 12);
    
    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
