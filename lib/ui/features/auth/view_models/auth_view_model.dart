import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  bool _isLoading = false;
  String? _errorMessage;

  String? _emailForReset;
  String? _otpForReset;

  String _currentLanguage = 'id';

  AuthViewModel({required this.authRepository}) {
    _loadLanguage();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => authRepository.isAuthenticated;

  String? get emailForReset => _emailForReset;
  String? get otpForReset => _otpForReset;
  String get currentLanguage => _currentLanguage;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_lang') ?? 'id';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', lang);
    notifyListeners();
  }

  String translate(String key) {
    if (_currentLanguage == 'en') {
      return _translations['en']?[key] ?? key;
    }
    return key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'Masuk': 'Login',
      'Daftar': 'Register',
      'Lupa Password': 'Forgot Password',
      'Lupa Kata Sandi?': 'Forgot Password?',
      'Kata Sandi': 'Password',
      'Kata Sandi Baru': 'New Password',
      'Nama Pengguna': 'Username',
      'Kamu lupa password? klik disini': 'Forgot password? click here',
      'Belum punya akun? Yuk Daftar': "Don't have an account? Register",
      'Sudah punya akun? Masuk disini': 'Already have an account? Login here',
      'Kamu lupa password? ': 'Forgot password? ',
      'klik disini': 'click here',
      'Belum punya akun? ': "Don't have an account? ",
      'Yuk Daftar': 'Register',
      'Sudah punya akun? ': 'Already have an account? ',
      'Sudah ingat kata sandi? ': 'Remember password? ',
      'Masuk disini': 'Login here',
      'Bahasa': 'Language',
      'Keamanan': 'Security',
      'Keluar': 'Logout',
      'Edit Profil': 'Edit Profile',
      'Riwayat Pesanan': 'Order History',
      'Ketentuan': 'Terms of Service',
      'Daftar Akun': 'Register Account',
      'Kode Khusus Karyawan': 'Employee Code',
      'Verifikasi': 'Verify',
      'Kirim': 'Send',
      'Kirim Kode Verifikasi': 'Send Verification Code',
      'Masukkan alamat email Anda': 'Enter your email address',
      'Masukkan alamat email terdaftar Anda untuk menerima kode verifikasi OTP.': 'Enter your registered email address to receive the OTP verification code.',
      'Email terdaftar': 'Registered Email',
      'Nama': 'Name',
      'Simpan': 'Save',
      'Layanan Kami': 'Our Services',
      'Cabang Terdekat': 'Closest Branches',
      'Pesanan Aktif': 'Active Order',
      'Hubungi Kurir': 'Contact Courier',
      'Hubungi Pelanggan': 'Contact Customer',
      'Kembalikan Cucian': 'Return Laundry',
      'Detail Pesanan': 'Order Details',
      'Total Pembayaran': 'Total Payment',
      'Metode Pembayaran': 'Payment Method',
      'Pilih Metode Pembayaran': 'Select Payment Method',
      'Bayar': 'Pay',
      'Pencucian': 'Washing',
      'Penyetrikaan': 'Ironing',
      'Cuci & Setrika': 'Wash & Iron',
      'Dry Cleaning': 'Dry Cleaning',
      'Sedang mencari kurir': 'Looking for a courier',
      'Kurir dalam perjalanan': 'Courier is on the way',
      'Kurir telah sampai': 'Courier has arrived',
      'Pesanan sedang diproses': 'Order is being processed',
      'Menunggu pembayaran': 'Waiting for payment',
      'Kurir dalam perjalanan mengantar pakaianmu': 'Courier is on the way to deliver your clothes',
      'Pesanan diproses': 'Order is processed',
      'Yuk gunakan promo #BersihTanpaPusing': 'Let\'s use the #CleanWithoutHeadache promo',
    }
  };

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan Kata Sandi tidak boleh kosong.');
      }
      await authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('Semua kolom wajib diisi.');
      }
      await authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendForgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Email tidak boleh kosong.');
      }
      final success = await authRepository.forgotPassword(email);
      if (success) {
        _emailForReset = email;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitVerifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (otp.length != 4) {
        throw Exception('Kode OTP harus terdiri dari 4 digit.');
      }
      if (_emailForReset == null) {
        throw Exception('Email sesi reset tidak ditemukan.');
      }
      final success = await authRepository.verifyOtp(_emailForReset!, otp);
      if (success) {
        _otpForReset = otp;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitResetPassword(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (password.isEmpty) {
        throw Exception('Kata sandi baru tidak boleh kosong.');
      }
      if (_emailForReset == null || _otpForReset == null) {
        throw Exception('Sesi reset sandi tidak valid atau kedaluwarsa.');
      }
      final success = await authRepository.resetPassword(_emailForReset!, _otpForReset!, password);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    notifyListeners();
  }
}
