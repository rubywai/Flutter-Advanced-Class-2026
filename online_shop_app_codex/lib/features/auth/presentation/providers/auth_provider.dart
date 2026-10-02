import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(dioProvider)),
);

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  const AuthState({
    this.token,
    this.expiresAt,
    this.userId,
    this.initialized = false,
  });
  final String? token;
  final DateTime? expiresAt;
  final int? userId;
  final bool initialized;
  bool get isAuthenticated =>
      token != null &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _tokenKey = 'auth.jwt';
  static const _expiryKey = 'auth.expiry';
  static const _userIdKey = 'auth.user_id';
  @override
  Future<AuthState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawExpiry = prefs.getInt(_expiryKey);
    var userId = prefs.getInt(_userIdKey);
    userId ??= _userIdFromToken(token);
    if (userId != null) await prefs.setInt(_userIdKey, userId);
    final expiry = rawExpiry == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(rawExpiry);
    if (token == null || (expiry != null && expiry.isBefore(DateTime.now()))) {
      return const AuthState(initialized: true);
    }
    ref.read(dioProvider).options.headers['Authorization'] = 'Bearer $token';
    return AuthState(
      token: token,
      expiresAt: expiry,
      userId: userId,
      initialized: true,
    );
  }

  int? _userIdFromToken(String? token) {
    try {
      if (token == null) return null;
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload is Map ? int.tryParse('${payload['id']}') : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authServiceProvider)
          .login(email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.token);
      if (session.expiresAt != null) {
        await prefs.setInt(
          _expiryKey,
          session.expiresAt!.millisecondsSinceEpoch,
        );
      }
      if (session.userId != null) {
        await prefs.setInt(_userIdKey, session.userId!);
      }
      ref.read(dioProvider).options.headers['Authorization'] =
          'Bearer ${session.token}';
      return AuthState(
        token: session.token,
        expiresAt: session.expiresAt,
        userId: session.userId,
        initialized: true,
      );
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_userIdKey);
    ref.read(dioProvider).options.headers.remove('Authorization');
    state = const AsyncData(AuthState(initialized: true));
  }
}
