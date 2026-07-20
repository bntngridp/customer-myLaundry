import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String _currentLanguage = 'Bahasa Indonesia';

  final List<Map<String, String>> _loginHistory = [
    {
      'location': 'Bandung, Indonesia',
      'device': 'samsung SM-M123',
      'time': 'Aktif, sekarang ini',
    },
    {
      'location': 'Jakarta, Indonesia',
      'device': 'samsung SM-M123',
      'time': '02:23 AM, 12 Januari 2023',
    },
  ];

  ProfileViewModel({required this.authRepository});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentLanguage => _currentLanguage;
  List<Map<String, String>> get loginHistory => _loginHistory;

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
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
