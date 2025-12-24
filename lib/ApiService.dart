import 'dart:convert';
import 'package:flutter/material.dart';
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

      debugPrint('🔵 Login Request to: $url');
      debugPrint(
          '🔵 Request Body: {"username": "$username", "password": "***"}');

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

      debugPrint('🔵 Response Status: ${response.statusCode}');
      debugPrint('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('🔵 Decoded JSON: $json');

        // Check if data is false (invalid credentials)
        if (json['data'] == false) {
          debugPrint('🔴 Invalid credentials - data is false');
          return AuthResponse.error('Invalid username or password');
        }

        // Check if data is a Map (successful login)
        if (json['data'] is Map<String, dynamic>) {
          return AuthResponse.fromJson(json);
        }

        // Unexpected data format
        return AuthResponse.error('Unexpected response format');
      } else {
        debugPrint('🔴 Login failed with status: ${response.statusCode}');
        debugPrint('🔴 Response: ${response.body}');
        return AuthResponse.error(
          'Login failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 Error in login: $e');
      debugPrint('🔴 StackTrace: $stackTrace');
      return AuthResponse.error('Network error: $e');
    }
  }

  // Refresh Token API
  static Future<AuthResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/token/refresh');

      debugPrint('🔵 Refresh Token Request to: $url');

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

      debugPrint('🔵 Refresh Response Status: ${response.statusCode}');
      debugPrint('🔵 Refresh Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('🔵 Decoded Refresh JSON: $json');
        return AuthResponse.fromJson(json);
      } else {
        debugPrint(
            '🔴 Token refresh failed with status: ${response.statusCode}');
        debugPrint('🔴 Response: ${response.body}');
        return AuthResponse.error(
          'Token refresh failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 Error in refresh token: $e');
      debugPrint('🔴 StackTrace: $stackTrace');
      return AuthResponse.error('Network error: $e');
    }
  }
}
