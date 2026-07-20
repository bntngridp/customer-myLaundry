import 'package:flutter/material.dart';
import '../../auth/views/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Nikmati Kemudahan\ndari Rumah',
      'subtitle': 'Pesan layanan jemput dan antar kembali cucian bersih Anda dengan sekali ketuk.',
    },
    {
      'title': 'Teknologi Pencucian\nTerdepan',
      'subtitle': 'Mesin cuci premium dan detergen khusus agar pakaian tetap bersih, wangi, dan awet.',
    },
    {
      'title': 'Harga Terjangkau',
      'subtitle': 'Biaya transparan tanpa biaya tersembunyi. Hemat waktu dan hemat dompet.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo-mylaundry.png',
                    height: 28,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'myLaundry',
                        style: TextStyle(
                          color: Color(0xFF0007B0),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Slider content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustrated Image (Using CustomPaint to draw rich graphic representations matching the themes)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36.0),
                          child: CustomPaint(
                            size: const Size(double.infinity, double.infinity),
                            painter: _OnboardingGraphicPainter(index: index),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Text content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            Text(
                              _onboardingData[index]['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1739),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _onboardingData[index]['subtitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 36),
            
            // Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF0007B0) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 36),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _onboardingData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _navigateToLogin();
                  }
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
                child: Text(
                  _currentPage == _onboardingData.length - 1 ? 'Mulai' : 'Lanjut',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }
}

// Graphic painter that draws vector assets matching onboarding topics
class _OnboardingGraphicPainter extends CustomPainter {
  final int index;
  _OnboardingGraphicPainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width * 0.35 : size.height * 0.35;

    // Draw background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    if (index == 0) {
      // Draw a house representation
      final paint = Paint()
        ..color = const Color(0xFF0007B0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(center.dx - 40, center.dy + 30)
        ..lineTo(center.dx - 40, center.dy - 10)
        ..lineTo(center.dx, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 10)
        ..lineTo(center.dx + 40, center.dy + 30)
        ..close();

      canvas.drawPath(path, paint);

      // Draw door
      canvas.drawRect(
        Rect.fromLTRB(center.dx - 12, center.dy + 10, center.dx + 12, center.dy + 30),
        Paint()..color = const Color(0xFF0007B0),
      );

      // Draw delivery truck
      final truckPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(center.dx - 70, center.dy + 10, 45, 25),
          const Radius.circular(4),
        ),
        truckPaint,
      );
    } else if (index == 1) {
      // Draw laundry machine
      final machinePaint = Paint()
        ..color = const Color(0xFF0B1739)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 90, height: 110),
          const Radius.circular(16),
        ),
        machinePaint,
      );

      // Inner glass door
      canvas.drawCircle(
        center.translate(0, 10),
        25,
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        center.translate(0, 10),
        25,
        Paint()
          ..color = const Color(0xFF0007B0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      );

      // Buttons
      canvas.drawCircle(center.translate(-25, -35), 4, Paint()..color = Colors.red);
      canvas.drawCircle(center.translate(-10, -35), 4, Paint()..color = Colors.green);
      canvas.drawRect(
        Rect.fromLTWH(center.dx + 10, center.dy - 40, 20, 8),
        Paint()..color = Colors.black38,
      );
    } else {
      // Draw Price tag / coin shield
      final shieldPaint = Paint()
        ..color = const Color(0xFF0007B0)
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(center.dx, center.dy - 50)
        ..lineTo(center.dx + 40, center.dy - 20)
        ..lineTo(center.dx + 40, center.dy + 20)
        ..quadraticBezierTo(center.dx, center.dy + 60, center.dx, center.dy + 60)
        ..quadraticBezierTo(center.dx - 40, center.dy + 20, center.dx - 40, center.dy + 20)
        ..lineTo(center.dx - 40, center.dy - 20)
        ..close();
      canvas.drawPath(path, shieldPaint);

      // Draw dollar/rupiah sign in white
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Rp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
