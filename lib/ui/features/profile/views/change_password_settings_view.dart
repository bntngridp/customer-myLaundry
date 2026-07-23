import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/profile_view_model.dart';

import '../../../shared/widgets/app_snackbar.dart';

class ChangePasswordSettingsView extends StatefulWidget {
  const ChangePasswordSettingsView({super.key});

  @override
  State<ChangePasswordSettingsView> createState() => _ChangePasswordSettingsViewState();
}

class _ChangePasswordSettingsViewState extends State<ChangePasswordSettingsView> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

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
          'Ganti Sandi',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Sandi Lama Field
                      _buildPasswordField(
                        'Sandi Lama',
                        'Masukkan sandi lama anda',
                        _oldPasswordController,
                        _obscureOld,
                        () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      const SizedBox(height: 20),

                      // Sandi Baru Field
                      _buildPasswordField(
                        'Sandi Baru',
                        'Masukkan sandi baru anda',
                        _newPasswordController,
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 20),

                      // Konfirmasi Sandi Field
                      _buildPasswordField(
                        'Konfirmasi Sandi',
                        'Masukkan kembali sandi anda',
                        _confirmPasswordController,
                        _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ],
                  ),
                ),
              ),

              // Button
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        if (_oldPasswordController.text.trim().isEmpty) {
                          AppSnackBar.showError(context, 'Sandi lama tidak boleh kosong');
                          return;
                        }
                        if (_newPasswordController.text.isEmpty) {
                          AppSnackBar.showError(context, 'Sandi baru tidak boleh kosong');
                          return;
                        }
                        if (_newPasswordController.text.length < 6) {
                          AppSnackBar.showError(context, 'Sandi minimal harus 6 karakter');
                          return;
                        }
                        if (_newPasswordController.text != _confirmPasswordController.text) {
                          AppSnackBar.showError(context, 'Konfirmasi kata sandi tidak cocok');
                          return;
                        }
                        final success = await viewModel.changePassword(
                          oldPassword: _oldPasswordController.text,
                          newPassword: _newPasswordController.text,
                        );
                        if (success && context.mounted) {
                          AppSnackBar.showSuccess(context, 'Kata sandi berhasil diperbarui');
                          Navigator.pop(context);
                        } else if (context.mounted && viewModel.errorMessage != null) {
                          AppSnackBar.showError(context, viewModel.errorMessage!);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Ganti Sandi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    String hint,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black26),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0007B0), width: 2),
            ),
          ),
        )
      ],
    );
  }
}
