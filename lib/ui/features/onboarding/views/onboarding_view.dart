import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../auth/views/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'badge': 'Layanan Antar Jemput',
      'title': 'Nikmati Kemudahan\ndari Rumah',
      'subtitle': 'Pesan layanan jemput dan antar kembali cucian bersih Anda dengan sekali ketuk.',
    },
    {
      'badge': 'Perawatan Maksimal',
      'title': 'Teknologi Pencucian\nTerdepan',
      'subtitle': 'Mesin cuci premium dan detergen khusus agar pakaian tetap bersih, wangi, dan awet.',
    },
    {
      'badge': 'Jaminan Hemat',
      'title': 'Harga Terjangkau &\nTransparan',
      'subtitle': 'Tanpa biaya tersembunyi. Lebih hemat waktu dan ramah di dompet Anda.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Ambient Background Glow Orbs
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x220007B0),
                    Color(0x000007B0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x1F38BDF8),
                    Color(0x0038BDF8),
                  ],
                ),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Logo Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0B000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                'assets/images/logo-nobg.png',
                                width: 26,
                                height: 26,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/logo-mylaundry.png',
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0007B0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_laundry_service_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'myLaundry',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Skip Button
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Lewati',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Onboarding Page Slider
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
                      final item = _onboardingData[index];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Vector Graphic Canvas
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: CustomPaint(
                                    painter: _ModernOnboardingPainter(index: index),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Text Content Card
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Category Badge
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: const Color(0xFFC7D2FE),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item['badge']!,
                                      style: const TextStyle(
                                        color: Color(0xFF0007B0),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Main Title
                                  Text(
                                    item['title']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      height: 1.25,
                                      letterSpacing: -0.5,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Subtitle Description
                                  Text(
                                    item['subtitle']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                      height: 1.55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Modern Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        gradient: _currentPage == index
                            ? const LinearGradient(
                                colors: [Color(0xFF0007B0), Color(0xFF2563EB)],
                              )
                            : null,
                        color: _currentPage == index ? null : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _currentPage == index
                            ? const [
                                BoxShadow(
                                  color: Color(0x590007B0),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Bottom Primary Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0007B0),
                          Color(0xFF1D4ED8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x590007B0),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_currentPage < _onboardingData.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            _navigateToLogin();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 58,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _onboardingData.length - 1
                                    ? 'Mulai Sekarang'
                                    : 'Lanjutkan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0x33FFFFFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Vector Painter for modern, aesthetic onboarding illustrations
class _ModernOnboardingPainter extends CustomPainter {
  final int index;
  _ModernOnboardingPainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minSize = math.min(size.width, size.height);

    // 1. Soft Backdrop Glow Circle
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: index == 0
            ? [const Color(0xFFDBEAFE), const Color(0x00DBEAFE)]
            : index == 1
                ? [const Color(0xFFE0E7FF), const Color(0x00E0E7FF)]
                : [const Color(0xFFFEF3C7), const Color(0x00FEF3C7)],
      ).createShader(Rect.fromCircle(center: center, radius: minSize * 0.45));

    canvas.drawCircle(center, minSize * 0.45, glowPaint);

    // 2. Base Container Soft Glass Card Shadow & Shape
    final cardRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: minSize * 0.72, height: minSize * 0.72),
      const Radius.circular(28),
    );

    // Card Shadow
    canvas.drawRRect(
      cardRRect.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0x0F000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    // Card Background
    canvas.drawRRect(
      cardRRect,
      Paint()..color = Colors.white,
    );

    // Card Border
    canvas.drawRRect(
      cardRRect,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (index == 0) {
      _drawHomeDeliveryGraphic(canvas, center, minSize);
    } else if (index == 1) {
      _drawWashingTechGraphic(canvas, center, minSize);
    } else {
      _drawAffordablePricingGraphic(canvas, center, minSize);
    }
  }

  // --- PAGE 1: Home Delivery & Pickup ---
  void _drawHomeDeliveryGraphic(Canvas canvas, Offset center, double scale) {
    const primaryColor = Color(0xFF0007B0);
    const accentColor = Color(0xFF38BDF8);

    // House illustration inside card
    final housePath = Path();
    final houseCenter = center.translate(-15, -10);

    // Roof
    housePath.moveTo(houseCenter.dx - 35, houseCenter.dy - 5);
    housePath.lineTo(houseCenter.dx, houseCenter.dy - 35);
    housePath.lineTo(houseCenter.dx + 35, houseCenter.dy - 5);
    housePath.close();

    canvas.drawPath(
      housePath,
      Paint()..color = primaryColor,
    );

    // House Body
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(houseCenter.dx - 28, houseCenter.dy - 5, 56, 42),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRRect, Paint()..color = const Color(0xFFEEF2FF));

    // House Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(houseCenter.dx - 9, houseCenter.dy + 12, 18, 25),
        const Radius.circular(4),
      ),
      Paint()..color = primaryColor,
    );

    // Express Delivery Van / Truck
    final truckCenter = center.translate(20, 20);
    final truckRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(truckCenter.dx - 30, truckCenter.dy - 15, 60, 32),
      const Radius.circular(8),
    );

    // Truck Shadow
    canvas.drawRRect(
      truckRRect.shift(const Offset(0, 4)),
      Paint()..color = const Color(0x330007B0),
    );

    // Truck Body
    canvas.drawRRect(
      truckRRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
        ).createShader(truckRRect.outerRect),
    );

    // Truck Wheels
    canvas.drawCircle(Offset(truckCenter.dx - 16, truckCenter.dy + 17), 7, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(truckCenter.dx - 16, truckCenter.dy + 17), 3, Paint()..color = Colors.white);

    canvas.drawCircle(Offset(truckCenter.dx + 16, truckCenter.dy + 17), 7, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(truckCenter.dx + 16, truckCenter.dy + 17), 3, Paint()..color = Colors.white);

    // Laundry Bag Icon on Truck
    canvas.drawCircle(
      Offset(truckCenter.dx, truckCenter.dy - 1),
      8,
      Paint()..color = const Color(0xE6FFFFFF),
    );

    // Motion Lines / Sparkles
    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center.translate(-65, 30), center.translate(-50, 30), linePaint);
    canvas.drawLine(center.translate(-75, 40), center.translate(-55, 40), linePaint);

    // Sparkle Star
    _drawSparkle(canvas, center.translate(45, -40), 12, const Color(0xFFF59E0B));
  }

  // --- PAGE 2: Washing Technology ---
  void _drawWashingTechGraphic(Canvas canvas, Offset center, double scale) {
    const primaryColor = Color(0xFF0007B0);
    const cyanColor = Color(0xFF06B6D4);

    // Washing Machine Main Body
    final machineRect = Rect.fromCenter(center: center, width: 84, height: 104);
    final machineRRect = RRect.fromRectAndRadius(machineRect, const Radius.circular(16));

    // Outer Body Fill & Gradient
    canvas.drawRRect(
      machineRRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(machineRect),
    );

    canvas.drawRRect(
      machineRRect,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Top Control Panel Bar
    final panelRect = Rect.fromLTWH(machineRect.left + 8, machineRect.top + 8, machineRect.width - 16, 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFFEEF2FF),
    );

    // Knobs & Display
    canvas.drawCircle(Offset(panelRect.left + 12, panelRect.top + 7), 4, Paint()..color = primaryColor);
    canvas.drawCircle(Offset(panelRect.left + 24, panelRect.top + 7), 3, Paint()..color = cyanColor);

    // Digital Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(panelRect.right - 22, panelRect.top + 3, 16, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF10B981),
    );

    // Circular Glass Door Outer
    final doorCenter = center.translate(0, 10);
    canvas.drawCircle(
      doorCenter,
      30,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ).createShader(Rect.fromCircle(center: doorCenter, radius: 30)),
    );

    // Glass Water Wave Effect inside door
    final waterPath = Path();
    waterPath.addArc(Rect.fromCircle(center: doorCenter, radius: 24), 0, math.pi * 2);
    canvas.drawPath(
      waterPath,
      Paint()..color = const Color(0x40FFFFFF),
    );

    // Inner Door Water Fill
    canvas.drawCircle(
      doorCenter,
      22,
      Paint()..color = const Color(0x9906B6D4),
    );

    // Bubbles around machine
    canvas.drawCircle(center.translate(-50, -25), 9, Paint()..color = const Color(0x7738BDF8));
    canvas.drawCircle(center.translate(-50, -25), 9, Paint()..color = const Color(0x80FFFFFF)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.drawCircle(center.translate(48, -35), 14, Paint()..color = const Color(0x6660A5FA));
    canvas.drawCircle(center.translate(48, -35), 14, Paint()..color = const Color(0x99FFFFFF)..style = PaintingStyle.stroke..strokeWidth = 2);

    canvas.drawCircle(center.translate(42, 38), 7, Paint()..color = const Color(0x88A7F3D0));

    // Clean Sparkle
    _drawSparkle(canvas, center.translate(-40, 42), 10, const Color(0xFFF59E0B));
  }

  // --- PAGE 3: Affordable Pricing & Guarantee ---
  void _drawAffordablePricingGraphic(Canvas canvas, Offset center, double scale) {
    const goldColor = Color(0xFFF59E0B);

    // Shield outline
    final shieldPath = Path();
    final sCenter = center.translate(-10, -5);

    shieldPath.moveTo(sCenter.dx, sCenter.dy - 40);
    shieldPath.quadraticBezierTo(sCenter.dx + 35, sCenter.dy - 35, sCenter.dx + 35, sCenter.dy);
    shieldPath.quadraticBezierTo(sCenter.dx + 35, sCenter.dy + 35, sCenter.dx, sCenter.dy + 50);
    shieldPath.quadraticBezierTo(sCenter.dx - 35, sCenter.dy + 35, sCenter.dx - 35, sCenter.dy);
    shieldPath.quadraticBezierTo(sCenter.dx - 35, sCenter.dy - 35, sCenter.dx, sCenter.dy - 40);
    shieldPath.close();

    // Shield Shadow
    canvas.drawPath(
      shieldPath.shift(const Offset(0, 6)),
      Paint()..color = const Color(0x220007B0),
    );

    // Shield Gradient
    canvas.drawPath(
      shieldPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0007B0), Color(0xFF2563EB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(shieldPath.getBounds()),
    );

    // Checkmark inside shield
    final checkPath = Path();
    checkPath.moveTo(sCenter.dx - 12, sCenter.dy + 2);
    checkPath.lineTo(sCenter.dx - 3, sCenter.dy + 11);
    checkPath.lineTo(sCenter.dx + 14, sCenter.dy - 8);

    canvas.drawPath(
      checkPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Gold Coin Badge
    final coinCenter = center.translate(28, 20);
    canvas.drawCircle(
      coinCenter,
      22,
      Paint()..color = goldColor,
    );
    canvas.drawCircle(
      coinCenter,
      18,
      Paint()
        ..color = const Color(0xFFFCD34D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rp Text on Coin
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Rp',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(coinCenter.dx - textPainter.width / 2, coinCenter.dy - textPainter.height / 2),
    );

    // Floating Discount Tag Pill
    final tagCenter = center.translate(-35, 35);
    final tagRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: tagCenter, width: 64, height: 24),
      const Radius.circular(12),
    );
    canvas.drawRRect(tagRRect, Paint()..color = const Color(0xFF10B981));

    final tagPainter = TextPainter(
      text: const TextSpan(
        text: 'HEMAT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tagPainter.paint(
      canvas,
      Offset(tagCenter.dx - tagPainter.width / 2, tagCenter.dy - tagPainter.height / 2),
    );

    // Sparkles
    _drawSparkle(canvas, center.translate(45, -35), 11, goldColor);
  }

  // Draw 4-point sparkle star
  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
