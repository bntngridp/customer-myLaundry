import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/app_snackbar.dart';
import 'payment_confirmation_view.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});

  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  // Selection state parameters
  String _selectedMethod = 'Virtual Account'; // 'Cash', 'QRIS', 'Virtual Account'
  String _selectedBank = 'Mandiri'; // 'Mandiri', 'BCA', 'BNI', 'BRI', 'Permata'
  
  // Transition state: false = Selection screen, true = Instruction screen
  bool _showInstructions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () {
            if (_showInstructions) {
              setState(() {
                _showInstructions = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _showInstructions ? 'Detail Pembayaran' : 'Metode Pembayaran',
          style: const TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _showInstructions ? _buildInstructionDetails() : _buildSelectionForm(),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom action button
              ElevatedButton(
                onPressed: () {
                  if (!_showInstructions) {
                    setState(() {
                      _showInstructions = true;
                    });
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentConfirmationView()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _showInstructions ? 'Saya Sudah Membayar' : 'Lanjut ke Pembayaran',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
          ),
          const SizedBox(height: 16),
          
          // Method Tab Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Cash', 'QRIS', 'Virtual Account'].map((method) {
              final isSel = _selectedMethod == method;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(method),
                    selected: isSel,
                    selectedColor: const Color(0xFF0007B0),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedMethod = method;
                        });
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Bank list row if VA selected
          if (_selectedMethod == 'Virtual Account') ...[
            const Text(
              'Jenis Bank',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Mandiri', 'BCA', 'BNI', 'BRI', 'Permata'].map((bank) {
                final isSel = _selectedBank == bank;
                return ChoiceChip(
                  label: Text(bank),
                  selected: isSel,
                  selectedColor: const Color(0xFF0007B0),
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  showCheckmark: false,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedBank = bank;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Total display field
          const Text(
            'Jumlah',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Text('Rp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black38)),
                SizedBox(width: 8),
                Text(
                  '55.000',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInstructionDetails() {
    if (_selectedMethod == 'Cash') {
      return _buildCashInstructions();
    } else if (_selectedMethod == 'QRIS') {
      return _buildQrisInstructions();
    } else {
      return _buildVaInstructions();
    }
  }

  Widget _buildCashInstructions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0007B0),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bayarkan pada Kurir Kami',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Total',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'Rp55.000,00',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Ref. ID: 51670\nBerlaku Sampai 9/10/2024 12:19:49 WIB',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 9, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Silakan siapkan uang tunai sejumlah Rp55.000,00 dan serahkan kepada kurir myLaundry saat pakaian diantarkan ke lokasi Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
        )
      ],
    );
  }

  Widget _buildQrisInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QRIS & GPN header logos
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QRIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              Icon(Icons.qr_code_scanner, color: Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Column(
              children: [
                Text(
                  'PT Laundry bersih',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                ),
                Text(
                  'NMID : ID3858278957',
                  style: TextStyle(fontSize: 10, color: Colors.black38),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Custom Paint QR Code representation
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _QrisPatternPainter(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Total',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black38, fontSize: 11),
          ),
          const Text(
            'Rp55.000,00',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF0007B0), fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ref. ID: 51676\nBerlaku Sampai 9/10/2024 12:19:49 WIB',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black38, fontSize: 9, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildVaInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bank Logo Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bank $_selectedBank',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B1739)),
                ),
                Text(
                  _selectedBank.toLowerCase(),
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0007B0),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Company Code copy
          _buildCopyRow('Kode Perusahaan', '12345'),
          const SizedBox(height: 16),

          // VA Number copy
          _buildCopyRow('Virtual Account', '8099892716382'),
          const SizedBox(height: 24),

          const Text(
            'Total',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black38, fontSize: 11),
          ),
          const Text(
            'Rp55.000,00',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF0007B0), fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ref. ID: 54676\nBerlaku Sampai 9/10/2024 12:19:49 WIB',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black38, fontSize: 9, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow(String label, String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  AppSnackBar.showSuccess(context, '$label berhasil disalin');
                },
                child: const Icon(Icons.copy, color: Color(0xFF0007B0), size: 18),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _QrisPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B1739)
      ..style = PaintingStyle.fill;

    // Draw QR Code outer frame positioning boxes (Top-Left, Top-Right, Bottom-Left)
    canvas.drawRect(const Rect.fromLTWH(0, 0, 40, 40), paint);
    canvas.drawRect(const Rect.fromLTWH(6, 6, 28, 28), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(14, 14, 12, 12), paint);

    canvas.drawRect(Rect.fromLTWH(size.width - 40, 0, 40, 40), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 34, 6, 28, 28), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 26, 14, 12, 12), paint);

    canvas.drawRect(Rect.fromLTWH(0, size.height - 40, 40, 40), paint);
    canvas.drawRect(Rect.fromLTWH(6, size.height - 34, 28, 28), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(14, size.height - 26, 12, 12), paint);

    // Draw random tiny square pixels to represent QR code pattern
    final randomPaint = Paint()
      ..color = const Color(0xFF0B1739)
      ..style = PaintingStyle.fill;

    // Center/internal blocks representation
    canvas.drawRect(const Rect.fromLTWH(60, 20, 15, 15), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(80, 10, 10, 25), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(110, 30, 20, 10), randomPaint);
    
    canvas.drawRect(const Rect.fromLTWH(20, 60, 25, 15), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(55, 60, 20, 20), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(90, 50, 15, 35), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(120, 70, 30, 15), randomPaint);
    
    canvas.drawRect(const Rect.fromLTWH(60, 110, 40, 10), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(50, 130, 15, 25), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(80, 140, 35, 15), randomPaint);
    canvas.drawRect(const Rect.fromLTWH(130, 110, 20, 40), randomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
