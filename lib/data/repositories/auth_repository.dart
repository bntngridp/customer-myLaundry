import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  User? _currentUser;
  String? _token;

  AuthRepository({required this.authService});

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
      } catch (_) {
        _currentUser = null;
      }
    }
  }

  Future<User?> login(String email, String password) async {
    final response = await authService.login(email, password);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final data = body['data'];
      _token = data['token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      final user = await getMe();
      if (user != null) {
        if (user.role != 'customer') {
          await logout();
          throw Exception('Hanya akun pelanggan yang diperbolehkan masuk.');
        }
        _currentUser = user;
        await prefs.setString('auth_user', jsonEncode(user.toJson()));
      }
      return _currentUser;
    } else {
      final msg = body['message'] ?? 'Email atau password salah';
      throw Exception(msg);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await authService.register(
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    final body = jsonDecode(response.body);

    if (response.statusCode == 201 || (response.statusCode == 200 && body['success'] == true)) {
      return true;
    } else {
      final msg = body['message'] ?? 'Pendaftaran gagal';
      throw Exception(msg);
    }
  }

  Future<User?> getMe() async {
    if (_token == null) return null;

    final response = await authService.getMe(_token!);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && (body['status'] == 'success' || body['success'] == true)) {
      final data = body['data'];
      return User.fromJson(data);
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data profil');
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }

  Future<bool> forgotPassword(String email) async {
    final response = await authService.forgotPassword(email);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return true;
    } else {
      final msg = body['message'] ?? 'Gagal mengirim email pemulihan sandi.';
      throw Exception(msg);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final response = await authService.verifyOtp(email, otp);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return true;
    } else {
      final msg = body['message'] ?? 'Kode verifikasi OTP salah atau kedaluwarsa.';
      throw Exception(msg);
    }
  }

  Future<bool> resetPassword(String email, String otp, String password) async {
    final response = await authService.resetPassword(email, otp, password);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return true;
    } else {
      final msg = body['message'] ?? 'Gagal menyetel ulang kata sandi.';
      throw Exception(msg);
    }
  }

  Future<void> updateProfile({
    required String username,
    required String email,
    String? password,
  }) async {
    if (_token == null || _currentUser == null) return;

    final response = await authService.updateCustomer(
      id: _currentUser!.id,
      username: username,
      email: email,
      password: password,
      token: _token!,
    );
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Re-fetch me to update local currentUser cache
      final updatedUser = await getMe();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user', jsonEncode(updatedUser.toJson()));
      }
    } else {
      final msg = body['message'] ?? 'Gagal memperbarui profil';
      throw Exception(msg);
    }
  }

  Future<void> deleteAccount() async {
    if (_token == null || _currentUser == null) return;

    final response = await authService.deleteCustomer(_currentUser!.id, _token!);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await logout();
    } else {
      final msg = body['message'] ?? 'Gagal menghapus akun';
      throw Exception(msg);
    }
  }

  Future<User?> googleLogin(String idToken, {String role = 'customer'}) async {
    final response = await authService.googleLogin(idToken, role: role);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && (body['status'] == 'success' || body['success'] == true)) {
      final data = body['data'];
      _token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      final user = await getMe();
      if (user != null) {
        if (user.role != 'customer') {
          await logout();
          throw Exception('Hanya akun pelanggan yang diperbolehkan masuk.');
        }
        _currentUser = user;
        await prefs.setString('auth_user', jsonEncode(user.toJson()));
      }
      return _currentUser;
    } else {
      final msg = body['message'] ?? 'Google Login gagal';
      throw Exception(msg);
    }
  }
}
