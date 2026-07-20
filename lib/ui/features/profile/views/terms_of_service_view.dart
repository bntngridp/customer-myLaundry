import 'package:flutter/material.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Ketentuan',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Syarat dan Ketentuan myLaundry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
              ),
              SizedBox(height: 16),
              Text(
                '1. Penerimaan Syarat dan Ketentuan\n'
                'Dengan mengunduh, mengakses, atau menggunakan aplikasi myLaundry ("Aplikasi"), Anda setuju untuk mematuhi dan terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak setuju dengan Syarat dan Ketentuan ini, harap jangan gunakan Aplikasi.\n\n'
                '2. Layanan\n'
                'myLaundry menyediakan layanan antar-jemput pakaian untuk dicuci dan dikembalikan kepada pengguna. Kami berkomitmen untuk memberikan pelayanan berkualitas tinggi dan memastikan kepuasan pelanggan.\n\n'
                '3. Pendaftaran dan Akun Pengguna\n'
                '• Pengguna harus mendaftar dan membuat akun untuk menggunakan layanan myLaundry.\n'
                '• Pengguna bertanggung jawab untuk menjaga kerahasiaan informasi akun mereka dan bertanggung jawab atas semua aktivitas yang terjadi di bawah akun mereka.\n'
                '• Pengguna bertanggung jawab atas semua aktivitas yang terjadi di bawah akun mereka.\n\n'
                '4. Pemesanan dan Pembayaran\n'
                '• Semua pesanan harus dilakukan melalui Aplikasi.\n'
                '• Pengguna dapat membatalkan pesanan mereka dalam jangka waktu tertentu yang ditentukan oleh Aplikasi.\n'
                '• Pembayaran harus dilakukan melalui metode pembayaran yang tersedia di Aplikasi.\n\n'
                '5. Harga dan Pembayaran\n'
                '• Harga layanan akan ditampilkan di Aplikasi dan dapat berubah sewaktu-waktu tanpa pemberitahuan terlebih dahulu.\n'
                '• Pembayaran yang sah adalah melalui metode pembayaran yang tersedia di Aplikasi.\n'
                '• Pengguna setuju untuk membayar semua biaya yang terkait dengan penggunaan layanan myLaundry.\n\n'
                '6. Pengambilan dan Pengiriman\n'
                '• myLaundry akan menjemput pakaian pada waktu dan lokasi yang telah disepakati.\n'
                '• Pengguna harus memastikan bahwa pakaian sudah siap untuk diambil pada waktu yang ditentukan.\n'
                '• myLaundry akan mengembalikan pakaian yang telah dicuci pada waktu dan lokasi yang telah disepakati.\n\n'
                '7. Tanggung Jawab dan Jaminan\n'
                '• myLaundry akan berusaha untuk menjaga pakaian Anda dengan hati-hati. Namun, kami tidak bertanggung jawab atas kerusakan atau kehilangan pakaian yang disebabkan oleh faktor di luar kendali kami.\n'
                '• Jika terjadi kerusakan atau kehilangan, pengguna harus melaporkannya dalam waktu 24 jam setelah pengiriman.',
                style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
