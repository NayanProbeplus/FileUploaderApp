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

  // Logout API
  static Future<Map<String, dynamic>> logout({
    required String refreshToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/token/logout');

      print('🔵 Logout Request to: $url');
      print(
          '🔵 Logout Request Body: {"refreshToken": "${refreshToken.substring(0, 30)}..."}');

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

      print('🔵 Logout Response Status: ${response.statusCode}');
      print('🔵 Logout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('🔵 Decoded Logout JSON: $json');

        // Check if data is true (successful logout)
        if (json['data'] == true) {
          print('✅ Logout API successful - server session invalidated');
          return {
            'success': true,
          };
        }

        // Check if data is false (invalid refresh token)
        if (json['data'] == false) {
          print('🔴 Logout API returned false - invalid refresh token');
          return {
            'success': false,
            'error': 'Invalid refresh token',
          };
        }

        // Unexpected data format
        print('🔴 Unexpected logout response format');
        return {
          'success': false,
          'error': 'Unexpected response format',
        };
      } else {
        print('🔴 Logout failed with status: ${response.statusCode}');
        print('🔴 Response: ${response.body}');
        return {
          'success': false,
          'error': 'Logout failed with status: ${response.statusCode}',
        };
      }
    } catch (e, stackTrace) {
      print('🔴 Error in logout: $e');
      print('🔴 StackTrace: $stackTrace');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
