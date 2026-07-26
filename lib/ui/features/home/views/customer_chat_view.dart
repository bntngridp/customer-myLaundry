import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/chat_service.dart';
import '../../../../domain/models/chat_message.dart';
import 'customer_call_view.dart';

class CustomerChatView extends StatefulWidget {
  final int orderId;
  final String courierName;
  final String phoneNumber;

  const CustomerChatView({
    super.key,
    this.orderId = 0,
    this.courierName = 'Kurir myLaundry',
    this.phoneNumber = '',
  });

  @override
  State<CustomerChatView> createState() => _CustomerChatViewState();
}

class _CustomerChatViewState extends State<CustomerChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final ImagePicker _picker = ImagePicker();

  List<ChatMessageModel> _messages = [];
  bool _isLoadingMessages = true;
  bool _isSending = false;
  Timer? _pollTimer;

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    // Poll for new chat messages every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages(silent: true));
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final token = authRepo.token;
    if (token == null || widget.orderId == 0) {
      if (mounted && !silent) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
      return;
    }

    try {
      final fetched = await _chatService.getOrderChatMessages(
        orderId: widget.orderId,
        token: token,
      );
      if (mounted) {
        final bool hadNew = fetched.length > _messages.length;
        setState(() {
          _messages = fetched;
          _isLoadingMessages = false;
        });
        if (hadNew) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      }
    } catch (_) {
      if (mounted && !silent) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
    }
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final token = authRepo.token;
    if (token == null || widget.orderId == 0) return;

    setState(() {
      _isSending = true;
    });

    try {
      final newMsg = await _chatService.sendChatMessage(
        orderId: widget.orderId,
        message: text,
        token: token,
      );
      _messageController.clear();
      if (mounted) {
        setState(() {
          _messages.add(newMsg);
          _isSending = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _pickAndSendMedia(ImageSource source, {bool isVideo = false}) async {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final token = authRepo.token;
    if (token == null || widget.orderId == 0) return;

    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(source: source);
      } else {
        file = await _picker.pickImage(source: source, imageQuality: 70);
      }

      if (file == null || !mounted) return;

      setState(() {
        _isSending = true;
      });

      final bytes = await file.readAsBytes();
      final mimeType = isVideo ? 'video/mp4' : 'image/jpeg';
      final base64Data = 'data:$mimeType;base64,${base64Encode(bytes)}';

      final msgType = isVideo ? 'VIDEO' : 'IMAGE';
      final captionText = isVideo ? '📹 Video Pesanan' : '📷 Foto Pesanan';

      final newMsg = await _chatService.sendChatMessage(
        orderId: widget.orderId,
        message: captionText,
        imageUrl: base64Data,
        messageType: msgType,
        token: token,
      );

      if (mounted) {
        setState(() {
          _messages.add(newMsg);
          _isSending = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim media: $e')),
        );
      }
    }
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kirim Lampiran Media',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMediaOptionItem(
                      icon: Icons.camera_alt_rounded,
                      color: const Color(0xFF2563EB),
                      label: 'Foto Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndSendMedia(ImageSource.camera);
                      },
                    ),
                    _buildMediaOptionItem(
                      icon: Icons.photo_library_rounded,
                      color: const Color(0xFF10B981),
                      label: 'Foto Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndSendMedia(ImageSource.gallery);
                      },
                    ),
                    _buildMediaOptionItem(
                      icon: Icons.videocam_rounded,
                      color: const Color(0xFF8B5CF6),
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndSendMedia(ImageSource.gallery, isVideo: true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaOptionItem({
    required IconData icon,
    required Color color,
    required String label,
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0B1739)),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _recordSeconds++;
        });
      }
    });
  }

  Future<void> _stopAndSendRecording() async {
    _recordTimer?.cancel();
    final durationStr = _formatDuration(_recordSeconds);
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final token = authRepo.token;
    if (token == null || widget.orderId == 0) return;

    try {
      final newMsg = await _chatService.sendChatMessage(
        orderId: widget.orderId,
        message: '🎙️ Pesan Suara ($durationStr)',
        token: token,
      );
      if (mounted) {
        setState(() {
          _messages.add(newMsg);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (_) {}
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
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

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _recordTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final currentUserId = authRepo.currentUser?.id;
    final name = widget.courierName.isNotEmpty ? widget.courierName : 'Kurir myLaundry';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0007B0), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'K',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
                  ),
                  Text(
                    widget.orderId > 0 ? 'Pesanan #${widget.orderId}' : 'Kurir Aktif',
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: _isLoadingMessages
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.black26),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada pesan.',
                                style: TextStyle(color: Colors.black45, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kirim pesan ke $name',
                                style: const TextStyle(color: Colors.black38, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = (msg.senderRole == 'customer') ||
                                (currentUserId != null && msg.senderId == currentUserId);
                            final isAudio = msg.message.contains('🎙️ Pesan Suara');
                            final isImage = msg.messageType == 'IMAGE' ||
                                msg.messageType == 'DELIVERY_PROOF' ||
                                (msg.imageUrl.startsWith('data:image') || msg.imageUrl.startsWith('http'));
                            final isVideo = msg.messageType == 'VIDEO' || msg.imageUrl.startsWith('data:video');

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                padding: isImage || isVideo
                                    ? const EdgeInsets.all(6)
                                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xFF0007B0) : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 16),
                                  ),
                                  border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: isAudio
                                    ? _buildAudioBubble(msg, index, isMe)
                                    : isImage
                                        ? _buildImageBubble(msg, isMe)
                                        : isVideo
                                            ? _buildVideoBubble(msg, isMe)
                                            : Column(
                                                crossAxisAlignment:
                                                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    msg.message,
                                                    style: TextStyle(
                                                      color: isMe ? Colors.white : const Color(0xFF0B1739),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _formatTime(msg.sentAt),
                                                    style: TextStyle(
                                                      color: isMe ? Colors.white70 : Colors.black38,
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

            // Message Input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: _isRecording ? _buildRecordingBar() : _buildStandardInputBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageBubble(ChatMessageModel message, bool isMe) {
    Widget imageWidget;
    if (message.imageUrl.startsWith('data:image')) {
      try {
        final base64Str = message.imageUrl.split(',').last;
        final Uint8List bytes = base64Decode(base64Str);
        imageWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        imageWidget = const Icon(Icons.broken_image, size: 48, color: Colors.grey);
      }
    } else if (message.imageUrl.startsWith('http')) {
      imageWidget = Image.network(message.imageUrl, fit: BoxFit.cover);
    } else {
      imageWidget = Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: const [
            Icon(Icons.image, color: Colors.white),
            SizedBox(width: 8),
            Text('Foto Pesanan', style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 220),
            width: double.infinity,
            child: imageWidget,
          ),
        ),
        if (message.message.isNotEmpty && !message.message.startsWith('📷 Foto'))
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
            child: Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF0B1739),
                fontSize: 13,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 6, left: 6),
          child: Text(
            _formatTime(message.sentAt),
            style: TextStyle(
              color: isMe ? Colors.white70 : Colors.black38,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoBubble(ChatMessageModel message, bool isMe) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.play_circle_fill_rounded, size: 48, color: Colors.white70),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.videocam, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Video Pesanan', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 6, left: 6),
          child: Text(
            _formatTime(message.sentAt),
            style: TextStyle(
              color: isMe ? Colors.white70 : Colors.black38,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBubble(ChatMessageModel msg, int index, bool isMe) {
    final isPlaying = _playingIndex == index;
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                  color: isMe ? Colors.white : const Color(0xFF0007B0),
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isMe ? const Color(0xFF0007B0) : Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              msg.message,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF0B1739),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _formatTime(msg.sentAt),
          style: TextStyle(
            color: isMe ? Colors.white60 : Colors.black38,
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
        IconButton(
          icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF0007B0), size: 26),
          onPressed: _showMediaPickerOptions,
          tooltip: 'Kirim Gambar/Video',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: _messageController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Ketik pesan...',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _messageController.text.trim().isEmpty
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
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _sendMessage,
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE6F0FF),
            foregroundColor: const Color(0xFF0007B0),
            child: _isSending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerCallView(
                  phoneNumber: widget.phoneNumber,
                  courierName: widget.courierName,
                ),
              ),
            );
          },
          child: const CircleAvatar(
            backgroundColor: Color(0xFF0007B0),
            foregroundColor: Colors.white,
            child: Icon(Icons.phone, size: 18),
          ),
        )
      ],
    );
  }
}
