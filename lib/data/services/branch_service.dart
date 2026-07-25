import 'dart:convert';
import 'package:http/http.dart' as http;

class BranchService {
  static const String baseUrl = 'http://localhost:8083/api';

  Future<List<Map<String, dynamic>>> getBranches({double? lat, double? lng}) async {
    String urlStr = '$baseUrl/branches';
    if (lat != null && lng != null) {
      urlStr += '?lat=$lat&lng=$lng';
    }

    try {
      final response = await http.get(Uri.parse(urlStr));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }
}
