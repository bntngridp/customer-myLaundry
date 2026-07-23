import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import 'customer_chat_view.dart';
import 'customer_call_view.dart';
import 'receipt_view.dart';

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
      infoWindow: const InfoWindow(title: 'Kurir: Surwanto (D 1080 ABK)'),
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

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final activeOrder = homeViewModel.activeOrder;
    final status = activeOrder?.status.toLowerCase() ?? '';

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

          // Safe Area App Bar Back Button
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
