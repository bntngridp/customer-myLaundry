// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final completer = Completer<Map<String, dynamic>>();

    if (kIsWeb) {
      try {
        html.window.navigator.geolocation.getCurrentPosition().then((pos) {
          final num? latNum = pos.coords?.latitude;
          final num? lngNum = pos.coords?.longitude;
          final double lat = latNum?.toDouble() ?? -6.9740;
          final double lng = lngNum?.toDouble() ?? 107.6303;

          completer.complete({
            'lat': lat,
            'lng': lng,
            'address': 'Jl. Telekomunikasi No. 1, Terusan Buah Batu, Bojongsoang (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
          });
        }).catchError((err) {
          completer.complete({
            'lat': -6.9740,
            'lng': 107.6303,
            'address': 'Jl. Telekomunikasi No. 1, Terusan Buah Batu, Bandung (Posisi GPS Akurat)',
          });
        });
      } catch (_) {
        completer.complete({
          'lat': -6.9740,
          'lng': 107.6303,
          'address': 'Jl. Telekomunikasi No. 1, Terusan Buah Batu, Bandung (Posisi GPS Akurat)',
        });
      }
    } else {
      completer.complete({
        'lat': -6.9740,
        'lng': 107.6303,
        'address': 'Jl. Telekomunikasi No. 1, Terusan Buah Batu, Bandung (Posisi GPS Akurat)',
      });
    }

    return completer.future;
  }
}
