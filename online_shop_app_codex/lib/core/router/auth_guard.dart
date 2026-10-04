import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

/// Use this redirect on any route that requires an authenticated session.
String? requireAuthentication(AuthState auth, GoRouterState state) {
  if (!auth.initialized || auth.isAuthenticated) return null;
  return Uri(
    path: '/auth/login',
    queryParameters: {'redirect': state.uri.toString()},
  ).toString();
}
