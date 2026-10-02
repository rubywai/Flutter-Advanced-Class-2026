import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/products_providers.dart';
import 'product_list_item.dart';

class ProductResultsView extends ConsumerWidget {
  const ProductResultsView({
    super.key,
    required this.query,
    this.emptyMessage = 'No products found.',
  });
  final ProductQuery query;
  final String emptyMessage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = productResultsProvider(query);
    final result = ref.watch(provider);
    return RefreshIndicator(
      onRefresh: () => ref.read(provider.notifier).refresh(),
      child: result.when(
        skipLoadingOnRefresh: false,
        loading: () => const _Status(child: CircularProgressIndicator()),
        error: (error, stack) => _Status(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load products.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(provider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data.products.isEmpty) return _Status(child: Text(emptyMessage));
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical &&
                  notification.metrics.extentAfter < 600 &&
                  data.loadMoreError == null) {
                ref.read(provider.notifier).loadNextPage();
              }
              return false;
            },
            child: CustomScrollView(
              key: PageStorageKey(query),
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
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = data.products[index];
                      return ProductListItem(
                        product: product,
                        onTap: () => context.pushNamed(
                          AppRoutes.productDetailsName,
                          pathParameters: {'productId': '${product.id}'},
                        ),
                      );
                    }, childCount: data.products.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Center(
                      child: data.isLoadingMore
                          ? const CircularProgressIndicator()
                          : data.hasMore
                          ? TextButton.icon(
                              onPressed: () =>
                                  ref.read(provider.notifier).loadNextPage(),
                              icon: Icon(
                                data.loadMoreError == null
                                    ? Icons.expand_more
                                    : Icons.refresh,
                              ),
                              label: Text(
                                data.loadMoreError == null
                                    ? 'Load more'
                                    : 'Retry loading more',
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    ],
  );
}
