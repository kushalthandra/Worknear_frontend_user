import 'package:http/http.dart' as http;

class ApiService {
  // Use your computer's IP address
  static const _baseUrl = 'http://192.168.1.8:3000/api';

  static Future<http.Response> getProtectedData(String jwt) {
    return http.get(
      Uri.parse('$_baseUrl/protected'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );
  }
  
    static Future<http.Response> getUserProfiles(String jwt) {
    return http.get(
      Uri.parse('$_baseUrl/get-user-profiles'), // Use the new endpoint URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt', // Secure the request with the token
      },
    );
  }
}

