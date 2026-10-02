import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_detail.dart';
import 'products_providers.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<ProductDetail, String>((ref, id) {
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      return ref
          .watch(productsApiServiceProvider)
          .getProduct(id, cancelToken: cancelToken);
    });
