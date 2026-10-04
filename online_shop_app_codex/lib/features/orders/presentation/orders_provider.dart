import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../data/order_summary.dart';
import '../data/orders_service.dart';

final ordersServiceProvider = Provider(
  (ref) => OrdersService(ref.watch(dioProvider)),
);

// An outer provider switches immediately to a new customer/session key so stale
// results from an earlier account cannot remain visible during reauthentication.
final ordersProvider = Provider.autoDispose
    .family<AsyncValue<List<OrderSummary>>, String?>((ref, status) {
      final auth = ref.watch(authProvider);
      if (auth.isLoading) return const AsyncLoading();
      if (auth.hasError) {
        return AsyncError(
          const OrdersException(
            'Could not restore your session. Please log in again.',
          ),
          StackTrace.current,
        );
      }
      final session = auth.value;
      if (session == null || !session.isAuthenticated) {
        return const AsyncData([]);
      }
      final id = session.userId;
      if (id == null || id <= 0) {
        return AsyncError(
          const OrdersException(
            'Your session has no customer ID. Log out and log in again.',
          ),
          StackTrace.current,
        );
      }
      return ref.watch(
        _sessionOrdersProvider((id: id, token: session.token!, status: status)),
      );
    });

final _sessionOrdersProvider = FutureProvider.autoDispose
    .family<List<OrderSummary>, ({int id, String token, String? status})>((
      ref,
      session,
    ) {
      final cancel = CancelToken();
      ref.onDispose(() => cancel.cancel());
      return ref
          .watch(ordersServiceProvider)
          .getOrders(session.id, cancelToken: cancel, status: session.status);
    });

Future<void> refreshOrders(WidgetRef ref, {String? status}) async {
  final session = ref.read(authProvider).value;
  if (session?.isAuthenticated != true ||
      session?.userId == null ||
      session?.token == null) {
    return;
  }
  final provider = _sessionOrdersProvider((
    id: session!.userId!,
    token: session.token!,
    status: status,
  ));
  ref.invalidate(provider);
  try {
    await ref.read(provider.future);
  } catch (_) {
    /* Render the provider error state. */
  }
}

void invalidateOrders(WidgetRef ref) {
  ref.invalidate(_sessionOrdersProvider);
  ref.invalidate(ordersProvider);
}
