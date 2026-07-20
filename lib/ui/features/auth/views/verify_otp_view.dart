import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'reset_password_view.dart';

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpString() {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    final targetEmail = viewModel.emailForReset ?? 'emailanda@mail.com';

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
          'Kode Verifikasi',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Laptop & flying emails illustration painter
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 180,
                    child: CustomPaint(
                      painter: _EmailFlyingPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                Text.rich(
                  TextSpan(
                    text: 'Masukkan 4 digit kode yang dikirimkan ke\n',
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                    children: [
                      TextSpan(
                        text: targetEmail,
                        style: const TextStyle(
                          color: Color(0xFF0007B0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // 4 OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 64,
                      height: 64,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0007B0),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFE6F0FF),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF0007B0), width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 36),

                // Resend OTP Link
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Kode belum masuk?',
                        style: TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final success = await viewModel.sendForgotPassword(targetEmail);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode OTP berhasil dikirim ulang! ✉️'),
                                backgroundColor: Color(0xFF0007B0),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Kirim Ulang',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0007B0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Verify Button
                ElevatedButton(
                  onPressed: viewModel.isLoading || _getOtpString().length != 4
                      ? null
                      : () async {
                          final success = await viewModel.submitVerifyOtp(_getOtpString());
                          if (success && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ResetPasswordView()),
                            );
                          } else if (context.mounted && viewModel.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(viewModel.errorMessage!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0007B0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Verifikasi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailFlyingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bgPaint = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.fill;

    // Draw background circle
    canvas.drawCircle(center, size.width * 0.35, bgPaint);

    final basePaint = Paint()
      ..color = const Color(0xFF0B1739)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Draw laptop base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, 20), width: 85, height: 45),
        const Radius.circular(8),
      ),
      basePaint,
    );

    // Laptop keyboard base bar
    canvas.drawLine(
      center.translate(-50, 42.5),
      center.translate(50, 42.5),
      Paint()
        ..color = const Color(0xFF0B1739)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round,
    );

    // Draw laptop monitor glass
    canvas.drawCircle(
      center.translate(0, 10),
      15,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill,
    );

    // Draw flying envelope shapes (representing OTP emails)
    final envelopePaint = Paint()
      ..color = const Color(0xFF0007B0)
      ..style = PaintingStyle.fill;
    
    // Tiny envelope 1 (top left)
    canvas.drawRect(Rect.fromLTWH(center.dx - 55, center.dy - 35, 20, 12), envelopePaint);
    // Tiny envelope 2 (top right)
    canvas.drawRect(Rect.fromLTWH(center.dx + 35, center.dy - 25, 20, 12), envelopePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
