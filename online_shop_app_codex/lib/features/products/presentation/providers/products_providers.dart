import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/product.dart';
import '../../data/services/products_api_service.dart';

final productsApiServiceProvider = Provider<ProductsApiService>((ref) {
  return ProductsApiService(ref.watch(dioProvider));
});

class ProductQuery {
  const ProductQuery({this.categoryId, this.search, this.perPage = 10});
  final int? categoryId;
  final String? search;
  final int perPage;

  @override
  bool operator ==(Object other) =>
      other is ProductQuery &&
      other.categoryId == categoryId &&
      other.search == search &&
      other.perPage == perPage;
  @override
  int get hashCode => Object.hash(categoryId, search, perPage);
}

final productResultsProvider = AsyncNotifierProvider.autoDispose
    .family<ProductsNotifier, ProductsListState, ProductQuery>(
      ProductsNotifier.new,
    );
final productsProvider = productResultsProvider(const ProductQuery());

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
  ProductsNotifier(this.query);
  final ProductQuery query;
  CancelToken? _cancelToken;
  int _generation = 0;

  @override
  Future<ProductsListState> build() {
    ref.onDispose(() {
      _generation++;
      _cancelToken?.cancel();
    });
    return _loadFirstPage();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _cancelToken?.cancel();
    state = const AsyncLoading();
    final result = await AsyncValue.guard(_loadFirstPage);
    if (ref.mounted && generation == _generation) state = result;
  }

  Future<void> loadNextPage() async {
    final current = state.value;

    if (state.isLoading ||
        current == null ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );

    final generation = _generation;
    try {
      final nextProducts = await ref
          .read(productsApiServiceProvider)
          .getProducts(
            page: current.nextPage,
            perPage: query.perPage,
            categoryId: query.categoryId,
            search: query.search,
            cancelToken: _cancelToken,
          );
      if (!ref.mounted || generation != _generation) return;
      final products = {
        for (final product in current.products) product.id: product,
      };
      final previousCount = products.length;
      for (final product in nextProducts) {
        products[product.id] = product;
      }

      state = AsyncData(
        current.copyWith(
          products: List.unmodifiable(products.values),
          nextPage: current.nextPage + 1,
          hasMore:
              nextProducts.length == query.perPage &&
              products.length > previousCount,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error),
      );
    }
  }

  Future<ProductsListState> _loadFirstPage() async {
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    final products = await ref
        .read(productsApiServiceProvider)
        .getProducts(
          page: 1,
          perPage: query.perPage,
          categoryId: query.categoryId,
          search: query.search,
          cancelToken: cancelToken,
        );

    return ProductsListState(
      products: List.unmodifiable(
        {for (final product in products) product.id: product}.values,
      ),
      nextPage: 2,
      hasMore: products.length == query.perPage,
    );
  }
}
