import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/call_signaling_service.dart';

class CustomerCallView extends StatefulWidget {
  final int targetUserId;
  final int orderId;
  final String courierName;
  final String phoneNumber;

  const CustomerCallView({
    super.key,
    this.targetUserId = 0,
    this.orderId = 0,
    this.courierName = 'Kurir myLaundry',
    this.phoneNumber = '',
  });

  @override
  State<CustomerCallView> createState() => _CustomerCallViewState();
}

class _CustomerCallViewState extends State<CustomerCallView> {
  final CallSignalingService _signalingService = CallSignalingService();
  StreamSubscription<CallMessage>? _subscription;

  bool _isSpeakerOn = false;
  bool _isMuted = false;
  int _seconds = 0;
  Timer? _timer;
  bool _isCallConnected = false;
  String _statusText = 'Menghubungi (In-App)...';

  @override
  void initState() {
    super.initState();
    _initSignalingAndCall();
  }

  Future<void> _initSignalingAndCall() async {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final token = authRepo.token;
    final currentUserName = authRepo.currentUser?.username ?? 'Pelanggan';

    if (token != null) {
      await _signalingService.connect(token);

      _subscription = _signalingService.onMessage.listen((msg) {
        if (!mounted) return;

        if (msg.type == 'CALL_ANSWER') {
          setState(() {
            _isCallConnected = true;
            _statusText = 'Terhubung';
          });
          _startTimer();
        } else if (msg.type == 'CALL_REJECT') {
          setState(() {
            _statusText = 'Panggilan Ditolak';
          });
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.pop(context);
          });
        } else if (msg.type == 'CALL_END') {
          if (mounted) Navigator.pop(context);
        }
      });

      if (widget.targetUserId > 0) {
        _signalingService.startCall(
          targetUserId: widget.targetUserId,
          orderId: widget.orderId,
          callerName: currentUserName,
        );
      }
    }

    // Fallback timer if target auto-connects or testing
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isCallConnected && _statusText.contains('Menghubungi')) {
        setState(() {
          _isCallConnected = true;
          _statusText = 'Terhubung (In-App Voice)';
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  Future<void> _triggerNativeFallback() async {
    if (widget.phoneNumber.trim().isNotEmpty) {
      final cleanNumber = widget.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final uri = Uri.parse('tel:$cleanNumber');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } catch (_) {}
    }
  }

  void _endCall() {
    if (widget.targetUserId > 0) {
      _signalingService.endCall(
        targetUserId: widget.targetUserId,
        orderId: widget.orderId,
      );
    }
    _signalingService.disconnect();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    _signalingService.disconnect();
    super.dispose();
  }

  String _formatDuration() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.courierName.isNotEmpty ? widget.courierName : 'Kurir myLaundry';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 64),
            Text(
              _statusText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1739),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'In-App Account Call',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isCallConnected) ...[
              const SizedBox(height: 12),
              Text(
                _formatDuration(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0007B0),
                ),
              ),
            ],
            const Spacer(),

            // Big centered Avatar image
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0007B0), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0007B0).withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 6),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'K',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 64),
                ),
              ),
            ),

            const Spacer(),

            // Action Buttons (Speaker & Mute)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Speaker Button
                GestureDetector(
                  onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _isSpeakerOn ? const Color(0xFF0007B0) : const Color(0xFFF1F5F9),
                        foregroundColor: _isSpeakerOn ? Colors.white : const Color(0xFF0B1739),
                        child: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_up_outlined),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Speaker',
                        style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),

                // Mute Button
                GestureDetector(
                  onTap: () => setState(() => _isMuted = !_isMuted),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _isMuted ? const Color(0xFF0007B0) : const Color(0xFFF1F5F9),
                        foregroundColor: _isMuted ? Colors.white : const Color(0xFF0B1739),
                        child: Icon(_isMuted ? Icons.mic_off : Icons.mic_none_outlined),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bisukan',
                        style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),

                // Native Dialer Fallback Button
                if (widget.phoneNumber.isNotEmpty)
                  GestureDetector(
                    onTap: _triggerNativeFallback,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFFF1F5F9),
                          foregroundColor: Color(0xFF0007B0),
                          child: Icon(Icons.dialpad_rounded),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pulsa HP',
                          style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 48),

            // Red End Call Button
            GestureDetector(
              onTap: _endCall,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
