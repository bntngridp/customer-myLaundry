import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/order_view_model.dart';
import '../view_models/home_view_model.dart';
import '../../../shared/widgets/app_snackbar.dart';

class OrderBottomSheet extends StatefulWidget {
  const OrderBottomSheet({super.key});

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  bool _showAddressSearch = false;
  double _swipeAlign = 0.0; // Slider swipe progress: 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context);

    // If searching courier, display full screen animation overlay
    if (viewModel.isFindingCourier) {
      return _buildFindingCourierScreen(context, viewModel);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gray pull-down line
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_showAddressSearch) ...[
                // Address Search panel
                const Text(
                  'Pilih Alamat Pengiriman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black38),
                    suffixIcon: const Icon(Icons.my_location, color: Color(0xFF0007B0)),
                    hintText: 'Tentukan lokasimu saat ini...',
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Address list
                ...viewModel.addresses.map((addr) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE6F0FF),
                      child: Icon(Icons.location_on, color: Color(0xFF0007B0)),
                    ),
                    title: Text(
                      addr.receiverName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                    ),
                    subtitle: Text(addr.fullAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      viewModel.selectAddress(addr);
                      setState(() {
                        _showAddressSearch = false;
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _showAddressSearch = false),
                  child: const Text('Batal', style: TextStyle(color: Colors.black54)),
                )
              ] else ...[
                // Selected Address Header
                GestureDetector(
                  onTap: () => setState(() => _showAddressSearch = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFEF4444)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.selectedAddress?.receiverName ?? 'Pilih Alamat',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1739)),
                              ),
                              Text(
                                viewModel.selectedAddress?.fullAddress ?? 'Ketuk untuk menambahkan alamat',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone number & Promo buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.black38, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.selectedAddress?.phoneNumber ?? '+6281234567890',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Color(0xFF0007B0), size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Promo',
                            style: TextStyle(color: Color(0xFF0007B0), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Services Row Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: viewModel.services.map((srv) {
                    final isSelected = viewModel.selectedService?.id == srv.id;
                    Color color = const Color(0xFFEAB308); // Cuci Lipat Yellow
                    IconData icon = Icons.dry_cleaning;
                    if (srv.title.toLowerCase().contains('iron')) {
                      color = const Color(0xFF38BDF8); // Cuci Setrika Blue
                      icon = Icons.iron;
                    } else if (srv.title.toLowerCase().contains('jacket') || srv.title.toLowerCase().contains('clean')) {
                      color = const Color(0xFF22C55E); // Cuci Satuan Green
                      icon = Icons.layers;
                    }

                    return GestureDetector(
                      onTap: () => viewModel.selectService(srv),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? color : color.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected ? Colors.white : color,
                                  size: 24,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(Icons.check_circle, color: color, size: 16),
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            srv.title.split(' ').take(2).join(' '),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : Colors.black54,
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Item tags selection grid
                const Text(
                  'Pilih Item Cucian (Satuan)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Selimut', 'Bedcover', 'Sprei', 'Kemeja', 'Jas', 'Kebaya', 'Dress', 'Karpet Bulu', 'Boneka(S)', 'Boneka(L)'
                  ].map((item) {
                    final isSel = viewModel.selectedItems.contains(item);
                    return ChoiceChip(
                      label: Text(item),
                      selected: isSel,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      selectedColor: const Color(0xFF0007B0),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => viewModel.toggleItem(item),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),

                // Custom swipe slider button ("Geser Untuk Pemesanan")
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _swipeAlign += details.primaryDelta! / 250.0;
                      if (_swipeAlign < 0.0) _swipeAlign = 0.0;
                      if (_swipeAlign > 1.0) _swipeAlign = 1.0;
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    if (_swipeAlign > 0.8) {
                      // Trigger order submission
                      final success = await viewModel.submitOrder();
                      if (success) {
                        // Refresh status card in HomeView
                        if (context.mounted) {
                          Provider.of<HomeViewModel>(context, listen: false).checkActiveOrder();
                        }
                      } else {
                        setState(() {
                          _swipeAlign = 0.0;
                        });
                        if (context.mounted && viewModel.errorMessage != null) {
                          AppSnackBar.showError(context, viewModel.errorMessage!);
                        }
                      }
                    } else {
                      setState(() {
                        _swipeAlign = 0.0;
                      });
                    }
                  },
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0FF),
                      borderRadius: BorderRadius.circular(29),
                      border: Border.all(color: const Color(0xFFD0E1FD)),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            'Geser Untuk Pemesanan',
                            style: TextStyle(
                              color: Color(0xFF0007B0),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        // Draggable Slider Dot
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 50),
                          alignment: Alignment(_swipeAlign * 2 - 1.0, 0),
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0007B0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindingCourierScreen(BuildContext context, OrderViewModel viewModel) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
                onPressed: () => viewModel.setFindingCourier(false),
              ),
            ],
          ),
          const Spacer(),

          // Motor scooter delivery animation representation
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: _ScooterCourierPainter(),
            ),
          ),
          const SizedBox(height: 36),

          const Text(
            'Sedang Mencari Kurir',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1739),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kami sedang mencocokkan pesanan Anda dengan kurir terdekat. Mohon tunggu sebentar...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),

          const CircularProgressIndicator(
            color: Color(0xFF0007B0),
            strokeWidth: 4,
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () {
              viewModel.setFindingCourier(false);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Batalkan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ScooterCourierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.fill;

    // Draw circular backdrop
    canvas.drawCircle(center, size.width * 0.45, paint);

    // Draw scooter outline representation
    final scooterPaint = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final wheelPaint = Paint()
      ..color = const Color(0xFF0B1739)
      ..style = PaintingStyle.fill;

    // Draw wheels
    canvas.drawCircle(center.translate(-35, 25), 15, wheelPaint);
    canvas.drawCircle(center.translate(35, 25), 15, wheelPaint);

    // Draw chassis line connecting wheels
    canvas.drawLine(center.translate(-35, 25), center.translate(35, 25), scooterPaint);

    // Draw body frame
    final path = Path()
      ..moveTo(center.dx - 35, center.dy + 10)
      ..quadraticBezierTo(center.dx, center.dy - 10, center.dx + 25, center.dy + 10)
      ..lineTo(center.dx + 35, center.dy - 20); // Front fork/handlebars

    canvas.drawPath(path, scooterPaint);

    // Draw laundry box basket on the back
    final boxPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromCenter(center: center.translate(-30, -10), width: 30, height: 30),
      boxPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
