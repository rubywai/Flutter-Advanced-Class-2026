import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product_detail.dart';
import 'providers/product_detail_provider.dart';
import 'widgets/product_detail_gallery.dart';
import 'widgets/product_option_chooser.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productDetailProvider(productId);
    final product = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: product.isLoading
                ? null
                : () => ref.invalidate(provider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh failures are presented by the provider's error state.
            try {
              ref.invalidate(provider);
              await ref.read(provider.future);
            } catch (_) {}
          },
          child: product.when(
            skipLoadingOnRefresh: false,
            loading: () =>
                const _StatusBody(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _StatusBody(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load this product.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(provider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
            data: (detail) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final gallery = ProductDetailGallery(
                        key: ValueKey(detail.id),
                        images: detail.images,
                        productName: detail.name,
                      );
                      final information = _ProductInformation(product: detail);
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: gallery),
                            const SizedBox(width: 32),
                            Expanded(child: information),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          gallery,
                          const SizedBox(height: 24),
                          information,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product});
  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regular = double.tryParse(product.regularPrice);
    final current = double.tryParse(product.price);
    final showDiscount =
        product.onSale &&
        regular != null &&
        current != null &&
        regular > current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.isEmpty ? 'Product' : product.name,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(product.displayPrice, style: theme.textTheme.titleLarge),
            if (showDiscount)
              Text(
                '${product.regularPrice} Ks',
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(product.availability)),
          ],
        ),
        if (product.type == 'variable') ProductOptionChooser(product: product),
        if (product.ratingCount > 0) ...[
          const SizedBox(height: 12),
          Text('${product.averageRating} / 5 (${product.ratingCount} ratings)'),
        ],
        if (product.shortDescription.isNotEmpty)
          _Section(
            title: 'Overview',
            child: SelectableText(product.shortDescription),
          ),
        if (product.description.isNotEmpty &&
            product.description != product.shortDescription)
          _Section(
            title: 'Description',
            child: SelectableText(product.description),
          ),
        if (product.attributes.any((attribute) => !attribute.isVariation))
          _Section(
            title: 'Attributes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final attribute in product.attributes.where(
                  (attribute) => !attribute.isVariation,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${attribute.name}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: attribute.options.join(', ')),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (product.categories.isNotEmpty)
          _Section(
            title: 'Categories',
            child: Text(product.categories.join(', ')),
          ),
        if (product.sku.isNotEmpty)
          _Section(title: 'SKU', child: SelectableText(product.sku)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
