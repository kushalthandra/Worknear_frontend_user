import 'package:http/http.dart' as http;

class ApiService {
  static const _baseUrl = 'http://localhost:3000/api';

  static Future<http.Response> getProtectedData(String jwt) {
    return http.get(
      Uri.parse('$_baseUrl/protected'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
  }
}