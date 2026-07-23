import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/promo_service.dart';
import '../../../shared/widgets/app_snackbar.dart';

class PromoListView extends StatefulWidget {
  const PromoListView({super.key});

  @override
  State<PromoListView> createState() => _PromoListViewState();
}

class _PromoListViewState extends State<PromoListView> {
  final PromoService _promoService = PromoService();
  bool _isLoading = true;
  List<Map<String, String>> _promos = [];

  @override
  void initState() {
    super.initState();
    _fetchPromos();
  }

  Future<void> _fetchPromos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _promoService.getPromos();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'];
          setState(() {
            _promos = list.map<Map<String, String>>((item) {
              return {
                'title': item['title']?.toString() ?? 'Promo Spesial',
                'subtitle': item['subtitle']?.toString() ?? 'Gunakan kode promo saat checkout',
                'code': item['code']?.toString() ?? 'PROMO',
              };
            }).toList();
          });
        }
      }
    } catch (_) {
      // Fallback promo data if offline
      _promos = [
        {
          'title': 'Dapatkan Diskon 30%',
          'subtitle': 'Hingga Rp5.000 untuk semua layanan',
          'code': 'BersihTanpaPusing',
        },
        {
          'title': 'Dapatkan Diskon 50%',
          'subtitle': 'Hingga Rp10.000 untuk cucian kiloan',
          'code': 'CucianWangi',
        },
        {
          'title': 'Free Delivery Promo',
          'subtitle': 'Khusus pengguna baru myLaundry',
          'code': 'MulaiLaundry',
        },
      ];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Promo & Voucher',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0007B0)),
              )
            : RefreshIndicator(
                onRefresh: _fetchPromos,
                color: const Color(0xFF0007B0),
                child: _promos.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada promo aktif.',
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: _promos.length,
                        itemBuilder: (context, index) {
                          final promo = _promos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0B1739), Color(0xFF0007B0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0007B0).withValues(alpha: 0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  promo['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  promo['subtitle']!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        promo['code']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: promo['code']!));
                                        AppSnackBar.showSuccess(context, 'Kode promo berhasil disalin!');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF0007B0),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text(
                                        'Salin Kode',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
