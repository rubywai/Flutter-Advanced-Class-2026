import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/models/product.dart';
import '../../data/services/products_api_service.dart';

final productsApiServiceProvider = Provider<ProductsApiService>((ref) {
  return ProductsApiService(ref.watch(dioProvider));
});

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productsApiServiceProvider).getProducts();
});
