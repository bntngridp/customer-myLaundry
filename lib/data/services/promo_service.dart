import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PromoService {
  final http.Client _client;

  PromoService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> getPromos() async {
    final url = Uri.parse('${AuthService.baseUrl}/promos');
    return await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> validatePromo(String code) async {
    final url = Uri.parse('${AuthService.baseUrl}/promos/validate/$code');
    return await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
