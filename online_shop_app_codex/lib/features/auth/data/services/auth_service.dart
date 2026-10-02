import 'dart:convert';

import 'package:dio/dio.dart';

class AuthService {
  AuthService(this._dio);
  final Dio _dio;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String userLogin,
  }) async {
    await _postJson('register', {
      'email': email,
      'password': password,
      'display_name': displayName,
      'user_login': userLogin,
    });
  }

  Future<void> verify({required String email, required String otp}) async {
    await _postJson('verify', {'email': email, 'otp': otp});
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final body = await _postJson('login', {
      'email': email,
      'password': password,
    });
    final data = _map(body['data']);
    final nested = _map(data['data']);
    final token = (nested['jwt'] ?? data['jwt'])?.toString();
    if (token == null || token.isEmpty) {
      throw const AuthException('Login succeeded without a session token.');
    }
    final expiry = int.tryParse('${nested['exp'] ?? data['exp'] ?? 0}') ?? 0;
    final userId = int.tryParse(
      '${nested['id'] ?? data['id'] ?? _jwtClaim(token, 'id') ?? ''}',
    );
    return AuthSession(
      token: token,
      expiresAt: expiry > 0
          ? DateTime.fromMillisecondsSinceEpoch(expiry * 1000)
          : null,
      userId: userId,
    );
  }

  String? _jwtClaim(String token, String key) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      return payload is Map ? payload[key]?.toString() : null;
    } catch (_) {
      return null;
    }
  }

  Future<String> reset(String email) async {
    final body = await _postJson('reset', {'email': email});
    final data = body['data'];
    if (data is String && data.trim().isNotEmpty) return data;
    final message = _message(body);
    return message == 'Request failed.'
        ? 'Password reset link sent to your email.'
        : message;
  }

  Future<Map<String, dynamic>> _postJson(
    String action,
    Map<String, String> data,
  ) async {
    try {
      final response = await _dio.post(
        '/auth.php?action=$action',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
      final body = _map(response.data);
      if (body['success'] != true && _map(body['data'])['success'] != true) {
        throw AuthException(_message(response.data));
      }
      return body;
    } on DioException catch (error) {
      throw AuthException(
        error.response == null
            ? 'Unable to connect to the server.'
            : _message(error.response!.data),
      );
    }
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  String _message(Object? value) {
    Object? decoded = value;
    if (decoded is String) {
      final text = decoded;
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        return text.trim().isEmpty ? 'Request failed.' : text;
      }
    }
    if (decoded is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final message = decoded[key];
        if (message is String && message.trim().isNotEmpty) return message;
      }
      final nested = decoded['data'];
      if (nested != null) return _message(nested);
    }
    return 'Request failed.';
  }
}

class AuthSession {
  const AuthSession({required this.token, this.expiresAt, this.userId});
  final String token;
  final DateTime? expiresAt;
  final int? userId;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
