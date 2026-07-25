// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final completer = Completer<Map<String, dynamic>>();

    if (kIsWeb) {
      try {
        html.window.navigator.geolocation.getCurrentPosition(
          enableHighAccuracy: true,
          timeout: const Duration(seconds: 10),
        ).then((pos) async {
          final num? latNum = pos.coords?.latitude;
          final num? lngNum = pos.coords?.longitude;
          if (latNum == null || lngNum == null) {
            completer.complete(_buildFallbackMap(-6.9740, 107.6303, 'Lokasi GPS Tidak Terdeteksi'));
            return;
          }

          final double lat = latNum.toDouble();
          final double lng = lngNum.toDouble();

          // Fetch real address from OpenStreetMap Nominatim Reverse Geocoding API
          final realAddressData = await _reverseGeocode(lat, lng);
          completer.complete(realAddressData);
        }).catchError((err) {
          completer.complete(_buildFallbackMap(-6.9740, 107.6303, 'Izin GPS Ditolak / Tidak Aktif'));
        });
      } catch (e) {
        completer.complete(_buildFallbackMap(-6.9740, 107.6303, 'Gagal Membaca GPS Browser'));
      }
    } else {
      completer.complete(_buildFallbackMap(-6.9740, 107.6303, 'GPS Mobile Service Ready'));
    }

    return completer.future;
  }

  static Future<Map<String, dynamic>> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');
      final res = await http.get(url, headers: {'User-Agent': 'MyLaundryApp/1.0'}).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final String displayName = body['display_name'] ?? '';
        final addressObj = body['address'] as Map<String, dynamic>? ?? {};

        final String road = addressObj['road'] ?? addressObj['pedestrian'] ?? addressObj['suburb'] ?? addressObj['village'] ?? '';
        final String village = addressObj['village'] ?? addressObj['suburb'] ?? addressObj['neighbourhood'] ?? '';
        final String county = addressObj['county'] ?? addressObj['city'] ?? addressObj['town'] ?? addressObj['regency'] ?? '';
        final String state = addressObj['state'] ?? '';

        final String fullStreet = road.isNotEmpty ? road : (displayName.isNotEmpty ? displayName : 'Posisi Terdeteksi ($lat, $lng)');

        return {
          'lat': lat,
          'lng': lng,
          'address': fullStreet,
          'display_name': displayName,
          'district': county,
          'sub_district': village,
          'state': state,
        };
      }
    } catch (_) {}

    return {
      'lat': lat,
      'lng': lng,
      'address': 'Posisi GPS Real ($lat, $lng)',
      'display_name': 'Posisi GPS Real ($lat, $lng)',
      'district': 'Kecamatan Terdeteksi',
      'sub_district': 'Kelurahan Terdeteksi',
      'state': '',
    };
  }

  static Map<String, dynamic> _buildFallbackMap(double lat, double lng, String message) {
    return {
      'lat': lat,
      'lng': lng,
      'address': message,
      'display_name': message,
      'district': 'Kecamatan',
      'sub_district': 'Kelurahan',
      'state': '',
    };
  }
}
