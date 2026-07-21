import 'package:flutter/material.dart';

class ReturnCallView extends StatefulWidget {
  const ReturnCallView({super.key});

  @override
  State<ReturnCallView> createState() => _ReturnCallViewState();
}

class _ReturnCallViewState extends State<ReturnCallView> {
  bool _isMuted = false;
  bool _isSpeaker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Menghubungi...',
              style: TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Surwanto',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 32),

            // Large avatar circle
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150',
                    ),
                    fit: BoxFit.cover,
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
                  onTap: () {
                    setState(() {
                      _isSpeaker = !_isSpeaker;
                    });
                  },
                ),
                _buildCallControl(
                  icon: _isMuted ? Icons.mic_off : Icons.mic_none_outlined,
                  label: 'Mute',
                  active: _isMuted,
                  onTap: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Hang up button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
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
