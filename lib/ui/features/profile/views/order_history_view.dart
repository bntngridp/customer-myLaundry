import 'package:flutter/material.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock grouped history data
    final List<Map<String, dynamic>> historyGroups = [
      {
        'date': 'Hari Ini',
        'orders': [
          {'title': 'Mandiri VA', 'price': 'Rp55.000,00', 'services': ['Cuci Lipat', 'Cuci Satuan', 'Cuci Setrika']}
        ]
      },
      {
        'date': 'Kemarin',
        'orders': [
          {'title': 'Mandiri VA', 'price': 'Rp55.000,00', 'services': ['Cuci Lipat', 'Cuci Satuan']}
        ]
      },
      {
        'date': '01 Agustus 2024',
        'orders': [
          {'title': 'Mandiri VA', 'price': 'Rp55.000,00', 'services': ['Cuci Lipat', 'Cuci Setrika']}
        ]
      }
    ];

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
          'Riwayat',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: historyGroups.length,
          itemBuilder: (context, index) {
            final group = historyGroups[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['date'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 12),
                ... (group['orders'] as List).map((ord) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        // Row of service icons representing the laundry items
                        Row(
                          children: (ord['services'] as List).map((s) {
                            Color sColor = const Color(0xFFEAB308);
                            IconData sIcon = Icons.dry_cleaning;
                            if (s == 'Cuci Satuan') {
                              sColor = const Color(0xFF22C55E);
                              sIcon = Icons.layers;
                            } else if (s == 'Cuci Setrika') {
                              sColor = const Color(0xFF38BDF8);
                              sIcon = Icons.iron;
                            }
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sColor.withValues(alpha: 0.15),
                              ),
                              child: Icon(sIcon, color: sColor, size: 18),
                            );
                          }).toList(),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              ord['title'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ord['price'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0007B0),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
