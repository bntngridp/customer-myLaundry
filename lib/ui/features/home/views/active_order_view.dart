import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import 'customer_chat_view.dart';
import 'customer_call_view.dart';
import '../../payment/views/payment_view.dart';
import '../../rating/views/rating_dialog.dart';

class ActiveOrderView extends StatefulWidget {
  const ActiveOrderView({super.key});

  @override
  State<ActiveOrderView> createState() => _ActiveOrderViewState();
}

class _ActiveOrderViewState extends State<ActiveOrderView> {
  static const LatLng _outletLocation = LatLng(-6.917464, 107.619123);
  static const LatLng _courierLocation = LatLng(-6.919400, 107.622500);
  static const LatLng _customerLocation = LatLng(-6.921464, 107.625123);

  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('outlet'),
      position: _outletLocation,
      infoWindow: const InfoWindow(title: 'Outlet myLaundry Main Store'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ),
    Marker(
      markerId: const MarkerId('courier'),
      position: _courierLocation,
      infoWindow: const InfoWindow(title: 'Posisi Kurir'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    Marker(
      markerId: const MarkerId('customer'),
      position: _customerLocation,
      infoWindow: const InfoWindow(title: 'Lokasi Penjemputan / Rumah Anda'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  final Set<Polyline> _polylines = {
    const Polyline(
      polylineId: PolylineId('delivery_route'),
      points: [
        _outletLocation,
        _courierLocation,
        _customerLocation,
      ],
      color: Color(0xFF0007B0),
      width: 4,
    ),
  };

  Timer? _statusPollTimer;

  @override
  void initState() {
    super.initState();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        Provider.of<HomeViewModel>(context, listen: false).fetchActiveOrder(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    super.dispose();
  }

  int _getStepIndex(String status) {
    final s = status.toLowerCase();
    if (s.contains('waiting for courier') || s.contains('pending') || s.contains('menunggu')) {
      return 0;
    }
    if (s.contains('on the way') || s.contains('assigned') || s.contains('diambil') || s.contains('pickup')) {
      return 1;
    }
    if (s.contains('arrived') || s.contains('pembayaran') || s.contains('dicuci') || s.contains('processing') || s.contains('washing') || s.contains('timbang')) {
      return 2;
    }
    if (s.contains('delivering') || s.contains('out_for_delivery') || s.contains('pengantaran')) {
      return 3;
    }
    if (s.contains('completed') || s.contains('selesai') || s.contains('done')) {
      return 4;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final activeOrder = homeViewModel.activeOrder;
    final status = activeOrder?.status.toLowerCase() ?? 'waiting for courier approval';
    final courierName = activeOrder?.courier?.username ?? 'Menunggu Kurir';
    final courierPhone = activeOrder?.courier?.phoneNumber ?? '';
    final currentStep = _getStepIndex(status);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map Background Layer
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _courierLocation,
              zoom: 14.5,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Safe Area App Bar Back Button & Status Card Header
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_laundry_service, color: Color(0xFF0007B0), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pesanan #${activeOrder?.id ?? 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1739)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0007B0).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                activeOrder?.status ?? 'Aktif',
                                style: const TextStyle(color: Color(0xFF0007B0), fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Payment Action if waiting for payment
          if (status.contains('pembayaran') || status.contains('unpaid') || status.contains('arrived') || (activeOrder != null && activeOrder.totalPrice > 0 && status != 'completed'))
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0007B0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D0007B0),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeOrder != null && activeOrder.totalPrice > 0
                                ? 'Tagihan: Rp ${activeOrder.totalPrice.toInt()}'
                                : 'Tagihan Cucian Siap',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            activeOrder != null && activeOrder.weight > 0
                                ? 'Berat Laundry: ${activeOrder.weight.toStringAsFixed(1).replaceAll('.0', '')} kg • Silakan bayar'
                                : 'Silakan lakukan pembayaran sekarang',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (activeOrder != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PaymentView(order: activeOrder)),
                          );
                        }
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

          // Floating Bottom Panel (Status Timeline Stepper + Dynamic Courier info)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Status Stepper Header Timeline
                  const Text(
                    'Status Pengerjaan Cucian',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusStepper(currentStep),
                  const SizedBox(height: 18),

                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 16),

                  // 2. Dynamic Courier Details Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF0007B0),
                        child: Text(
                          courierName.isNotEmpty ? courierName[0].toUpperCase() : 'K',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courierName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1739),
                              ),
                            ),
                            Text(
                              courierPhone.isNotEmpty ? courierPhone : 'Kurir Mitra ResmimyLaundry',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Chat & Call Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerChatView(
                                  orderId: activeOrder?.id ?? 0,
                                  courierName: courierName,
                                  phoneNumber: courierPhone,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Kirim pesan ke kurir...',
                                  style: TextStyle(color: Colors.black38, fontSize: 12),
                                ),
                                Spacer(),
                                Icon(Icons.send_rounded, color: Color(0xFF0007B0), size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerCallView(
                                targetUserId: activeOrder?.courier?.id ?? 0,
                                orderId: activeOrder?.id ?? 0,
                                phoneNumber: courierPhone,
                                courierName: courierName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0007B0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                  if (currentStep >= 4 || status == 'completed') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          RatingDialog.show(context, activeOrder?.id.toString() ?? '1');
                        },
                        icon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                        label: const Text(
                          'Beri Ulasan Laundry',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0007B0)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFBEB),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFFDE68A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusStepper(int currentStep) {
    final steps = [
      {'title': 'Dibuat', 'icon': Icons.assignment},
      {'title': 'Penjemputan', 'icon': Icons.local_shipping},
      {'title': 'Diproses', 'icon': Icons.local_laundry_service},
      {'title': 'Pengantaran', 'icon': Icons.directions_bike},
      {'title': 'Selesai', 'icon': Icons.check_circle},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index <= currentStep ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF0007B0) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? const Color(0xFF0007B0) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      steps[index]['icon'] as IconData,
                      size: 16,
                      color: isDone ? Colors.white : Colors.black38,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index < currentStep ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index]['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? const Color(0xFF0007B0) : Colors.black45,
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
