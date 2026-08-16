import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import 'providers/products_providers.dart';
import 'widgets/product_list_item.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productsProvider.future),
        child: productsAsync.when(
          loading: () =>
              const _CenteredState(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _ErrorView(onRetry: () => ref.invalidate(productsProvider)),
          data: (products) {
            if (products.isEmpty) {
              return const _CenteredState(child: _EmptyViewContent());
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = products[index];

                      return ProductListItem(
                        product: product,
                        onTap: () =>
                            context.go('${AppRoutes.products}/${product.id}'),
                      );
                    }, childCount: products.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load products.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyViewContent extends StatelessWidget {
  const _EmptyViewContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inventory_2_outlined, size: 48),
        const SizedBox(height: 16),
        Text(
          'No products found.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
