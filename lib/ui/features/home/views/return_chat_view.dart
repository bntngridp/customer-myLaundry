import 'dart:async';
import 'package:flutter/material.dart';

class ReturnChatView extends StatefulWidget {
  const ReturnChatView({super.key});

  @override
  State<ReturnChatView> createState() => _ReturnChatViewState();
}

class _ReturnChatViewState extends State<ReturnChatView> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'customer',
      'text': 'Mas barangnya titip sama resepsionis ya',
      'time': '12:05',
      'isAudio': false,
    },
    {
      'sender': 'courier',
      'text': 'Baik, siap kak',
      'time': '12:06',
      'isAudio': false,
    },
    {
      'sender': 'customer',
      'text': 'Tolong apa aja ya mas',
      'time': '12:06',
      'isAudio': false,
    },
  ];

  final TextEditingController _controller = TextEditingController();

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _timer;
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'customer',
        'text': _controller.text.trim(),
        'time': '12:07',
        'isAudio': false,
      });
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _recordSeconds++;
        });
      }
    });
  }

  void _stopAndSendRecording() {
    _timer?.cancel();
    final durationStr = _formatDuration(_recordSeconds);
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
      _messages.add({
        'sender': 'customer',
        'text': 'Pesan Suara',
        'time': '12:07',
        'isAudio': true,
        'audioDuration': durationStr,
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _cancelRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150',
              ),
              radius: 18,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Surwanto',
                  style: TextStyle(color: Color(0xFF0B1739), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kurir Pengantaran • 4 Menit',
                  style: TextStyle(color: Colors.black38, fontSize: 10),
                )
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isCustomer = msg['sender'] == 'customer';
                final isAudio = msg['isAudio'] == true;

                return Align(
                  alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCustomer ? const Color(0xFF0007B0) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isCustomer ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isCustomer ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      border: isCustomer ? null : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: isAudio
                        ? _buildAudioBubble(msg, index, isCustomer)
                        : Column(
                            crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'],
                                style: TextStyle(
                                  color: isCustomer ? Colors.white : const Color(0xFF0B1739),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['time'],
                                style: TextStyle(
                                  color: isCustomer ? Colors.white70 : Colors.black38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
            ),
            child: _isRecording ? _buildRecordingBar() : _buildStandardInputBar(),
          )
        ],
      ),
    );
  }

  Widget _buildAudioBubble(Map<String, dynamic> msg, int index, bool isCustomer) {
    final isPlaying = _playingIndex == index;
    return Column(
      crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_playingIndex == index) {
                    _playingIndex = null;
                  } else {
                    _playingIndex = index;
                  }
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCustomer ? Colors.white : const Color(0xFF0007B0),
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isCustomer ? const Color(0xFF0007B0) : Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Audio Waveform Visualization
            Row(
              children: List.generate(12, (i) {
                final heights = [12.0, 22.0, 16.0, 28.0, 10.0, 24.0, 18.0, 30.0, 14.0, 20.0, 26.0, 12.0];
                final h = heights[i % heights.length];
                final active = isPlaying && (i % 3 == 0);
                return Container(
                  width: 3,
                  height: active ? h + 4 : h,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: isCustomer
                        ? (active ? Colors.white : Colors.white70)
                        : (active ? const Color(0xFF0007B0) : Colors.black26),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(width: 10),
            Text(
              msg['audioDuration']?.toString() ?? '00:05',
              style: TextStyle(
                color: isCustomer ? Colors.white : const Color(0xFF0B1739),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          msg['time']?.toString() ?? 'Just now',
          style: TextStyle(
            color: isCustomer ? Colors.white60 : Colors.black38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 24),
          onPressed: _cancelRecording,
          tooltip: 'Batal Rekam',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordSeconds),
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (i) {
                      final h = (i % 2 == 0) ? 14.0 : 22.0;
                      return Container(
                        width: 3,
                        height: h,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _stopAndSendRecording,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0007B0),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardInputBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Ketik pesan atau rekam suara...',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _controller.text.trim().isEmpty
                  ? IconButton(
                      icon: const Icon(Icons.mic_rounded, color: Color(0xFF0007B0), size: 22),
                      onPressed: _startRecording,
                      tooltip: 'Rekam Suara',
                    )
                  : null,
            ),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _sendMessage,
          child: const CircleAvatar(
            backgroundColor: Color(0xFF0007B0),
            foregroundColor: Colors.white,
            child: Icon(Icons.send, size: 18),
          ),
        ),
      ],
    );
  }
}
