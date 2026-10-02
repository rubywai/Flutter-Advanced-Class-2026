import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/data/models/product_detail.dart';
import '../../data/models/cart_item.dart';
import '../../data/services/cart_service.dart';

final cartServiceProvider = Provider((ref) => CartService());
final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  Future<void> _tail = Future<void>.value();

  @override
  Future<List<CartItem>> build() => ref.read(cartServiceProvider).load();

  Future<void> _mutate(Future<List<CartItem>> Function() action) {
    final result = _tail.then((_) async {
      // Finish initial hydration before publishing a mutation result.
      if (state.isLoading) await future;
      final items = await action();
      state = AsyncData(items);
    });
    _tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<void> reload() => _mutate(() => ref.read(cartServiceProvider).load());
  Future<void> add(
    ProductDetail product,
    int quantity, {
    ProductVariation? variation,
    Map<String, String> options = const {},
  }) => _mutate(
    () => ref
        .read(cartServiceProvider)
        .add(product, quantity, variation: variation, options: options),
  );
  Future<void> setQuantity(int id, int quantity) =>
      _mutate(() => ref.read(cartServiceProvider).setQuantity(id, 0, quantity));
  Future<void> setLineQuantity(int id, int variationId, int quantity) =>
      _mutate(
        () => ref
            .read(cartServiceProvider)
            .setQuantity(id, variationId, quantity),
      );
  Future<void> remove(int id) =>
      _mutate(() => ref.read(cartServiceProvider).remove(id, 0));
  Future<void> removeLine(int id, int variationId) =>
      _mutate(() => ref.read(cartServiceProvider).remove(id, variationId));
}
