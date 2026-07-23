import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/profile_view_model.dart';

class LoginHistoryView extends StatelessWidget {
  const LoginHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final history = profileViewModel.loginHistory;

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
          'Riwayat Masuk',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: profileViewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0007B0)),
              )
            : RefreshIndicator(
                onRefresh: () => profileViewModel.fetchLoginHistory(),
                color: const Color(0xFF0007B0),
                child: ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.devices_rounded, size: 18, color: Color(0xFF0007B0)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry['location']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B1739),
                                  ),
                                ),
                              ),
                              if (index == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1A4CAF50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Aktif Hari Ini',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Waktu: ${entry['time']}',
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perangkat: ${entry['device']}',
                            style: const TextStyle(fontSize: 11, color: Colors.black38),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
