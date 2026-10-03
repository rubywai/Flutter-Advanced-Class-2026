import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';

import '../data/models/cart_item.dart';
import 'providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is CartException
                ? error.message
                : 'Could not update cart. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load cart.'),
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(ref.read(cartProvider.notifier).reload),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          final subtotal = items.fold(
            CartMoney.zero,
            (sum, item) => sum + item.total,
          );
          return Column(
            children: [
              if (_busy) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final notifier = ref.read(cartProvider.notifier);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox.square(
                              dimension: 64,
                              child: item.imageUrl.isEmpty
                                  ? const Icon(
                                      Icons.image_not_supported_outlined,
                                    )
                                  : Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, error, stack) =>
                                          const Icon(
                                            Icons.image_not_supported_outlined,
                                          ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${item.unitPrice} Ks'),
                                  if (item.options.isNotEmpty)
                                    Text(
                                      item.options.entries
                                          .map(
                                            (entry) =>
                                                '${entry.key}: ${entry.value}',
                                          )
                                          .join(' · '),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove item',
                              onPressed: _busy
                                  ? null
                                  : () => _run(
                                      () => notifier.removeLine(
                                        item.productId,
                                        item.variationId,
                                      ),
                                    ),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Decrease quantity',
                                  onPressed: !_busy && item.quantity > 1
                                      ? () => _run(
                                          () => notifier.setLineQuantity(
                                            item.productId,
                                            item.variationId,
                                            item.quantity - 1,
                                          ),
                                        )
                                      : null,
                                  icon: const Icon(Icons.remove),
                                ),
                                SizedBox(
                                  width: 64,
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Increase quantity',
                                  onPressed:
                                      !_busy && item.permits(item.quantity + 1)
                                      ? () => _run(
                                          () => notifier.setLineQuantity(
                                            item.productId,
                                            item.variationId,
                                            item.quantity + 1,
                                          ),
                                        )
                                      : null,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                            Text(
                              '${item.total} Ks',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Subtotal: $subtotal Ks',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _busy
                              ? null
                              : () => context.pushNamed(AppRoutes.checkoutName),
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
