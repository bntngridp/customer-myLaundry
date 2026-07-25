import 'package:flutter/material.dart';
import '../../../../data/repositories/rating_repository.dart';
import '../../../../domain/models/order.dart';
import '../../../shared/widgets/app_snackbar.dart';

class RateOrderModal extends StatefulWidget {
  final OrderModel order;
  final RatingRepository ratingRepository;
  final String token;

  const RateOrderModal({
    super.key,
    required this.order,
    required this.ratingRepository,
    required this.token,
  });

  @override
  State<RateOrderModal> createState() => _RateOrderModalState();
}

class _RateOrderModalState extends State<RateOrderModal> {
  double _courierScore = 5.0;
  double _branchScore = 5.0;

  final Set<String> _selectedTags = {};
  final TextEditingController _reviewTextController = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _availableTags = [
    '⚡ Kurir Cepat & Ramah',
    '👔 Cucian Rapi & Wangi',
    '🚚 Pengantaran Tepat Waktu',
    '😊 Pelayanan Sangat Baik',
    '⚠️ Kurir Kurang Sopan',
    '⏳ Pengantaran Terlambat',
  ];

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    try {
      final tagsString = _selectedTags.join(', ');
      await widget.ratingRepository.submitRating(
        orderId: widget.order.id.toString(),
        courierScore: _courierScore,
        branchScore: _branchScore,
        tags: tagsString,
        reviewText: _reviewTextController.text.trim(),
        token: widget.token,
      );

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Terima kasih atas ulasan & rating Anda!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        AppSnackBar.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String orderIdStr = widget.order.id.toString();
    final String courierNameStr = widget.order.courier?.username ?? 'Kurir Penjemput';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Color(0xFF0007B0), size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Beri Ulasan & Rating Pesanan #$orderIdStr',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1739),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bagaimana pengalaman Anda menggunakan layanan myLaundry?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Courier Rating
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: Color(0xFF0007B0), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Rating Kurir ($courierNameStr)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1739)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: _buildStarRatingBar(
                      score: _courierScore,
                      onChanged: (val) => setState(() => _courierScore = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: Branch Rating
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, color: Color(0xFF0007B0), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Rating Cabang & Hasil Cucian',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1739)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: _buildStarRatingBar(
                      score: _branchScore,
                      onChanged: (val) => setState(() => _branchScore = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Quick Tag Chips
            const Text(
              'Pilih Tambahan Komentar / Catatan:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                final isNegative = tag.contains('Tidak') || tag.contains('Terlambat');

                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: isNegative ? const Color(0xFFFEE2E2) : const Color(0xFFEEF2FF),
                  checkmarkColor: isNegative ? const Color(0xFFEF4444) : const Color(0xFF0007B0),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? (isNegative ? const Color(0xFFEF4444) : const Color(0xFF0007B0))
                        : const Color(0xFFE2E8F0),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (isNegative ? const Color(0xFF991B1B) : const Color(0xFF0007B0))
                        : const Color(0xFF0B1739),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Section 4: Freeform Review
            const Text(
              'Tulis Ulasan Lebih Detail (Opsional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reviewTextController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Kurir sangat sopan, cucian bersih wangi lavender...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF0007B0), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0007B0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Kirim Ulasan & Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRatingBar({required double score, required ValueChanged<double> onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = (index + 1).toDouble();
        final isFilled = starValue <= score;

        return IconButton(
          onPressed: () => onChanged(starValue),
          icon: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? const Color(0xFFFFB800) : Colors.black26,
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }
}
