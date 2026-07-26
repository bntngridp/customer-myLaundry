import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/call_signaling_service.dart';

class ReturnCallView extends StatefulWidget {
  final int targetUserId;
  final int orderId;
  final String courierName;
  final String phoneNumber;

  const ReturnCallView({
    super.key,
    this.targetUserId = 0,
    this.orderId = 0,
    this.courierName = 'Kurir myLaundry',
    this.phoneNumber = '',
  });

  @override
  State<ReturnCallView> createState() => _ReturnCallViewState();
}

class _ReturnCallViewState extends State<ReturnCallView> {
  final CallSignalingService _signalingService = CallSignalingService();
  StreamSubscription<CallMessage>? _subscription;

  bool _isMuted = false;
  bool _isSpeaker = false;
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

    // Fallback: auto-connect after 3s for demo/testing
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
      if (mounted) setState(() => _seconds++);
    });
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _statusText,
              style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 6),
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
            const SizedBox(height: 32),

            // Avatar (initial-based, no external network image)
            Center(
              child: Container(
                width: 130,
                height: 130,
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
                      blurRadius: 25,
                      spreadRadius: 5,
                    )
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'K',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 52,
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallControl(
                  icon: _isSpeaker ? Icons.volume_up : Icons.volume_up_outlined,
                  label: 'Speaker',
                  active: _isSpeaker,
                  onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                ),
                _buildCallControl(
                  icon: _isMuted ? Icons.mic_off : Icons.mic_none_outlined,
                  label: 'Bisukan',
                  active: _isMuted,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Hang up button
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
                child: const Icon(Icons.call_end, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControl({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0007B0) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : const Color(0xFF0B1739),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
          )
        ],
      ),
    );
  }
}
