import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/data/models/product_detail.dart';
import '../../../products/presentation/providers/product_options_provider.dart';
import '../../data/models/cart_item.dart';
import '../providers/cart_provider.dart';

class AddToCartControl extends ConsumerStatefulWidget {
  const AddToCartControl({super.key, required this.product});
  final ProductDetail product;

  @override
  ConsumerState<AddToCartControl> createState() => _AddToCartControlState();
}

class _AddToCartControlState extends ConsumerState<AddToCartControl> {
  int _quantity = 1;
  bool _busy = false;

  Future<void> _add({
    ProductVariation? variation,
    Map<String, String> options = const {},
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(cartProvider.notifier)
          .add(
            widget.product,
            _quantity,
            variation: variation,
            options: options,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Added to cart.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is CartException
                ? error.message
                : 'Could not add to cart. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isVariable = product.type == 'variable';
    final optionProvider = productOptionsProvider(product.id);
    final selected = ref.watch(optionProvider);
    final variationAttributes = product.attributes
        .where((a) => a.isVariation)
        .toList();
    final complete =
        variationAttributes.isNotEmpty &&
        variationAttributes.every(
          (attribute) =>
              attribute.options.contains(selected[attribute.selectionKey]),
        );
    final options = <String, String>{
      for (final attribute in variationAttributes)
        if (selected[attribute.selectionKey] != null)
          attribute.name.trim().toLowerCase():
              selected[attribute.selectionKey]!,
    };
    final query = complete
        ? ProductVariationQuery(
            variationIds: product.variationIds,
            options: options,
          )
        : null;
    final variationAsync = query == null
        ? null
        : ref.watch(productVariationProvider(query));
    final variation = variationAsync?.asData?.value;

    final existing =
        ref.watch(cartProvider).asData?.value ?? const <CartItem>[];
    final current = existing.where(
      (item) =>
          item.productId == product.id &&
          item.variationId == (variation?.id ?? 0),
    );
    final alreadyInCart = current.isEmpty ? 0 : current.first.quantity;
    final candidate = CartItem.fromProduct(
      product,
      _quantity,
      variation: variation,
    );
    final permitted = variationAsync == null
        ? candidate.permits(alreadyInCart + _quantity)
        : variation != null &&
              variation.isAvailable &&
              candidate.permits(alreadyInCart + _quantity);
    final price = variation?.price ?? product.price;
    final regular = variation?.regularPrice ?? product.regularPrice;
    final showPrice = isVariable && variation != null;
    final reason = !isVariable ? CartItem.unavailableReason(product) : null;

    String? status;
    if (isVariable && !complete) {
      status =
          'Select ${variationAttributes.map((a) => a.name).join(' and ')}.';
    } else if (variationAsync?.isLoading == true) {
      status = 'Checking selected option...';
    } else if (variationAsync?.hasError == true) {
      status = 'Could not check this option. Retry below.';
    } else if (isVariable && variation == null && complete) {
      status = 'This option is unavailable.';
    } else if (variation != null) {
      status = variation.availability;
    } else if (reason != null) {
      status = reason;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPrice)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              spacing: 8,
              children: [
                Text(
                  '$price Ks',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (variation.onSale && regular.isNotEmpty && regular != price)
                  Text(
                    '$regular Ks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (variationAsync?.hasError == true && query != null)
                  IconButton(
                    tooltip: 'Retry option lookup',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        ref.invalidate(productVariationProvider(query)),
                    icon: const Icon(Icons.refresh, size: 20),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            IconButton(
              tooltip: 'Decrease quantity',
              onPressed: !_busy && _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 36,
              child: Text('$_quantity', textAlign: TextAlign.center),
            ),
            IconButton(
              tooltip: 'Increase quantity',
              onPressed:
                  !_busy &&
                      permitted &&
                      candidate.permits(alreadyInCart + _quantity + 1)
                  ? () => setState(() => _quantity++)
                  : null,
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    !_busy &&
                        permitted &&
                        (isVariable ? variation != null : reason == null)
                    ? () => _add(variation: variation, options: options)
                    : null,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(_busy ? 'Adding...' : 'Add to cart'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
