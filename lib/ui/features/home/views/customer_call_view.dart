import 'dart:async';
import 'package:flutter/material.dart';

class CustomerCallView extends StatefulWidget {
  const CustomerCallView({super.key});

  @override
  State<CustomerCallView> createState() => _CustomerCallViewState();
}

class _CustomerCallViewState extends State<CustomerCallView> {
  bool _isSpeakerOn = false;
  bool _isMuted = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 64),
            // Outgoing call status
            const Text(
              'Menghubungi...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Surwanto',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1739),
              ),
            ),
            const SizedBox(height: 12),
            // Call duration timer
            Text(
              _formatDuration(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
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
                child: const Text(
                  'S',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 64),
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
              ],
            ),
            const SizedBox(height: 48),

            // Red End Call Button
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
