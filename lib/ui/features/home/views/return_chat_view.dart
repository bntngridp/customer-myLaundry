import 'package:flutter/material.dart';

class ReturnChatView extends StatefulWidget {
  const ReturnChatView({super.key});

  @override
  State<ReturnChatView> createState() => _ReturnChatViewState();
}

class _ReturnChatViewState extends State<ReturnChatView> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'customer',
      'text': 'Mas barangnya titip sama resepsionis ya',
      'time': '12:05',
    },
    {
      'sender': 'courier',
      'text': 'Baik, siap kak',
      'time': '12:06',
    },
    {
      'sender': 'customer',
      'text': 'Tolong apa aja ya mas',
      'time': '12:06',
    },
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isCustomer = msg['sender'] == 'customer';
                return Align(
                  alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: Column(
                      crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isCustomer ? Colors.white : const Color(0xFF0B1739),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            color: isCustomer ? Colors.white60 : Colors.black38,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan pesan Anda disini...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF0007B0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _messages.add({
                          'sender': 'customer',
                          'text': _controller.text,
                          'time': '12:07',
                        });
                        _controller.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0007B0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
