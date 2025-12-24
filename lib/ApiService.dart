import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_uploader_app/models/auth_response_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.10.3.30:9010/api/v1';

  // Login API
  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/token/login');

      print('🔵 Login Request to: $url');
      print('🔵 Request Body: {"username": "$username", "password": "***"}');

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('🔵 Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('🔵 Decoded JSON: $json');

        // Check if data is false (invalid credentials)
        if (json['data'] == false) {
          print('🔴 Invalid credentials - data is false');
          return AuthResponse.error('Invalid username or password');
        }

        // Check if data is a Map (successful login)
        if (json['data'] is Map<String, dynamic>) {
          return AuthResponse.fromJson(json);
        }

        // Unexpected data format
        return AuthResponse.error('Unexpected response format');
      } else {
        print('🔴 Login failed with status: ${response.statusCode}');
        print('🔴 Response: ${response.body}');
        return AuthResponse.error(
          'Login failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('🔴 Error in login: $e');
      print('🔴 StackTrace: $stackTrace');
      return AuthResponse.error('Network error: $e');
    }
  }

  // Refresh Token API
  static Future<AuthResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/token/refresh');

      print('🔵 Refresh Token Request to: $url');

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken':
              refreshToken, // Note: API uses 'refreshToken' not 'refresh_token'
        }),
      );

      print('🔵 Refresh Response Status: ${response.statusCode}');
      print('🔵 Refresh Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('🔵 Decoded Refresh JSON: $json');
        return AuthResponse.fromJson(json);
      } else {
        print('🔴 Token refresh failed with status: ${response.statusCode}');
        print('🔴 Response: ${response.body}');
        return AuthResponse.error(
          'Token refresh failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('🔴 Error in refresh token: $e');
      print('🔴 StackTrace: $stackTrace');
      return AuthResponse.error('Network error: $e');
    }
  }
}
