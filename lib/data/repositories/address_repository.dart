import 'dart:convert';
import '../../domain/models/order.dart';
import '../services/address_service.dart';

class AddressRepository {
  final AddressService addressService;

  AddressRepository({required this.addressService});

  Future<List<AddressModel>> getAddresses(int userId, String token) async {
    final response = await addressService.getAddressesByUserId(userId, token);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => AddressModel.fromJson(json)).toList();
    } else {
      final msg = body['message'] ?? 'Gagal mengambil data alamat';
      throw Exception(msg);
    }
  }

  Future<AddressModel> createAddress({
    required String receiverName,
    required String phoneNumber,
    required String houseNumber,
    required String residenceName,
    required String addressNotes,
    required String streetName,
    required String district,
    required String subDistrict,
    required String token,
  }) async {
    final response = await addressService.createAddress(
      receiverName: receiverName,
      phoneNumber: phoneNumber,
      houseNumber: houseNumber,
      residenceName: residenceName,
      addressNotes: addressNotes,
      streetName: streetName,
      district: district,
      subDistrict: subDistrict,
      token: token,
    );
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return AddressModel.fromJson(body['data']);
    } else {
      final msg = body['message'] ?? 'Gagal menyimpan alamat baru';
      throw Exception(msg);
    }
  }

  Future<AddressModel> updateAddress({
    required int addressId,
    required String receiverName,
    required String phoneNumber,
    required String houseNumber,
    required String residenceName,
    required String addressNotes,
    required String streetName,
    required String district,
    required String subDistrict,
    required String token,
  }) async {
    final response = await addressService.updateAddress(
      addressId: addressId,
      receiverName: receiverName,
      phoneNumber: phoneNumber,
      houseNumber: houseNumber,
      residenceName: residenceName,
      addressNotes: addressNotes,
      streetName: streetName,
      district: district,
      subDistrict: subDistrict,
      token: token,
    );
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] ?? body;
      return AddressModel.fromJson(data);
    } else {
      final msg = body['message'] ?? 'Gagal memperbarui alamat';
      throw Exception(msg);
    }
  }

  Future<bool> deleteAddress(int addressId, String token) async {
    final response = await addressService.deleteAddress(addressId, token);
    if (response.statusCode == 200) {
      return true;
    } else {
      final body = jsonDecode(response.body);
      final msg = body['message'] ?? 'Gagal menghapus alamat';
      throw Exception(msg);
    }
  }
}
