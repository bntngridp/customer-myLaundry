import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, String>> _loginHistory = [];

  ProfileViewModel({required this.authRepository}) {
    fetchLoginHistory();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get loginHistory => _loginHistory;

  Future<void> fetchLoginHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawList = await authRepository.getLoginHistory();
      if (rawList.isNotEmpty) {
        _loginHistory = rawList.map((item) {
          final ip = item['ip'] ?? '127.0.0.1';
          final ua = item['user_agent'] ?? 'Aplikasi Web/Mobile';
          final loggedAt = item['logged_at'] ?? item['CreatedAt'] ?? '';
          
          return {
            'location': 'IP: $ip',
            'device': ua.toString().length > 40 ? '${ua.toString().substring(0, 40)}...' : ua.toString(),
            'time': loggedAt.toString().isNotEmpty ? loggedAt.toString().split('T')[0] : 'Sesi Aktif',
          };
        }).toList();
      } else {
        // Fallback default info if list empty
        _loginHistory = [
          {
            'location': 'Sesi Perangkat Ini',
            'device': 'Aplikasi Customer',
            'time': 'Aktif, Sekarang ini',
          }
        ];
      }
    } catch (_) {
      _loginHistory = [
        {
          'location': 'Sesi Perangkat Ini',
          'device': 'Aplikasi Customer',
          'time': 'Aktif',
        }
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String username, required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.updateProfile(username: username, email: email);
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

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = authRepository.currentUser;
      if (user == null) throw Exception('Sesi tidak valid.');
      
      await authRepository.updateProfile(
        username: user.username,
        email: user.email,
        oldPassword: oldPassword,
        password: newPassword,
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

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.deleteAccount();
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
}
