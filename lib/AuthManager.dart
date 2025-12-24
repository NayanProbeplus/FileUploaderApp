import 'package:file_uploader_app/ApiService.dart';
import 'package:file_uploader_app/TokenStorage.dart';
import 'package:flutter/material.dart';

class AuthManager {
  // Get valid access token (refreshes if needed)
  static Future<String?> getValidAccessToken() async {
    final isExpired = await TokenStorage.isAccessTokenExpired();

    if (isExpired) {
      // Try to refresh the token
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        // Refresh failed, user needs to login again
        await TokenStorage.clearTokens();
        return null;
      }
    }

    return await TokenStorage.getAccessToken();
  }

  // Refresh access token using refresh token
  static Future<bool> _refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null) return false;

    // Check if refresh token is expired
    final refreshExpired = await TokenStorage.isRefreshTokenExpired();
    if (refreshExpired) return false;

    try {
      final response =
          await ApiService.refreshToken(refreshToken: refreshToken);

      if (response.success && response.data != null) {
        final data = response.data!;

        // Save new tokens
        await TokenStorage.saveTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          tokenType: data.tokenType,
          expiresIn: data.expiresIn,
          refreshExpiresIn: data.refreshExpiresIn,
          idToken: data.idToken,
          scope: data.scope,
          sessionState: data.sessionState,
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    // Get refresh token before clearing
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken != null) {
      // Call logout API
      final result = await ApiService.logout(refreshToken: refreshToken);

      if (result['success'] == true) {
      } else {
        debugPrint('⚠️ [AuthManager] Logout API failed: ${result['error']}');
      }
    } else {
      debugPrint('⚠️ [AuthManager] No refresh token found - skipping API call');
    }

    await TokenStorage.clearTokens();
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await TokenStorage.isLoggedIn();
  }

  // Get authorization header for API calls
  static Future<Map<String, String>?> getAuthHeaders() async {
    final accessToken = await getValidAccessToken();

    if (accessToken == null) return null;
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }
}
