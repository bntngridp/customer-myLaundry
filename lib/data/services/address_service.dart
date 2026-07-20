import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AddressService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8085/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8085/api';
      }
    } catch (_) {
      // Platform check can fail in web unit tests
    }
    return 'http://localhost:8085/api';
  }

  final http.Client _client;

  AddressService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> getAddressesByUserId(int userId, String token) async {
    final url = Uri.parse('$baseUrl/addresses/user/$userId');
    return await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> createAddress({
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
    final url = Uri.parse('$baseUrl/addresses/');
    return await _client.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded', // It uses ShouldBind in gin, which parses form/json. Let's use json.
        'Authorization': 'Bearer $token',
      },
      body: {
        'receiver_name': receiverName,
        'phone_number': phoneNumber,
        'house_number': houseNumber,
        'residence_name': residenceName,
        'address_notes': addressNotes,
        'street_name': streetName,
        'district': district,
        'sub_district': subDistrict,
      },
    );
  }
}
