import 'package:flutter/material.dart';
import 'return_chat_view.dart';
import 'return_call_view.dart';
import 'order_success_delivery_view.dart';

class ReturnDeliveryView extends StatelessWidget {
  const ReturnDeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Road Map Visual representation using custom painter
          Positioned.fill(
            child: CustomPaint(
              painter: _RoadMapPainter(),
            ),
          ),

          // Top Header back button
          Positioned(
            top: 60,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
              ),
            ),
          ),

          // Floating Driver tracking details card at bottom
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Simulation trigger button to arrive
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderSuccessDeliveryView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Simulasi Pesanan Sampai 🚚', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Surwanto avatar image
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150',
                                ),
                                fit: BoxFit.cover,
                              ),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B1739),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kurir Pengantaran',
                                  style: TextStyle(fontSize: 10, color: Colors.black38),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kurir akan tiba dalam 4 Menit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1739),
                            ),
                          ),
                          Row(
                            children: [
                              // Chat bubble button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ReturnChatView()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0007B0), size: 18),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Call/phone button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ReturnCallView()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Icon(Icons.phone_outlined, color: Color(0xFF0007B0), size: 18),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _RoadMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFF1F5F9));

    // Draw main boulevard/street lines representing Podomoro Boulevard
    final streetPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Road 1: Main vertical boulevard
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), streetPaint);
    // Road 2: Horizontal connection
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.55), streetPaint);
    // Road 3: Diagonal bypass
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.2), Offset(size.width * 0.9, size.height * 0.8), streetPaint);

    // Center divider dash lines
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), dashPaint);
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.55), dashPaint);

    // Text labels for landmark simulation (e.g. Oetomo Hospital)
    const textStyle = TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold);
    
    // Oetomo Hospital Label
    final textPainter1 = TextPainter(
      text: const TextSpan(text: 'Oetomo Hospital 🏥', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter1.paint(canvas, Offset(size.width * 0.12, size.height * 0.42));

    // Bulevar Podomoro Label
    final textPainter2 = TextPainter(
      text: const TextSpan(text: 'Bulevar Podomoro', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(size.width * 0.52, size.height * 0.65));

    // Draw scooter/courier dot route line representation
    final routePaint = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width * 0.45, size.height * 0.35),
      routePaint,
    );

    // Scooter marker circle
    final markerPaint = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.35), 8, markerPaint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.35), 14, Paint()..color = const Color(0xFF0007B0).withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
