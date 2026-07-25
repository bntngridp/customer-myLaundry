import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'reset_password_view.dart';
import '../../../shared/widgets/app_snackbar.dart';

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _cooldownSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  void _startCooldownTimer([int seconds = 60]) {
    _timer?.cancel();
    setState(() {
      _cooldownSeconds = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          viewModel.translate('Kode Verifikasi'),
          style: const TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
                    width: 180,
                    height: 150,
                    child: CustomPaint(
                      painter: _EmailFlyingPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Text.rich(
                  TextSpan(
                    text: viewModel.translate('Masukkan 6 digit kode OTP yang dikirimkan ke\n'),
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
                const SizedBox(height: 28),

                // 6 OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 46,
                      height: 54,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0007B0),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFE6F0FF),
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0007B0), width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
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
                const SizedBox(height: 28),

                // Resend OTP Link
                Center(
                  child: Column(
                    children: [
                      Text(
                        viewModel.translate('Kode belum masuk?'),
                        style: const TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _cooldownSeconds > 0 || viewModel.isLoading
                            ? null
                            : () async {
                                final success = await viewModel.sendForgotPassword(targetEmail);
                                if (success && context.mounted) {
                                  AppSnackBar.showSuccess(context, 'Kode OTP berhasil dikirim ulang');
                                  _startCooldownTimer(60);
                                } else if (context.mounted && viewModel.errorMessage != null) {
                                  AppSnackBar.showError(context, viewModel.errorMessage!);
                                }
                              },
                        child: Text(
                          _cooldownSeconds > 0
                              ? 'Kirim Ulang ($_cooldownSeconds s)'
                              : viewModel.translate('Kirim Ulang'),
                          style: TextStyle(
                            fontSize: 14,
                            color: _cooldownSeconds > 0 ? Colors.black38 : const Color(0xFF0007B0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (viewModel.errorMessage != null && viewModel.errorMessage!.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.priority_high_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Verify Button
                ElevatedButton(
                  onPressed: viewModel.isLoading || _getOtpString().length != 6
                      ? null
                      : () async {
                          final success = await viewModel.submitVerifyOtp(_getOtpString());
                          if (success && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ResetPasswordView()),
                            );
                          } else if (context.mounted && viewModel.errorMessage != null) {
                            AppSnackBar.showError(context, viewModel.errorMessage!);
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
                      : Text(
                          viewModel.translate('Verifikasi'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
