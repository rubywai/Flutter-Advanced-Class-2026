import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/product.dart';
import '../../data/services/products_api_service.dart';

final productsApiServiceProvider = Provider<ProductsApiService>((ref) {
  return ProductsApiService(ref.watch(dioProvider));
});

final productsProvider =
    AsyncNotifierProvider.autoDispose<ProductsNotifier, ProductsListState>(
      ProductsNotifier.new,
    );

const _productsPerPage = 10;

class ProductsListState {
  const ProductsListState({
    required this.products,
    required this.nextPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Product> products;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  ProductsListState copyWith({
    List<Product>? products,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return ProductsListState(
      products: products ?? this.products,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
    );
  }
}

class ProductsNotifier extends AsyncNotifier<ProductsListState> {
  @override
  Future<ProductsListState> build() => _loadFirstPage();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFirstPage);
  }

  Future<void> loadNextPage() async {
    final current = state.value;

    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );

    try {
      final nextProducts = await ref
          .read(productsApiServiceProvider)
          .getProducts(page: current.nextPage, perPage: _productsPerPage);

      state = AsyncData(
        current.copyWith(
          products: [...current.products, ...nextProducts],
          nextPage: current.nextPage + 1,
          hasMore: nextProducts.length == _productsPerPage,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error),
      );
    }
  }

  Future<ProductsListState> _loadFirstPage() async {
    final products = await ref
        .read(productsApiServiceProvider)
        .getProducts(page: 1, perPage: _productsPerPage);

    return ProductsListState(
      products: products,
      nextPage: 2,
      hasMore: products.length == _productsPerPage,
    );
  }
}
