import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _refreshExpiresInKey = 'refresh_expires_in';
  static const String _idTokenKey = 'id_token';
  static const String _scopeKey = 'scope';
  static const String _sessionStateKey = 'session_state';
  static const String _loginTimeKey = 'login_time';

  // Save all tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    required int refreshExpiresIn,
    String? idToken,
    String? scope,
    String? sessionState,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setInt(_expiresInKey, expiresIn);
    await prefs.setInt(_refreshExpiresInKey, refreshExpiresIn);
    await prefs.setInt(_loginTimeKey, loginTime);

    if (idToken != null) await prefs.setString(_idTokenKey, idToken);
    if (scope != null) await prefs.setString(_scopeKey, scope);
    if (sessionState != null)
      await prefs.setString(_sessionStateKey, sessionState);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Get token type
  static Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  // Check if access token is expired
  static Future<bool> isAccessTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_loginTimeKey);
    final expiresIn = prefs.getInt(_expiresInKey);

    if (loginTime == null || expiresIn == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = loginTime + (expiresIn * 1000);

    // Check if token will expire in next 60 seconds
    return currentTime >= (expiryTime - 60000);
  }

  // Check if refresh token is expired
  static Future<bool> isRefreshTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_loginTimeKey);
    final refreshExpiresIn = prefs.getInt(_refreshExpiresInKey);

    if (loginTime == null || refreshExpiresIn == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = loginTime + (refreshExpiresIn * 1000);

    return currentTime >= expiryTime;
  }

  // Clear all tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_expiresInKey);
    await prefs.remove(_refreshExpiresInKey);
    await prefs.remove(_idTokenKey);
    await prefs.remove(_scopeKey);
    await prefs.remove(_sessionStateKey);
    await prefs.remove(_loginTimeKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null || refreshToken == null) return false;

    // Check if refresh token is still valid
    final refreshExpired = await isRefreshTokenExpired();
    return !refreshExpired;
  }
}
