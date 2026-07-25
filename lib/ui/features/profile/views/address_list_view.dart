import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../domain/models/order.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../../shared/widgets/app_snackbar.dart';
import 'add_edit_address_view.dart';

class AddressListView extends StatefulWidget {
  const AddressListView({super.key});

  @override
  State<AddressListView> createState() => _AddressListViewState();
}

class _AddressListViewState extends State<AddressListView> {
  bool _isLoading = true;
  List<AddressModel> _addresses = [];
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final addressRepo = Provider.of<AddressRepository>(context, listen: false);
    final user = authVm.authRepository.currentUser;
    final token = authVm.authRepository.token;

    if (user == null || token == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final list = await addressRepo.getAddresses(user.id, token);
      setState(() {
        _addresses = list;
        if (_addresses.isNotEmpty && _selectedAddressId == null) {
          _selectedAddressId = _addresses.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBar.showError(context, 'Gagal mengambil daftar alamat: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final addressRepo = Provider.of<AddressRepository>(context, listen: false);
    final token = authVm.authRepository.token;
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Alamat?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Apakah Anda yakin ingin menghapus alamat "${address.residenceName} - ${address.streetName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await addressRepo.deleteAddress(address.id, token);
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Alamat berhasil dihapus!');
        _fetchAddresses();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Gagal menghapus alamat: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final addressRepo = Provider.of<AddressRepository>(context);
    final token = authVm.authRepository.token ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Alamat Tersimpan',
          style: TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0007B0)))
            : _addresses.isEmpty
                ? _buildEmptyState(addressRepo, token)
                : RefreshIndicator(
                    onRefresh: _fetchAddresses,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final addr = _addresses[index];
                        final isSelected = addr.id == _selectedAddressId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0007B0) : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0007B0) : const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: isSelected ? Colors.white : const Color(0xFF0B1739),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addr.residenceName.isNotEmpty ? addr.residenceName : 'Alamat Penjemputan',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0B1739),
                                          ),
                                        ),
                                        Text(
                                          '${addr.receiverName} • ${addr.phoneNumber}',
                                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Utama',
                                        style: TextStyle(
                                          color: Color(0xFF0007B0),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),

                              Text(
                                '${addr.streetName}${addr.houseNumber.isNotEmpty ? ", ${addr.houseNumber}" : ""}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0B1739), height: 1.4),
                              ),
                              Text(
                                '${addr.subDistrict}, ${addr.district}, ${addr.city}',
                                style: const TextStyle(fontSize: 12, color: Colors.black45),
                              ),
                              if (addr.addressNotes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Catatan: ${addr.addressNotes}',
                                    style: const TextStyle(fontSize: 11, color: Colors.black87, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () async {
                                      final updated = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddEditAddressView(
                                            address: addr,
                                            addressRepository: addressRepo,
                                            token: token,
                                          ),
                                        ),
                                      );
                                      if (updated == true) _fetchAddresses();
                                    },
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0007B0)),
                                    label: const Text('Edit', style: TextStyle(color: Color(0xFF0007B0), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _deleteAddress(addr),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                    label: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () async {
            final added = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditAddressView(
                  addressRepository: addressRepo,
                  token: token,
                ),
              ),
            );
            if (added == true) _fetchAddresses();
          },
          icon: const Icon(Icons.add_location_alt_rounded, size: 20),
          label: const Text('Tambah Alamat Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0007B0),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AddressRepository addressRepo, String token) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_rounded, color: Color(0xFF0007B0), size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Alamat Tersimpan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1739)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan alamat penjemputan agar saat checkout laundry jadi lebih cepat dan gampang!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditAddressView(
                      addressRepository: addressRepo,
                      token: token,
                    ),
                  ),
                );
                if (added == true) _fetchAddresses();
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah Alamat Pertama', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0007B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
