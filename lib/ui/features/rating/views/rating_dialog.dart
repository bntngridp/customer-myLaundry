import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/rating_view_model.dart';

class RatingDialog extends StatefulWidget {
  final String orderId;

  const RatingDialog({super.key, required this.orderId});

  static Future<void> show(BuildContext context, String orderId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingDialog(orderId: orderId),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingViewModel>().resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final ratingVm = Provider.of<RatingViewModel>(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authViewModel.translate('Beri Ulasan Laundry'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1739),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order #${widget.orderId}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rating Kurir
            Text(
              authViewModel.translate('Rating Kurir Pelayanan'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 8),
            _buildStarRating(
              score: ratingVm.courierScore,
              onChanged: (score) => ratingVm.setCourierScore(score),
            ),
            const SizedBox(height: 20),

            // Rating Cabang / Outlet
            Text(
              authViewModel.translate('Rating Hasil Cucian Cabang'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 8),
            _buildStarRating(
              score: ratingVm.branchScore,
              onChanged: (score) => ratingVm.setBranchScore(score),
            ),
            const SizedBox(height: 20),

            // Tags Pilihan Cepat
            Text(
              authViewModel.translate('Apa yang kamu suka?'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ratingVm.availableTags.map((tag) {
                final isSelected = ratingVm.selectedTags.contains(tag);
                return FilterChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0007B0),
                  backgroundColor: const Color(0xFFF1F5F9),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (_) => ratingVm.toggleTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Catatan Text Ulasan
            Text(
              authViewModel.translate('Catatan Ulasan (Opsional)'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ratingVm.reviewController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: authViewModel.translate('Ceritakan pengalaman kamu menggunakan layanan myLaundry...'),
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF0007B0)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ratingVm.isSubmitting
                    ? null
                    : () async {
                        final success = await ratingVm.submitRating(widget.orderId);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authViewModel.translate('Terima kasih atas ulasannya! 🎉✨')),
                              backgroundColor: const Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: ratingVm.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        authViewModel.translate('Kirim Ulasan'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating({required double score, required Function(double) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFilled = score >= starValue;
        return IconButton(
          icon: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
            size: 32,
          ),
          padding: const EdgeInsets.only(right: 6),
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(starValue),
        );
      }),
    );
  }
}
