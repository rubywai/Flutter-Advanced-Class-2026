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
  const AuthState({this.token, this.expiresAt, this.initialized = false});
  final String? token;
  final DateTime? expiresAt;
  final bool initialized;
  bool get isAuthenticated =>
      token != null &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _tokenKey = 'auth.jwt';
  static const _expiryKey = 'auth.expiry';
  @override
  Future<AuthState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawExpiry = prefs.getInt(_expiryKey);
    final expiry = rawExpiry == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(rawExpiry);
    if (token == null || (expiry != null && expiry.isBefore(DateTime.now()))) {
      return const AuthState(initialized: true);
    }
    ref.read(dioProvider).options.headers['Authorization'] = 'Bearer $token';
    return AuthState(token: token, expiresAt: expiry, initialized: true);
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
      ref.read(dioProvider).options.headers['Authorization'] =
          'Bearer ${session.token}';
      return AuthState(
        token: session.token,
        expiresAt: session.expiresAt,
        initialized: true,
      );
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    ref.read(dioProvider).options.headers.remove('Authorization');
    state = const AsyncData(AuthState(initialized: true));
  }
}
