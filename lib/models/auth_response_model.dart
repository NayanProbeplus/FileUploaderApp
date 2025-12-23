class AuthResponse {
  final bool success;
  final AuthData? data;
  final String? error;

  AuthResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🔵 Parsing AuthResponse from JSON');

      return AuthResponse(
        success: true,
        data: AuthData.fromJson(json['data']),
      );
    } catch (e, stackTrace) {
      print('🔴 Error parsing AuthResponse: $e');
      print('🔴 StackTrace: $stackTrace');
      print('🔴 JSON: $json');
      return AuthResponse.error('Failed to parse response: $e');
    }
  }

  factory AuthResponse.error(String errorMessage) {
    return AuthResponse(
      success: false,
      error: errorMessage,
    );
  }
}

class AuthData {
  final String accessToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String refreshToken;
  final String tokenType;
  final String? idToken;
  final int notBeforePolicy;
  final String? sessionState;
  final String? scope;

  AuthData({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.refreshToken,
    required this.tokenType,
    this.idToken,
    required this.notBeforePolicy,
    this.sessionState,
    this.scope,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    try {
      print('🔵 Parsing AuthData from: $json');

      return AuthData(
        accessToken: json['access_token'] as String,
        expiresIn: json['expires_in'] as int,
        refreshExpiresIn: json['refresh_expires_in'] as int,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String,
        idToken: json['id_token'] as String?,
        notBeforePolicy: json['not-before-policy'] as int,
        sessionState: json['session_state'] as String?,
        scope: json['scope'] as String?,
      );
    } catch (e, stackTrace) {
      print('🔴 Error parsing AuthData: $e');
      print('🔴 StackTrace: $stackTrace');
      print('🔴 JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'id_token': idToken,
      'not-before-policy': notBeforePolicy,
      'session_state': sessionState,
      'scope': scope,
    };
  }
}
