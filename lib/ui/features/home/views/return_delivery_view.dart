import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'return_chat_view.dart';
import 'return_call_view.dart';
import 'order_success_delivery_view.dart';

class ReturnDeliveryView extends StatefulWidget {
  const ReturnDeliveryView({super.key});

  @override
  State<ReturnDeliveryView> createState() => _ReturnDeliveryViewState();
}

class _ReturnDeliveryViewState extends State<ReturnDeliveryView> {
  static const LatLng _outletLocation = LatLng(-6.917464, 107.619123);
  static const LatLng _courierLocation = LatLng(-6.920100, 107.623800);
  static const LatLng _customerLocation = LatLng(-6.921464, 107.625123);

  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('outlet'),
      position: _outletLocation,
      infoWindow: const InfoWindow(title: 'Outlet myLaundry'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ),
    Marker(
      markerId: const MarkerId('courier'),
      position: _courierLocation,
      infoWindow: const InfoWindow(title: 'Surwanto (Kurir Pengantaran)'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    Marker(
      markerId: const MarkerId('destination'),
      position: _customerLocation,
      infoWindow: const InfoWindow(title: 'Lokasi Pengantaran (Rumah Anda)'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  final Set<Polyline> _polylines = {
    const Polyline(
      polylineId: PolylineId('return_delivery_route'),
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
    return Scaffold(
      body: Stack(
        children: [
          // Google Map Background
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _courierLocation,
              zoom: 15.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
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
