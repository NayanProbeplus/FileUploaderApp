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

      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Check if data is false (invalid credentials)
        if (json['data'] == false) {
          return AuthResponse.error('Invalid username or password');
        }

        // Check if data is a Map (successful login)
        if (json['data'] is Map<String, dynamic>) {
          return AuthResponse.fromJson(json);
        }

        // Unexpected data format
        return AuthResponse.error('Unexpected response format');
      } else {
        debugPrint('Response: ${response.body}');
        return AuthResponse.error(
          'Login failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in login: $e');
      return AuthResponse.error('Network error: $e');
    }
  }

  // Refresh Token API
  static Future<AuthResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/token/refresh');

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

      debugPrint('Refresh Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return AuthResponse.fromJson(json);
      } else {
        return AuthResponse.error(
          'Token refresh failed with status: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in refresh token: $e');
      return AuthResponse.error('Network error: $e');
    }
  }

  // Logout API
  static Future<Map<String, dynamic>> logout({
    required String refreshToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/token/logout');

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Check if data is true (successful logout)
        if (json['data'] == true) {
          return {
            'success': true,
          };
        }

        // Check if data is false (invalid refresh token)
        if (json['data'] == false) {
          return {
            'success': false,
            'error': 'Invalid refresh token',
          };
        }
        // Unexpected data format
        return {
          'success': false,
          'error': 'Unexpected response format',
        };
      } else {
        debugPrint('Response: ${response.body}');
        return {
          'success': false,
          'error': 'Logout failed with status: ${response.statusCode}',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('Error in logout: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
