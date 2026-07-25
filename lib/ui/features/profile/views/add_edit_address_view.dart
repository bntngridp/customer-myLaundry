import 'package:flutter/material.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../domain/models/order.dart';
import '../../../shared/widgets/app_snackbar.dart';

class AddEditAddressView extends StatefulWidget {
  final AddressModel? address;
  final AddressRepository addressRepository;
  final String token;

  const AddEditAddressView({
    super.key,
    this.address,
    required this.addressRepository,
    required this.token,
  });

  @override
  State<AddEditAddressView> createState() => _AddEditAddressViewState();
}

class _AddEditAddressViewState extends State<AddEditAddressView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _residenceNameController;
  late TextEditingController _receiverNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _streetNameController;
  late TextEditingController _houseNumberController;
  late TextEditingController _districtController;
  late TextEditingController _subDistrictController;
  late TextEditingController _notesController;

  bool _isLocatingGps = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _residenceNameController = TextEditingController(text: addr?.residenceName ?? 'Rumah');
    _receiverNameController = TextEditingController(text: addr?.receiverName ?? '');
    _phoneNumberController = TextEditingController(text: addr?.phoneNumber ?? '081234567890');
    _streetNameController = TextEditingController(text: addr?.streetName ?? '');
    _houseNumberController = TextEditingController(text: addr?.houseNumber ?? 'No. 1');
    _districtController = TextEditingController(text: addr?.district ?? 'Bojongsoang');
    _subDistrictController = TextEditingController(text: addr?.subDistrict ?? 'Sukapura');
    _notesController = TextEditingController(text: addr?.addressNotes ?? '');
  }

  @override
  void dispose() {
    _residenceNameController.dispose();
    _receiverNameController.dispose();
    _phoneNumberController.dispose();
    _streetNameController.dispose();
    _houseNumberController.dispose();
    _districtController.dispose();
    _subDistrictController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() => _isLocatingGps = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      final String addrStr = loc['address'] as String? ?? 'Jl. Bojongsoang Raya No. 1';
      final double lat = loc['lat'] as double? ?? -6.9740;
      final double lng = loc['lng'] as double? ?? 107.6303;

      setState(() {
        _streetNameController.text = addrStr;
        _districtController.text = 'Bojongsoang';
        _subDistrictController.text = 'Sukapura';
        _notesController.text = 'Lokasi GPS (Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)})';
        _isLocatingGps = false;
      });
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Berhasil mendapatkan lokasi GPS terbaru!');
      }
    } catch (e) {
      setState(() => _isLocatingGps = false);
      if (mounted) {
        AppSnackBar.showError(context, 'Gagal mengambil lokasi GPS: ${e.toString()}');
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      if (widget.address != null) {
        // Edit existing address
        await widget.addressRepository.updateAddress(
          addressId: widget.address!.id,
          receiverName: _receiverNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          houseNumber: _houseNumberController.text.trim(),
          residenceName: _residenceNameController.text.trim(),
          addressNotes: _notesController.text.trim(),
          streetName: _streetNameController.text.trim(),
          district: _districtController.text.trim(),
          subDistrict: _subDistrictController.text.trim(),
          token: widget.token,
        );
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Alamat berhasil diperbarui!');
          Navigator.pop(context, true);
        }
      } else {
        // Create new address
        await widget.addressRepository.createAddress(
          receiverName: _receiverNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          houseNumber: _houseNumberController.text.trim(),
          residenceName: _residenceNameController.text.trim(),
          addressNotes: _notesController.text.trim(),
          streetName: _streetNameController.text.trim(),
          district: _districtController.text.trim(),
          subDistrict: _subDistrictController.text.trim(),
          token: widget.token,
        );
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Alamat baru berhasil ditambahkan!');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        AppSnackBar.showError(context, 'Gagal menyimpan alamat: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1739)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Alamat Penjemputan' : 'Tambah Alamat Baru',
          style: const TextStyle(color: Color(0xFF0B1739), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // GPS Auto-Detect Button Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0007B0),
                        shape: BoxShape.circle,
                      ),
                      child: _isLocatingGps
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Gunakan Lokasi GPS Saat Ini',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1739)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Otomatis mengisi jalan & kecamatan dari posisi Anda',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLocatingGps ? null : _fetchGpsLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0007B0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Deteksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Residence Name Tag (Rumah, Kosan, Kantor)
              const Text('Label Alamat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _residenceNameController,
                decoration: _inputDecoration('Contoh: Rumah, Kosan, Kantor', Icons.label_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Label alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Receiver Name
              const Text('Nama Penerima / Pemilik', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiverNameController,
                decoration: _inputDecoration('Nama lengkap penerima', Icons.person_outline),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama penerima wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Phone Number
              const Text('Nomor HP / Telepon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('0812xxxxxxxx', Icons.phone_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nomor HP wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Street Name
              const Text('Alamat Lengkap / Jalan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetNameController,
                maxLines: 2,
                decoration: _inputDecoration('Jl. Bojongsoang Raya No. 1', Icons.location_city_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Alamat lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // House / Unit Number
              const Text('Nomor Rumah / Unit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _houseNumberController,
                decoration: _inputDecoration('No. 1 / Blk B2', Icons.home_outlined),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kecamatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _districtController,
                          decoration: _inputDecoration('Bojongsoang', Icons.map_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kelurahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _subDistrictController,
                          decoration: _inputDecoration('Sukapura', Icons.nature_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address Notes
              const Text('Catatan Tambahan (Patokan / Penjemputan)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B1739))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('Pagar warna hitam, dekat masjid', Icons.note_alt_outlined),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0007B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEdit ? 'Simpan Perubahan Alamat' : 'Simpan Alamat Baru',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF0007B0), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0007B0), width: 1.5),
      ),
    );
  }
}
