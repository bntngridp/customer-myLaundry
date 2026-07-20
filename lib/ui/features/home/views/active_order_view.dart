import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import 'customer_chat_view.dart';
import 'customer_call_view.dart';
import 'receipt_view.dart';

class ActiveOrderView extends StatelessWidget {
  const ActiveOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final activeOrder = homeViewModel.activeOrder;
    final status = activeOrder?.status.toLowerCase() ?? '';

    return Scaffold(
      body: Stack(
        children: [
          // Custom road map background painter
          Positioned.fill(
            child: CustomPaint(
              painter: _InteractiveRoadMapPainter(),
            ),
          ),

          // Safe Area App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B1739),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Payment Action if waiting for payment
          if (status == 'unpaid' || status == 'waiting_payment')
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0007B0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0007B0).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payment, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagihan Cucian Siap',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Silakan lakukan pembayaran sekarang',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReceiptView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0007B0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),

          // Floating Bottom Panel (Courier Tracking info)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Courier Details Row
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Surwanto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1739),
                              ),
                            ),
                            Text(
                              'D 1080 ABK',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Driver akan tiba dalam',
                              style: TextStyle(fontSize: 9, color: Colors.black45),
                            ),
                            Text(
                              '8 Menit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0007B0),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Chat Input Form / Trigger
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerChatView()),
                            );
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Obrolan pesan bisa di sini ya...',
                                  style: TextStyle(color: Colors.black38, fontSize: 13),
                                ),
                                Spacer(),
                                Icon(Icons.send, color: Color(0xFF0007B0), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerCallView()),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0007B0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InteractiveRoadMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background with light green land color
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36.0
      ..strokeCap = StrokeCap.round;

    // Draw road path borders then roads
    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.5)
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.5, size.height)
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, roadBorderPaint);
    canvas.drawPath(path, roadPaint);

    // Draw Hospital Area Landmark (Oetomo Hospital)
    final landmarkPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    
    final hospitalRect = Rect.fromLTWH(size.width * 0.1, size.height * 0.45, 120, 60);
    canvas.drawRRect(RRect.fromRectAndRadius(hospitalRect, const Radius.circular(12)), landmarkPaint);

    // Draw red cross icon on hospital
    final crossPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.1 + 60, size.height * 0.45 + 20), Offset(size.width * 0.1 + 60, size.height * 0.45 + 40), crossPaint);
    canvas.drawLine(Offset(size.width * 0.1 + 50, size.height * 0.45 + 30), Offset(size.width * 0.1 + 70, size.height * 0.45 + 30), crossPaint);

    // Draw Text Labels
    const textStyle = TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Oetomo Hospital Label
    textPainter.text = const TextSpan(text: 'Oetomo Hospital', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.1 + 18, size.height * 0.45 + 44));

    // Bulevar Podomoro La Label
    textPainter.text = const TextSpan(text: 'Bulevar Podomoro La', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.42, size.height * 0.82));

    // Pin Markers (Blue for Courier, Red for Customer)
    final blueMarker = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.fill;
    
    final redMarker = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    // Draw Courier pin
    final courierOffset = Offset(size.width * 0.4, size.height * 0.38);
    canvas.drawCircle(courierOffset, 12, blueMarker);
    canvas.drawCircle(courierOffset, 6, Paint()..color = Colors.white);

    // Draw Customer pin
    final customerOffset = Offset(size.width * 0.62, size.height * 0.52);
    canvas.drawCircle(customerOffset, 12, redMarker);
    canvas.drawCircle(customerOffset, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
