import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/promo_service.dart';
import '../view_models/order_view_model.dart';
import '../view_models/home_view_model.dart';
import '../../../shared/widgets/app_snackbar.dart';

class OrderBottomSheet extends StatefulWidget {
  const OrderBottomSheet({super.key});

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  double _swipeAlign = 0.0; // Slider swipe progress: 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).loadInitialData();
    });
  }

  // Modal 1: Pemilih Promo Dinamis
  void _showPromoSelectorModal(BuildContext context, OrderViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final promoService = PromoService();
        final codeController = TextEditingController();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Promo & Voucher',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black45),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Manual Promo Code Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      decoration: InputDecoration(
                        hintText: 'Ketik kode promo (misal: BersihTanpaPusing)',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final code = codeController.text.trim();
                      if (code.isEmpty) return;
                      try {
                        final res = await promoService.validatePromo(code);
                        if (res.statusCode == 200) {
                          final body = jsonDecode(res.body);
                          if (body['success'] == true && body['data'] != null) {
                            viewModel.selectPromo(body['data']);
                            if (context.mounted) {
                              Navigator.pop(context);
                              AppSnackBar.showSuccess(context, 'Promo berhasil diterapkan!');
                            }
                            return;
                          }
                        }
                        if (context.mounted) {
                          AppSnackBar.showError(context, 'Kode promo tidak ditemukan/kadaluarsa');
                        }
                      } catch (_) {
                        if (context.mounted) {
                          AppSnackBar.showError(context, 'Gagal memvalidasi kode promo');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0007B0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Gunakan', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Voucher Tersedia Untukmu',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 12),

              // Dynamic Promos List from API
              FutureBuilder(
                future: promoService.getPromos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF0007B0))),
                    );
                  }

                  List promos = [];
                  if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                    final body = jsonDecode(snapshot.data!.body);
                    if (body['data'] != null) {
                      promos = body['data'];
                    }
                  }

                  // Fallback promos if offline
                  if (promos.isEmpty) {
                    promos = [
                      {
                        'code': 'BersihTanpaPusing',
                        'title': 'Diskon 30% Hemat Laundry',
                        'subtitle': 'Diskon hingga Rp 5.000 untuk semua layanan',
                        'discount_percentage': 30,
                        'max_discount_amount': 5000,
                      },
                      {
                        'code': 'CucianWangi',
                        'title': 'Diskon 50% Super Hemat',
                        'subtitle': 'Diskon hingga Rp 10.000 untuk cucian kiloan',
                        'discount_percentage': 50,
                        'max_discount_amount': 10000,
                      },
                      {
                        'code': 'MulaiLaundry',
                        'title': 'Free Delivery Promo',
                        'subtitle': 'Khusus pengguna baru myLaundry',
                        'discount_percentage': 100,
                        'max_discount_amount': 10000,
                      },
                    ];
                  }

                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      itemCount: promos.length,
                      itemBuilder: (context, index) {
                        final p = promos[index];
                        final isSelected = viewModel.selectedPromo?['code'] == p['code'];

                        return GestureDetector(
                          onTap: () {
                            viewModel.selectPromo(p);
                            Navigator.pop(context);
                            AppSnackBar.showSuccess(context, 'Promo ${p['code']} diterapkan!');
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0007B0).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.confirmation_number, color: Color(0xFF0007B0)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['title'] ?? 'Promo Laundry',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B1739)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p['subtitle'] ?? '-',
                                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF0007B0) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    p['code'] ?? 'PROMO',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF0007B0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  // Modal 2: Pemilih Alamat & Tambah GPS / Manual (Inline Modern Form)
  void _showAddressModal(BuildContext context, OrderViewModel viewModel) {
    bool isAddingManual = false;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+6281234567890');
    final streetCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      const SizedBox(height: 16),

                      if (!isAddingManual) ...[
                        // MODE 1: ALAMAT LIST & CHOICES
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pilih Alamat Pengiriman',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.black45),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Button 1: Real GPS Location Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final success = await viewModel.addGpsAddress();
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                AppSnackBar.showSuccess(context, 'Posisi terdeteksi otomatis via Real GPS Browser/Device!');
                              }
                            }
                          },
                          icon: const Icon(Icons.my_location, color: Colors.white),
                          label: const Text('Lokasi Saya Saat Ini (GPS Akurat)', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0007B0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Button 2: Switch to Inline Manual Address Form
                        OutlinedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              isAddingManual = true;
                            });
                          },
                          icon: const Icon(Icons.add_location_alt, color: Color(0xFF0007B0)),
                          label: const Text('+ Tambah Alamat Manual Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0007B0))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF0007B0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Daftar Alamat Tersimpan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),

                        // Address Cards List
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            itemCount: viewModel.addresses.length,
                            itemBuilder: (context, index) {
                              final addr = viewModel.addresses[index];
                              final isSelected = viewModel.selectedAddress?.id == addr.id;

                              return GestureDetector(
                                onTap: () {
                                  viewModel.selectAddress(addr);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: isSelected ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
                                        child: Icon(Icons.location_on, color: isSelected ? Colors.white : Colors.black45),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              addr.receiverName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B1739)),
                                            ),
                                            Text(
                                              addr.fullAddress,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle, color: Color(0xFF0007B0)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ] else ...[
                        // MODE 2: SLEEK MODERN INLINE ADDRESS FORM (NO POPUP DIALOG)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
                              onPressed: () {
                                setModalState(() {
                                  isAddingManual = false;
                                });
                              },
                            ),
                            const Text(
                              'Formulir Alamat Baru',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nama Label / Penerima',
                            hintText: 'Misal: Rumah Bandung, Kos Sukabirus',
                            prefixIcon: const Icon(Icons.bookmark_outline, color: Color(0xFF0007B0)),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon',
                            hintText: '+6281234567890',
                            prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF0007B0)),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: streetCtrl,
                          decoration: InputDecoration(
                            labelText: 'Alamat Lengkap & Jalan',
                            hintText: 'Misal: Jl. Sukabirus No. 42, Bojongsoang',
                            prefixIcon: const Icon(Icons.home_outlined, color: Color(0xFF0007B0)),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesCtrl,
                          decoration: InputDecoration(
                            labelText: 'Catatan Patokan (Opsional)',
                            hintText: 'Misal: Pagar Hitam Sebelah Minimarket',
                            prefixIcon: const Icon(Icons.notes_outlined, color: Color(0xFF0007B0)),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: () async {
                            if (nameCtrl.text.trim().isEmpty || streetCtrl.text.trim().isEmpty) {
                              AppSnackBar.showError(context, 'Nama penerima dan alamat lengkap wajib diisi');
                              return;
                            }
                            final success = await viewModel.addManualAddress(
                              receiverName: nameCtrl.text.trim(),
                              phoneNumber: phoneCtrl.text.trim(),
                              streetName: streetCtrl.text.trim(),
                              notes: notesCtrl.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                AppSnackBar.showSuccess(context, 'Alamat baru berhasil disimpan!');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0007B0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Simpan & Gunakan Alamat Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog Input Custom Item
  void _showAddCustomItemDialog(BuildContext context, OrderViewModel viewModel) {
    final itemCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Item Cucian Khusus', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
          content: TextField(
            controller: itemCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ketik nama barang (misal: Gorden 2m, Sepatu Canvas)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final item = itemCtrl.text.trim();
                if (item.isNotEmpty) {
                  viewModel.addCustomItem(item);
                  Navigator.pop(context);
                  AppSnackBar.showSuccess(context, 'Item "$item" ditambahkan!');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0007B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tambah'),
            )
          ],
        );
      },
    );
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

              // 1. Address selector button
              GestureDetector(
                onTap: () => _showAddressModal(context, viewModel),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE6F0FF),
                        child: Icon(Icons.location_on, color: Color(0xFF0007B0)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.selectedAddress?.receiverName ?? 'Pilih Alamat',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              viewModel.selectedAddress?.fullAddress ?? 'Ketuk untuk memilih / menambah alamat',
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

              // 2. Phone number & Dynamic Promo button
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
                          Expanded(
                            child: Text(
                              viewModel.selectedAddress?.phoneNumber ?? '+6281234567890',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showPromoSelectorModal(context, viewModel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: viewModel.selectedPromo != null ? const Color(0xFFDCFCE7) : const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: viewModel.selectedPromo != null ? const Color(0xFF166534) : const Color(0xFF0007B0).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            viewModel.selectedPromo != null ? Icons.confirmation_number : Icons.add,
                            color: viewModel.selectedPromo != null ? const Color(0xFF166534) : const Color(0xFF0007B0),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            viewModel.selectedPromo != null
                                ? '🏷️ ${viewModel.selectedPromo!['code']}'
                                : 'Promo',
                            style: TextStyle(
                              color: viewModel.selectedPromo != null ? const Color(0xFF166534) : const Color(0xFF0007B0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (viewModel.selectedPromo != null) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => viewModel.selectPromo(null),
                              child: const Icon(Icons.cancel, color: Color(0xFF166534), size: 14),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Services Row Selector
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
                                top: 0,
                                right: 0,
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

              // 4. Flexible Item tags selection grid (Preset + Custom Input)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Item Cucian (Satuan)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                  ),
                  GestureDetector(
                    onTap: () => _showAddCustomItemDialog(context, viewModel),
                    child: const Text(
                      '+ Custom Item',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0007B0)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...[
                    'Selimut', 'Bedcover', 'Sprei', 'Kemeja', 'Jas', 'Kebaya', 'Dress', 'Karpet Bulu', 'Boneka(S)', 'Boneka(L)'
                  ],
                  ...viewModel.selectedItems.where((i) => ![
                        'Selimut', 'Bedcover', 'Sprei', 'Kemeja', 'Jas', 'Kebaya', 'Dress', 'Karpet Bulu', 'Boneka(S)', 'Boneka(L)'
                      ].contains(i))
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
                  if (viewModel.isLoading) return;
                  setState(() {
                    _swipeAlign += details.primaryDelta! / 250.0;
                    if (_swipeAlign < 0.0) _swipeAlign = 0.0;
                    if (_swipeAlign > 1.0) _swipeAlign = 1.0;
                  });
                },
                onHorizontalDragEnd: (details) async {
                  if (viewModel.isLoading) return;
                  if (_swipeAlign > 0.75) {
                    setState(() {
                      _swipeAlign = 1.0;
                    });
                    final success = await viewModel.submitOrder();
                    if (success) {
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
                      Center(
                        child: Text(
                          viewModel.isLoading ? 'Memproses Pesanan...' : 'Geser Untuk Pemesanan',
                          style: const TextStyle(
                            color: Color(0xFF0007B0),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      // Sliding Circle Knob with arrow or loading indicator
                      Align(
                        alignment: Alignment(_swipeAlign * 2.0 - 1.0, 0),
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0007B0),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x330007B0),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: viewModel.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 28,
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Searching Courier & Success Celebration Screen Overlay View
  Widget _buildFindingCourierScreen(BuildContext context, OrderViewModel viewModel) {
    return _FindingCourierOverlay(
      onClose: () {
        viewModel.setFindingCourier(false);
        Navigator.pop(context);
      },
    );
  }
}

class _FindingCourierOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _FindingCourierOverlay({required this.onClose});

  @override
  State<_FindingCourierOverlay> createState() => _FindingCourierOverlayState();
}

class _FindingCourierOverlayState extends State<_FindingCourierOverlay> {
  bool _isMatched = false;

  @override
  void initState() {
    super.initState();
    // Simulate finding courier match after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isMatched = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isMatched ? 'Pesanan Berhasil! 🎉' : 'Mencari Kurir...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1739),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black45),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const Spacer(),

          if (!_isMatched) ...[
            // Phase 1: Radar / Scooter Searching Animation
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _ScooterCourierPainter(),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Sedang Mencocokkan Kurir',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B1739),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sistem kami sedang menghubungkan pesanan Anda dengan armada kurir terdekat. Mohon tunggu sebentar...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF0007B0),
              strokeWidth: 4,
            ),
          ] else ...[
            // Phase 2: Success Celebration Animation
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCFCE7),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 90,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Pesanan Berhasil Dibuat!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B1739),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kurir terdekat telah menerima pesanan Anda dan siap menuju ke lokasi penjemputan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],

          const Spacer(),

          if (_isMatched)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF0007B0).withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Lihat Status Pesanan Saya',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Batalkan Pencarian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
      ..quadraticBezierTo(center.dx, center.dy - 10, center.dx + 25, center.dy + 10);
    canvas.drawPath(path, scooterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
