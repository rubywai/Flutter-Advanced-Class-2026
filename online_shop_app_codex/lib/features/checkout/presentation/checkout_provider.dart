import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../data/checkout_models.dart';
import '../data/checkout_service.dart';

final checkoutServiceProvider = Provider(
  (ref) => CheckoutService(ref.watch(dioProvider)),
);
final shippingMethodsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(checkoutServiceProvider).shippingMethods(),
);
final checkoutProvider =
    NotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
      CheckoutNotifier.new,
    );

class CheckoutState {
  const CheckoutState({
    this.busy = false,
    this.result,
    this.error,
    this.uncertain = false,
    this.cleanupPending = false,
  });
  final bool busy, uncertain, cleanupPending;
  final OrderResult? result;
  final String? error;
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  OrderRequest? _submitted;
  @override
  CheckoutState build() => const CheckoutState();

  Future<void> submit(OrderRequest request) async {
    if (state.busy || state.result != null) return;
    if (ref.read(authProvider).value?.isAuthenticated != true) {
      state = const CheckoutState(
        error: 'Please log in before placing an order.',
      );
      return;
    }
    if (request.items.isEmpty || request.method.cost == null) return;
    final keepAlive = ref.keepAlive();
    state = const CheckoutState(busy: true);
    try {
      _submitted = request;
      final result = await ref
          .read(checkoutServiceProvider)
          .createOrder(request);
      state = CheckoutState(busy: true, result: result, cleanupPending: true);
      await cleanup();
    } catch (error) {
      state = CheckoutState(
        error: error is CheckoutException
            ? error.message
            : 'The order result is unknown. Check with the shop before retrying.',
        uncertain: error is CheckoutException ? error.uncertain : true,
      );
    } finally {
      keepAlive.close();
    }
  }

  Future<void> cleanup() async {
    final result = state.result;
    if (result == null || _submitted == null || !state.cleanupPending) return;
    state = CheckoutState(busy: true, result: result, cleanupPending: true);
    try {
      await ref.read(cartProvider.notifier).removePurchased(_submitted!.items);
      state = CheckoutState(result: result);
    } catch (_) {
      state = CheckoutState(
        result: result,
        cleanupPending: true,
        error:
            'Order created, but purchased items could not be removed from your cart. Retry cart cleanup.',
      );
    }
  }
}
